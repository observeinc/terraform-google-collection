variable "project_id" {
  type        = string
  description = "GCP project to deploy sample env"
}

variable "region" {
  type        = string
  description = "GCP region to deploy sample env"
}

variable "zone1" {
  type        = string
  description = "GCP zone"
}

variable "zone2" {
  type        = string
  description = "GCP alternate zone"
}

variable "name_format" {
  type        = string
  description = "Format string to use for infra names."
}

variable "observe" {
  type = object({
    domain                = optional(string)
    customer_id           = optional(string)
    otel_datastream_token = optional(string)
    host_datastream_token = optional(string)
  })
  default     = null
  description = "Object with Observe credentials"
}
