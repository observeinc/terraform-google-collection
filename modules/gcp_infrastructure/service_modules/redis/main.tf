# You can't access redis via public ip - following commands allow you to port forward to vm on google cloud

/*
REDIS_INTERNAL_IP=$(terraform output -json redis_host | jq -r '.')
REDIS_LOCATION_ID=$(terraform output -json redis_location_id | jq -r '.')
MY_COMPUTE_NAME=$(echo "$USER-redis-port-forwarder")
gcloud_create_instance="gcloud compute instances create ${MY_COMPUTE_NAME} --machine-type=f1-micro --zone=${REDIS_LOCATION_ID}"
gcloud_delete_instance="gcloud compute instances delete ${MY_COMPUTE_NAME} --zone=${REDIS_LOCATION_ID}"
gcloud_port_forward="gcloud compute ssh ${MY_COMPUTE_NAME} --zone=${REDIS_LOCATION_ID} -- -N -L 6379:${REDIS_INTERNAL_IP}:6379"
eval "$gcloud_create_instance"
eval "$gcloud_port_forward"

# cleanup 
eval "$gcloud_delete_instance"
*/

# https://cloud.google.com/memorystore/docs/redis/connect-redis-instance#connecting_from_a_local_machine_with_port_forwarding





# resource "google_vpc_access_connector" "connector" {
#   name          = "redis-vpc-con"
#   ip_cidr_range = "10.0.1.0/28"
#   network       = data.google_compute_network.default.name
#   region        = local.region
# }


resource "google_redis_instance" "cache" {
  name           = format(var.name_format, "ha-memory-cache")
  tier           = "STANDARD_HA"
  memory_size_gb = 1
  project        = var.project_id
  region         = var.region
  # read_replicas_mode = "READ_REPLICAS_ENABLED"

  location_id             = var.zone1
  alternative_location_id = var.zone2

  redis_version = "REDIS_4_0"
  display_name  = "Terraform Test Instance"

  labels = {
    my_key    = "sample_env"
    other_key = "redis_app"
  }
}

# resource "google_redis_instance" "cache_standard" {
#   name           = "memory-cache"
#   tier           = "BASIC"
#   memory_size_gb = 1
#   project        = local.project
#   region         = local.region2

#   location_id = "${local.region2}-a"
#   # alternative_location_id = "${local.region2}-c"

#   # authorized_network = data.google_compute_network.redis-network.id

#   redis_version = "REDIS_4_0"
#   display_name  = "Terraform Test Instance Standard"
#   # reserved_ip_range = "192.168.0.0/29"

#   labels = {
#     my_key    = "arthur_test"
#     other_key = "redis_app"
#   }

# }

# resource "google_memcache_instance" "instance" {
#   name = "tf-memcache-instance"
#   # authorized_network = google_service_networking_connection.private_service_connection.network
#   project = local.project
#   region  = local.region
#   node_config {
#     cpu_count      = 1
#     memory_size_mb = 1024
#   }
#   node_count       = 3
#   memcache_version = "MEMCACHE_1_5"
#   display_name     = "Terraform Memcache"
#   labels = {
#     my_key    = "arthur_test"
#     other_key = "memcache_app"
#   }

# }
resource "google_project_iam_audit_config" "redis" {
  project = var.project_id
  service = "redis.googleapis.com"
  audit_log_config {
    log_type = "DATA_READ"
  }
  # audit_log_config {
  #   log_type = "DATA_READ"
  #   exempted_members = [
  #     "user:joebloggs@hashicorp.com",
  #   ]
  # }
}



