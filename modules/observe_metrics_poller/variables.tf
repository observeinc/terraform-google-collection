variable "workspace" {
  type        = object({ oid = string, id = string })
  description = "Workspace to apply module to."
}

variable "datastream" {
  type = object({
    oid = string
  })
  description = <<-EOF
    Datastream to derive resources from.
  EOF
}

variable "project_id" {
  type        = string
  description = "GCP project_id"
}

variable "name_format" {
  type        = string
  description = "Format string to use for infra names."
}

variable "service_account_private_key_json" {
  type        = string
  description = "The GCP Service Accont Key to authenticate polling the API"
}

variable "metric_prefixes" {
  description = "Default metric prefixes to poll"
  type        = list(string)
  default = [
    "cloudfunctions.googleapis.com/",
    "logging.googleapis.com/",
    "iam.googleapis.com/",
    "monitoring.googleapis.com/",
    "pubsub.googleapis.com/",
    "storage.googleapis.com/",
    "cloudsql.googleapis.com/",
    "compute.googleapis.com/",
    "serviceruntime.googleapis.com/",
    "loadbalancing.googleapis.com/",
    "kubernetes.io/",
    "redis.googleapis.com/",
    "run.googleapis.com/"
  ]
}