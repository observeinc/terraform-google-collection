variable "name" {
  type        = string
  description = "Poller name. Should be unique per datastream."
  default     = "PubSub"
}

# tflint-ignore: terraform_unused_declarations
variable "description" {
  type        = string
  description = "Short description meant for other humans"
  default     = "GCP Poller for Pub/Sub data"
}

variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "datastream" {
  type = object({
    oid = string
  })
  description = <<-EOF
    Datastream to derive resources from.
  EOF
}

variable "project" {
  type        = string
  description = "GCP Project ID"
}

variable "subscription" {
  type        = string
  description = "GCP Pub/Sub Subscription ID (from topic)"
}

variable "service_account_private_key_json" {
  sensitive   = true
  type        = string
  description = <<-EOF
    A GCP Service Account should include the following role: Pub/Sub Subscriber (roles/pubsub.subscriber).
    
    Please enter the entire JSON string of your service account.
  EOF
}
