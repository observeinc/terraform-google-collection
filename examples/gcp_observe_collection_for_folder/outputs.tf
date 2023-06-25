output "subscription" {
  description = "The Pub/Sub subscription created by this module."
  value       = module.observe_gcp_collection.subscription
}

output "service_account_private_key" {
  description = "A service account key sent to the pollers for Pub/Sub and Cloud Monitoring"
  value       = base64decode(module.observe_gcp_collection.service_account_key.private_key)
  sensitive   = true
}

output "project_info" {
  value = data.google_project.service_project
}

output "projects" {
  value = data.google_projects.my-folder-projects
}