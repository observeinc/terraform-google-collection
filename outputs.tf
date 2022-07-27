output "project" {
  description = "The ID of the Project in which resources were created"
  value       = local.project
}

output "region" {
  description = "The region in which resources were created"
  value       = local.region
}

output "subscription" {
  value       = { for key, value in google_pubsub_subscription.this : key => value }
  description = "The Pub/Sub subscription created by this module."
}

output "service_account_key" {
  description = "A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring"
  value       = google_service_account_key.poller
  sensitive   = true
}
