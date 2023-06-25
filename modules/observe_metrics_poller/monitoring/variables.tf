
variable "name" {
  type        = string
  description = "Poller name. Should be unique per datastream."
  default     = "Monitoring"
}

# tflint-ignore: terraform_unused_declarations
variable "description" {
  type        = string
  description = "Short description meant for other humans"
  default     = "GCP Poller for Google Cloud Monitoring"
}

variable "workspace" {
  type        = object({ oid = string })
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

variable "project" {
  type        = string
  description = "GCP Project ID"
}

variable "service_account_private_key_json" {
  sensitive   = true
  type        = string
  description = <<-EOF
    A GCP Service Account should include the following roles: Monitoring Viewer (roles/monitoring.viewer), 
    Cloud Asset Viewer (roles/cloudasset.viewer), and Browser (roles/browser).

    Please enter the entire JSON string of your service account.
    EOF
}

variable "interval_duration" {
  type        = string
  default     = "5m0s"
  description = <<-EOF
    How frequently to poll for metrics from Google Cloud Monitoring.  Minimum value is 1m0s.
  EOF
}

variable "include_metric_type_prefixes" {
  type = list(string)
  default = [
    "cloudfunctions.googleapis.com/",
    "cloudsql.googleapis.com/",
    "compute.googleapis.com/",
    "iam.googleapis.com/",
    "logging.googleapis.com/",
    "monitoring.googleapis.com/",
    "pubsub.googleapis.com/",
    "serviceruntime.googleapis.com/",
    "storage.googleapis.com/",
    "bigquery.googleapis.com/",
    "loadbalancing.googleapis.com",
    "kubernetes.io/",
    "redis.googleapis.com",
    "memcache.googleapis.com",
    "vpcaccess.googleapis.com"
  ]
  description = <<-EOF
    Metrics with these Metric Types with these prefixes will be fetched.
    
    See https://cloud.google.com/monitoring/api/metrics_gcp for a list of Metric Types.
  EOF
}

variable "exclude_metric_type_prefixes" {
  type        = list(string)
  default     = []
  description = <<-EOF
    Metrics with these Metric Types with these prefixes will not be fetched. This
    variable takes precendence over "metrics_poller_include_metric_type_prefixes".
    
    See https://cloud.google.com/monitoring/api/metrics_gcp for a list of Metric Types.
  EOF
}
