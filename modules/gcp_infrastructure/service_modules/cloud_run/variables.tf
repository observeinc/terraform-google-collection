variable "project_id" {
  type        = string
  description = "GCP project to deploy sample env"
}

variable "region" {
  type        = string
  description = "GCP region to deploy sample env"
}

variable "name_format" {
  type        = string
  description = "Format string to use for infra names."
}

variable "always_run_load_tests" {
  type        = bool
  description = "Configures whether to run a load test in every deploy of this resource"
  default     = false
}
