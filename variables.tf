variable "name" {
  type    = string
  default = "observe-collection"

  validation {
    condition     = length(var.name) <= 20
    error_message = "The name must be less than 20 characters long."
  }
}

variable "observe_customer" {
  description = "Observe Customer ID"
  type        = string
}

variable "observe_token" {
  description = "Observe Token"
  type        = string
}

variable "observe_domain" {
  description = "Observe Domain"
  type        = string
  default     = "observeinc.com"
}

variable "region" {
  description = "The Google Cloud region to deploy resources in"
  type        = string
}

variable "pubsub_ack_deadline_seconds" {
  description = "Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = number
  default     = 60
}

variable "pubsub_message_retention_duration" {
  description = "Message retention for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = string
  default     = "86400s"
}

variable "pubsub_minimum_backoff" {
  description = "Retry policy minimum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = string
  default     = "10s"
}

variable "pubsub_maximum_backoff" {
  description = "Retry policy maximum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = string
  default     = "600s"
}
