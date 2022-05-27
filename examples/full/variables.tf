variable "name" {
  description = "Name"
  type        = string
}

variable "observe_customer" {
  description = "Observe Customer ID"
  type        = string
}

variable "observe_token" {
  description = "Observe token"
  type        = string
}

variable "observe_domain" {
  description = "Observe Domain"
  type        = string
  default     = "observeinc.com"
}

variable "gcp_project" {
  description = "GCP project"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}


variable "observe_workspace" {
  description = "Name of the workspace to create datasets for"
  type        = string
  default     = "Default"
}

variable "observe_services" {
  description = "Map of services to create Observe datasets for.	See the services variable in https://github.com/observeinc/terraform-observe-google."
  type        = map(bool)
  default     = {}
}

variable "include_metric_type_prefixes" {
  description = "GCP metric endpoints to pull data from"
  type        = list(any)
  default = [
    "logging.googleapis.com/",
    "iam.googleapis.com/",
    "monitoring.googleapis.com/",
    "pubsub.googleapis.com/",
    "storage.googleapis.com/",
  ]
}

variable "exclude_metric_type_prefixes" {
  description = "GCP metric endpoints to ignore. This takes precedence over include_metric_type_prefixes"
  type        = list(any)
  default     = ["aws.googleapis.com/"]
}
