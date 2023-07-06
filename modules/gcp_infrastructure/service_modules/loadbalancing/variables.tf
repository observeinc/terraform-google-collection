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

# variable "compute_instance_count" {
#   default     = 2
#   description = "compute_instance_count"
# }

variable "target_group_instances" {
  default     = []
  description = "target_group_instances"
  type        = list(any)
}

# variable "function_name" {
#   type        = string
#   description = "function name"
# }
