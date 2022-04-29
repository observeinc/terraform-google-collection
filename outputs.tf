output "project_id" {
  description = "" // TODO:
  value       = data.google_client_config.this.project
}

output "subscription_id" {
  description = <<EOF
    The id of the Pub/Sub subscription created by this module (example: observe-collection)".
  EOF
  value       = google_pubsub_subscription.this.name
}

output "service_account_key" {
  description = "A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring"
  value       = google_service_account_key.poller
  sensitive   = true
}
