variable "name" {
  type        = string
  description = "Name of Observe's GCP Collection"
  default     = "observe"
}

variable "project_id" {
  type        = string
  description = "GCP project to deploy sample env"
}

variable "folder_number" {
  type        = string
  description = "GCP folder number to deploy sample env"
}

variable "datastream_name" {
  type        = string
  description = "GCP datastream"
  default     = "GCP"
}

variable "region" {
  type        = string
  description = "GCP region to deploy sample env. Required for Google provider."
}

variable "name_format" {
  type        = string
  description = "Format string to use for infra names."
}

variable "metric_services" {
  description = "Default metric service prefixes to poll"
  type        = list(string)
  default = [
    "cloudfunctions.googleapis.com",
    "cloudasset.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "sql-component.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com"
  ]
}
