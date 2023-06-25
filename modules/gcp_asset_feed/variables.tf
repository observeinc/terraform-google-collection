variable "project_id" {
  type        = string
  description = "Project ID from GCP console"
  # https://support.google.com/googleapi/answer/7014113?hl=en#
}

variable "feed_name" {
  type        = string
  description = "the topic name where the resources will be sent"
}

variable "topic_id" {
  type        = string
  description = "the topic name where the resources will be sent"
}