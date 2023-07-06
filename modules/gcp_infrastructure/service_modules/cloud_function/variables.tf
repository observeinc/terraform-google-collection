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

variable "function_roles" {
  description = <<-EOF
    A list of IAM roles to give the Cloud Function.
  EOF
  type        = set(string)

  default = [
    "roles/browser", # for viewing projects
  ]
}

variable "source_dir" {
  type        = string
  description = "Code source"
}

variable "output_path" {
  type        = string
  description = "Output path for zip file"
}

variable "description" {
  type        = string
  description = "Function description"
  default     = "sample function"
}

variable "runtime" {
  type        = string
  description = "Function runtime"
  default     = "python310"
}

variable "environment_variables" {
  type        = map(any)
  description = "Function environment variables"
  default = {
    CONSOLE_LOGGING   = true
    COLLECTOR_LOGGING = false
  }
}


# merge({
#     "REDIS_HOST"        = google_redis_instance.cache.host
#     "REDIS_PORT"        = google_redis_instance.cache.port
#     "CONSOLE_LOGGING"   = true
#     "COLLECTOR_LOGGING" = false
#     # "VERSION"    = "${var.function_bucket}/${var.function_object}"
#   }, var.function_disable_logging ? { "DISABLE_LOGGING" : "ok" } : {})
variable "function_available_memory_mb" {
  description = "Memory (in MB), available to the function. Default value is 512. Possible values include 128, 256, 512, 1024, etc."
  type        = number
  default     = 1024
}

variable "function_timeout" {
  description = <<-EOF
    Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds.
  EOF
  type        = number
  default     = 300
}

variable "function_max_instances" {
  description = "The limit on the maximum number of function instances that may coexist at a given time."
  type        = number
  default     = 5
}

variable "vpc_connector_id" {
  type        = string
  default     = null
  description = "id of vpc connector"
}
