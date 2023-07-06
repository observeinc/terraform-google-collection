locals {
  name_format = var.name_format

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # There is a stupid bug that makes permissions for cloud scheduler not work right unless I change this when it has inconsitent plan
  hack = "${module.function_bigquery.bucket_object.md5hash}=1234"
}

#------------------------------------------------------------------------#
/*
Assumed that variables are set via you.auto.tfvars

Example -
project_id  = "YOURS"
region      = "us-central1"
zone1       = "us-central1-a"
zone2       = "us-central1-b"
name_format = "YOURS-%s"
observe = {
  customer_id      = "YOURS"
  datastream_token = "YOURS"
  domain           = "observe-staging.com"
}

Modules are for each part of the GCP stack we have built services for

Modules for each deployed serve are here - sample_infrastructure/service_modules

Modules can be repeated as long as you chage names

Function code is organized here - sample_infrastructure/python_scripts
-- All functions are designed to use otel collector and are triggered by cloud scheduler jobs


*/
#------------------------------------------------------------------------#


#------------------------------------------------------------------------#
# Create a Compute Instance that Load Balancing can front
#------------------------------------------------------------------------#
module "compute" {
  source      = "./service_modules/compute"
  project_id  = var.project_id
  region      = var.region
  name_format = format(var.name_format, "compute-%s")
  observe = {
    domain : var.observe.domain
    install_linux_host_monitoring : true,
    customer_id : var.observe.customer_id
    datastream_token : var.observe.host_datastream_token
  }
  # use_branch_name        = "main"
  compute_instance_count = 1
  config_bucket_name     = module.config_bucket.bucket_name
}

module "config_bucket" {
  source     = "./service_modules/config_bucket"
  project_id = var.project_id
  # region      = var.region
  name_format = format(var.name_format, "config_bucket-%s")
}

#------------------------------------------------------------------------#
# Create a Load Balancer
#------------------------------------------------------------------------#
module "loadbalancing" {
  #   depends_on  = [module.project]
  #   count       = local.modules_var["loadbalancing"].create == true ? 1 : 0
  source      = "./service_modules/loadbalancing"
  project_id  = var.project_id
  region      = var.region
  name_format = var.name_format
  # these instances have to be in the same region as the load balancer target group
  # using a filter in compute module to produce a list in the same region even though we produce instances in other regions
  target_group_instances = module.compute.target_group_instances
}

#------------------------------------------------------------------------#
# create a compute based otel collector pointed at observe
#------------------------------------------------------------------------#
module "compute_otel_collector" {
  source     = "./service_modules/compute_otel_collector"
  project_id = var.project_id
  # region      = var.region
  zone        = "${var.region}-a"
  name_format = format(var.name_format, "otel-%s")
  observe     = var.observe
}

#------------------------------------------------------------------------#
# Create a big query dataset and tables
#------------------------------------------------------------------------#
# Important - tables expire based on dataset property see module for details
module "bigquery" {
  source     = "./service_modules/bigquery"
  project_id = var.project_id
  # region      = var.region
  name_format = local.name_format
}

#------------------------------------------------------------------------#
# create function to read and write against big query
#------------------------------------------------------------------------#
module "function_bigquery" {
  source     = "./service_modules/cloud_function"
  project_id = var.project_id
  region     = var.region
  # zone        = "${var.region}-a"
  name_format = format(var.name_format, "bq-%s")
  function_roles = [
    "roles/browser", # for viewing projects
    "roles/bigquery.jobUser",
    "roles/bigquery.dataViewer",
    "roles/bigquery.dataEditor"
  ]
  environment_variables = {
    CONSOLE_LOGGING    = "TRUE"
    COLLECTOR_LOGGING  = "TRUE"
    COLLECTOR_ENDPOINT = "http://${module.compute_otel_collector.gcp_ubuntu_box.compute_instances.UBUNTU_20_04_LTS_0.public_ip}:4317"
  }
  source_dir  = "${path.module}/python_scripts/function_code/bigquery"
  output_path = "${path.module}/python_scripts/function_code/bigquery/zip_files/bigquery_func_code.zip"
}

