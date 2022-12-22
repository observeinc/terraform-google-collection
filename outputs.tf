output "project" {
  description = "The ID of the Project in which resources were created"
  value       = data.google_project.this.project_id
}

output "topic" {
  description = "The Pub/Sub topic created by this module."
  value       = google_pubsub_topic.this
}

output "subscription" {
  description = "The Pub/Sub subscription created by this module."
  value       = google_pubsub_subscription.this
}

output "service_account_key" {
  description = "A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring"
  value       = google_service_account_key.poller
  sensitive   = true
}
