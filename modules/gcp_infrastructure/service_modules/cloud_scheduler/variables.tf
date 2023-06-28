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

variable "schedule" {
  type        = string
  description = "Cron job string"
  default     = "*/2 * * * *"
}

variable "cloud_function_uri" {
  type        = string
  description = "Function uri"
}

variable "cloud_function_name" {
  type        = string
  description = "Function name"
}

variable "body" {
  type        = string
  description = "base64encode(jsonencode({ \"method\" : \"write\" })"
}

variable "md5hash" {
  type        = string
  description = "triggers lifecycle"
}


