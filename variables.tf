variable "name" {
  type        = string
  description = "Module name. Used as a name prefix."
  default     = "observe-collection"

  validation {
    condition     = length(var.name) <= 20
    error_message = "The name must be less than 20 characters long."
  }
}

variable "labels" {
  description = <<-EOF
    A map of labels to add to resources (https://cloud.google.com/resource-manager/docs/creating-managing-labels)"

    Note: Many, but not all, Google Cloud SDK resources support labels.
  EOF
  type        = map(string)
  default     = {}
}

variable "pubsub_ack_deadline_seconds" {
  description = "Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = number
  default     = 60
}

variable "logging_filter" {
  description = <<-EOF
    An advanced logs filter. The only exported log entries are those that are
    in the resource owning the sink and that match the filter.

    Relevant docs: https://cloud.google.com/logging/docs/view/building-queries
  EOF
  type        = string
  default     = ""
}

variable "logging_exclusions" {
  description = <<-EOF
    Log entries that match any of these exclusion filters will not be exported.

    If a log entry is matched by both logging_filter and one of logging_exclusions it will not be exported.

    Relevant docs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/billingAccounts.exclusions#LogExclusion
  EOF
  type = list(object({
    name        = string
    description = string
    filter      = string
    disabled    = string
  }))
  default = []
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


