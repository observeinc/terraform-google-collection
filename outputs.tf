output "subscription_id" {
  description = <<EOF
    The id of the Pub/Sub subscription created by this module (example: observe-collection)".
  EOF
  value       = google_pubsub_subscription.this.name
}
