variable "project_id" {
  type        = string
  description = "GCP project to deploy to"
}

variable "region" {
  type        = string
  description = "GCP region to deploy to"
}

variable "name_format" {
  type        = string
  default     = "gcp-test-%s"
  description = "name prefix"
}

variable "target_group_instances" {
  default     = []
  description = "target_group_instances"
  type        = list(any)
}