#------------------------------------------------------------------------#
# Create cloud scheduler job that writes to bigquery table
#------------------------------------------------------------------------#
module "cloud_scheduler_bigquery_write" {
  depends_on = [
    module.function_bigquery
  ]
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "bqwrite-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_bigquery.cloud_function_trigger
  cloud_function_name = module.function_bigquery.cloud_function_name
  body = base64encode(jsonencode({
    "method" : "write",
  "biq_query_table" : module.bigquery.bigquery_selflink2 }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create cloud scheduler job that reads bigquery table
#------------------------------------------------------------------------#
module "cloud_scheduler_bigquery_read" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "bqread-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_bigquery.cloud_function_trigger
  cloud_function_name = module.function_bigquery.cloud_function_name
  body = base64encode(jsonencode({
    "method" : "read",
  "biq_query_table" : module.bigquery.bigquery_selflink2 }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create cloud sql instances 
#------------------------------------------------------------------------#
module "cloudsql" {
  source          = "./service_modules/cloudsql"
  project_id      = var.project_id
  region          = var.region
  name_format     = format(var.name_format, "sql-%s")
  database_filter = ["MYSQL_8_0", "POSTGRES_14"] # WARNING SQL SERVER IS EXPENSIVE "MYSQL_8_0", "POSTGRES_14", "SQLSERVER_2019_STANDARD"]
}

#------------------------------------------------------------------------#
# Create function to read and write to mysql instance
#------------------------------------------------------------------------#
module "function_mysql" {
  source     = "./service_modules/cloud_function"
  project_id = var.project_id
  region     = var.region
  # zone        = "${var.region}-a"
  name_format = format(var.name_format, "mysql-%s")
  function_roles = [
    "roles/browser", # for viewing projects
  ]

  environment_variables = {
    MYSQL_HOST         = module.cloudsql.connection_string.MYSQL_8_0.host
    MYSQL_DBNAME       = module.cloudsql.connection_string.MYSQL_8_0.database_name
    MYSQL_USER         = module.cloudsql.connection_string.MYSQL_8_0.username
    MYSQL_PASSWORD     = module.cloudsql.connection_string.MYSQL_8_0.password
    CONSOLE_LOGGING    = "TRUE"
    COLLECTOR_LOGGING  = "TRUE"
    COLLECTOR_ENDPOINT = "http://${module.compute_otel_collector.gcp_ubuntu_box.compute_instances.UBUNTU_20_04_LTS_0.public_ip}:4317"
  }
  source_dir  = "${path.module}/python_scripts/function_code/mysql"
  output_path = "${path.module}/python_scripts/function_code/mysql/zip_files/mysql_func_code.zip"
}


/* Local test for python in function
tf output -json | jq -r '.cloudsql.value.connection_string'
export COLLECTOR_ENDPOINT=http://146.148.79.73:4317; 
export MYSQL_HOST=34.71.192.247; 
export MYSQL_DBNAME=cloud_freak; 
export MYSQL_USER=redfish; 
export MYSQL_PASSWORD=G0ZKH8qI; 
python3 main.py '{"method": "write"}'
*/
#------------------------------------------------------------------------#
# Create cloud scheduler job to write to mysql instance
#------------------------------------------------------------------------#
module "cloud_scheduler_mysql_write" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "mysqlwrite-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_mysql.cloud_function_trigger
  cloud_function_name = module.function_mysql.cloud_function_name
  body = base64encode(jsonencode({
  "method" : "write" }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create cloud scheduler job to read from mysql instance
#------------------------------------------------------------------------#
module "cloud_scheduler_mysql_read" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "mysqlread-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_mysql.cloud_function_trigger
  cloud_function_name = module.function_mysql.cloud_function_name
  body = base64encode(jsonencode({
  "method" : "read" }))
  md5hash = local.hack
}

/* Local test for python in function
tf output -json | jq -r '.cloudsql.value.connection_string'
export COLLECTOR_ENDPOINT=http://146.148.79.73:4317; 
export POSTGRES_HOST=34.173.99.224; 
export POSTGRES_DBNAME=cloud_freak; 
export POSTGRES_USER=mutt; 
export POSTGRES_PASSWORD=IhYip5b9; 
python3 main.py '{"method": "write"}'
*/
#------------------------------------------------------------------------#
# Create function to read and write to postgres instance
#------------------------------------------------------------------------#
module "function_postgres" {
  source      = "./service_modules/cloud_function"
  project_id  = var.project_id
  region      = var.region
  name_format = format(var.name_format, "postgres-%s")
  function_roles = [
    "roles/browser", # for viewing projects
  ]

  environment_variables = {
    POSTGRES_HOST      = module.cloudsql.connection_string.POSTGRES_14.host
    POSTGRES_DBNAME    = module.cloudsql.connection_string.POSTGRES_14.database_name
    POSTGRES_USER      = module.cloudsql.connection_string.POSTGRES_14.username
    POSTGRES_PASSWORD  = module.cloudsql.connection_string.POSTGRES_14.password
    CONSOLE_LOGGING    = "TRUE"
    COLLECTOR_LOGGING  = "TRUE"
    COLLECTOR_ENDPOINT = "http://${module.compute_otel_collector.gcp_ubuntu_box.compute_instances.UBUNTU_20_04_LTS_0.public_ip}:4317"
  }
  source_dir  = "${path.module}/python_scripts/function_code/postgres"
  output_path = "${path.module}/python_scripts/function_code/postgres/zip_files/postgres_func_code.zip"
}

#------------------------------------------------------------------------#
# Create cloud scheduler job to write to postgres instance
#------------------------------------------------------------------------#
module "cloud_scheduler_postgres_write" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "pgwrite-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_postgres.cloud_function_trigger
  cloud_function_name = module.function_postgres.cloud_function_name
  body = base64encode(jsonencode({
  "method" : "write" }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create cloud scheduler job to read from postgres instance
#------------------------------------------------------------------------#
module "cloud_scheduler_postgres_read" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "pgread-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_postgres.cloud_function_trigger
  cloud_function_name = module.function_postgres.cloud_function_name
  body = base64encode(jsonencode({
  "method" : "read" }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create kubernetes cluster
#------------------------------------------------------------------------#
module "gke" {
  source            = "./service_modules/gke"
  project_id        = var.project_id
  region            = var.region
  name_format       = var.name_format
  node_machine_type = "n1-standard-4"
  gke_num_nodes     = 1
}

#------------------------------------------------------------------------#
# Create container registry
#------------------------------------------------------------------------#
resource "google_artifact_registry_repository" "my_repo" {
  location      = var.region
  project       = var.project_id
  repository_id = "sockshop-registry"
  description   = "sockshop docker repository"
  format        = "DOCKER"
}

#------------------------------------------------------------------------#
# Create redis instance
#------------------------------------------------------------------------#
module "redis" {
  source      = "./service_modules/redis"
  project_id  = var.project_id
  region      = var.region
  zone1       = var.zone1
  zone2       = var.zone2
  name_format = var.name_format
}

#------------------------------------------------------------------------#
# Create vpc access connector for redis instance
#------------------------------------------------------------------------#
data "google_compute_network" "default" {
  name    = "default"
  project = var.project_id
}
resource "google_vpc_access_connector" "connector" {
  name          = format(var.name_format, "redis-con")
  ip_cidr_range = "10.0.2.0/28"
  network       = data.google_compute_network.default.name
  project       = var.project_id
  region        = var.region
  machine_type  = "e2-standard-4"
}

#------------------------------------------------------------------------#
# Create function to read and write to redis instance
#------------------------------------------------------------------------#
module "function_redis" {
  source     = "./service_modules/cloud_function"
  project_id = var.project_id
  region     = var.region

  name_format = format(var.name_format, "redis-%s")
  function_roles = [
    "roles/browser", # for viewing projects
  ]

  environment_variables = {
    REDIS_HOST         = module.redis.host
    REDIS_PORT         = module.redis.port
    CONSOLE_LOGGING    = "TRUE"
    COLLECTOR_LOGGING  = "TRUE"
    COLLECTOR_ENDPOINT = "http://${module.compute_otel_collector.gcp_ubuntu_box.compute_instances.UBUNTU_20_04_LTS_0.public_ip}:4317"
  }

  source_dir       = "${path.module}/python_scripts/function_code/redis"
  output_path      = "${path.module}/python_scripts/function_code/postgres/zip_files/redis_func_code.zip"
  vpc_connector_id = google_vpc_access_connector.connector.id
}

#------------------------------------------------------------------------#
# Create cloud scheduler job to write to redis instance
#------------------------------------------------------------------------#
module "cloud_scheduler_redis_write" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "redwrite-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_redis.cloud_function_trigger
  cloud_function_name = module.function_redis.cloud_function_name
  body = base64encode(jsonencode({
  "method" : "write" }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create cloud scheduler job to read from postgres instance
#------------------------------------------------------------------------#
module "cloud_scheduler_redis_read" {
  source              = "./service_modules/cloud_scheduler"
  project_id          = var.project_id
  region              = var.region
  name_format         = format(var.name_format, "redread-%s")
  schedule            = "* * * * *"
  cloud_function_uri  = module.function_redis.cloud_function_trigger
  cloud_function_name = module.function_redis.cloud_function_name
  body = base64encode(jsonencode({
  "method" : "read" }))
  md5hash = local.hack
}

#------------------------------------------------------------------------#
# Create cloud run instance
#------------------------------------------------------------------------#
module "cloud_run" {
  source      = "./service_modules/cloud_run"
  project_id  = var.project_id
  region      = var.region
  name_format = format(var.name_format, "redread-%s")

}
# need to add Eventarc trigger service to projects
