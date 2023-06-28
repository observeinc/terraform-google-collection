output "bigquery" {
  value     = module.bigquery
  sensitive = true
}
# endpoints for bigquery operations
# tf output -json | jq -r '.bigquery.value.bigquery_selflink'
# tf output -json | jq -r '.bigquery.value.bigquery_selflink2'

output "compute_otel_collector" {
  value     = module.compute_otel_collector
  sensitive = true
}
# tf output -json | jq -r '.compute_otel_collector.value.gcp_ubuntu_box.compute_instances'
# sudo journalctl -u otelcol


output "function_bigquery" {
  value     = module.function_bigquery
  sensitive = true
}

output "function_bigquery_write_payload" {
  value = jsonencode({
    "method" : "write",
  "biq_query_table" : module.bigquery.bigquery_selflink2 })
}
# tf output -json | jq -r '.function_bigquery_write_payload.value'

output "collector_endpoint" {
  value     = "http://${module.compute_otel_collector.gcp_ubuntu_box.compute_instances.UBUNTU_20_04_LTS_0.public_ip}:4317"
  sensitive = true
}
# tf output -json | jq -r '.collector_endpoint.value'

output "cloudsql" {
  value     = module.cloudsql
  sensitive = true
}
# tf output -json | jq -r '.cloudsql.value.connection_string'

output "function_mysql" {
  value     = module.function_mysql
  sensitive = true
}
# tf output -json | jq -r '.function_mysql.value.cloud_function_trigger'

output "function_postgres" {
  value     = module.function_postgres
  sensitive = true
}
# tf output -json | jq -r '.function_postgres.value'



output "gke" {
  value     = module.gke
  sensitive = true
}
# tf output -json | jq -r '.gke.value'

output "google_artifact_registry_repository" {
  value     = google_artifact_registry_repository.my_repo
  sensitive = true
}
# tf output -json | jq -r '.google_artifact_registry_repository.value'


output "redis" {
  value     = module.redis
  sensitive = true
}
# tf output -json | jq -r '.redis.value'

output "function_redis" {
  value     = module.function_redis
  sensitive = true
}
# tf output -json | jq -r '.function_redis.value'


