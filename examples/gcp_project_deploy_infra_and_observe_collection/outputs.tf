output "project" {
  description = "The Pub/Sub project of the subcription (to be passed to the Pub/Sub poller)"
  value       = module.observe_gcp_collection.project
}

# To extract correct value - terraform output -json | jq -r '.subscription.value.name' 
output "subscription" {
  description = "The Pub/Sub subscription created by this module (to be passed to the Pub/Sub poller)"
  value       = module.observe_gcp_collection.subscription
}

# To extract properly formatted string - terraform output -json | jq -r '.service_account_private_key.value'
output "service_account_private_key" {
  description = "A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring"
  value       = base64decode(module.observe_gcp_collection.service_account_key.private_key)
  sensitive   = true
}