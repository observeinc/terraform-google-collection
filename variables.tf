variable "name" {
  type        = string
  description = "Module name. Used as a name prefix."
  default     = "obs"

  validation {
    condition     = length(var.name) <= 20
    error_message = "The name must be less than 20 characters long."
  }
}

variable "resource" {
  description = <<-EOF
    The identifier of the GCP Resource to monitor.

    The resource can be a project, folder, or organization.

    Examples: "projects/my_project-123", "folders/1234567899", "organizations/34739118321"
  EOF
  type        = string


  validation {
    condition     = length(split("/", var.resource)) == 2
    error_message = "The resource value must be formatted as <type>/<id>."
  }

  validation {
    condition     = contains(["projects", "folders", "organizations"], split("/", var.resource)[0])
    error_message = "The resource should have prefix 'projects/', 'folders/' or 'organizations/'."
  }
}

variable "labels" {
  description = <<-EOF
    A map of labels to add to resources (https://cloud.google.com/resource-manager/docs/creating-managing-labels)"

    Note: Many, but not all, Google Cloud SDK resources support labels.
  EOF
  type        = map(string)
  default     = {}
}

variable "pubsub_ack_deadline_seconds" {
  description = "Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = number
  default     = 60
}

variable "logging_filter" {
  description = <<-EOF
    An advanced logs filter. The only exported log entries are those that are
    in the resource owning the sink and that match the filter.

    Relevant docs: https://cloud.google.com/logging/docs/view/building-queries
  EOF
  type        = string
  default     = ""
}

variable "logging_exclusions" {
  description = <<-EOF
    Log entries that match any of these exclusion filters will not be exported.

    If a log entry is matched by both logging_filter and one of logging_exclusions it will not be exported.

    Relevant docs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/billingAccounts.exclusions#LogExclusion
  EOF
  type = list(object({
    name        = string
    description = string
    filter      = string
    disabled    = string
  }))
  default = []
}

variable "pubsub_message_retention_duration" {
  description = "Message retention for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = string
  default     = "86400s"
}

variable "pubsub_minimum_backoff" {
  description = "Retry policy minimum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = string
  default     = "10s"
}

variable "pubsub_maximum_backoff" {
  description = "Retry policy maximum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions)"
  type        = string
  default     = "600s"
}

variable "function_roles" {
  description = <<-EOF
    A list of IAM roles to give the Cloud Function.
  EOF
  type        = set(string)

  default = [
    "roles/compute.viewer",
    "roles/iam.serviceAccountViewer",
    "roles/cloudscheduler.viewer",
    "roles/cloudasset.viewer",
    "roles/browser",
    "roles/logging.viewer",
    "roles/monitoring.viewer",
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
    "roles/storage.objectAdmin",
    "roles/storage.admin",
    "roles/cloudfunctions.invoker",
    "roles/cloudtasks.enqueuer",
    "roles/cloudtasks.viewer",
    "roles/cloudtasks.taskDeleter",
    "roles/iam.serviceAccountUser"
  ]
}

variable "enable_function" {
  description = "Whether to enable the Cloud function"
  type        = bool
  default     = true
}

variable "folder_include_children" {
  description = "Whether to include all children Projects of a Folder when collecting logs"
  type        = bool
  default     = true
}

variable "function_bucket" {
  description = "GCS bucket containing the Cloud Function source code"
  type        = string
  default     = "observeinc"
}

variable "function_object" {
  description = "GCS object key of the Cloud Function source code zip file"
  type        = string
  default     = "google-cloud-functions-latest.zip"
}

variable "function_available_memory_mb" {
  description = "Memory (in MB), available to the function. Default value is 512. Possible values include 128, 256, 512, 1024, etc."
  type        = number
  default     = 4096
}

variable "function_timeout" {
  description = <<-EOF
    Timeout (in seconds) for the function. Default value is 300 seconds. Cannot be more than 540 seconds.
  EOF
  type        = number
  default     = 300
}

variable "function_max_instances" {
  description = "The limit on the maximum number of function instances that may coexist at a given time."
  type        = number
  default     = 100
}

variable "function_disable_logging" {
  description = "Whether to disable function logging."
  type        = bool
  default     = false
}

variable "function_schedule_frequency" {
  description = "Cron schedule for the job"
  type        = string
  default     = "0 * * * *"
}

variable "function_schedule_frequency_rest_of_assets" {
  description = "Cron schedule for the job"
  type        = string
  default     = "*/5 * * * *"
}


variable "poller_roles" {
  description = <<-EOF
    A list of IAM roles to give the Observe poller (through the service account key output).
  EOF
  type        = set(string)

  default = [
    "roles/monitoring.viewer",
  ]
}

variable "project_id" {
  description = "Billing Project ID needed for asset feed."
  type        = string
  default     = null
}

variable "gcp_region" {
  description = "The location where the Task Queue will be created."
  type        = string
  default     = "us-central1"
}

variable "max_concurrent_dispatches" {
  description = "The maximum number of tasks that can be dispatched concurrently."
  type        = number
  default     = 2
}

variable "max_dispatches_per_second" {
  description = "The maximum rate at which tasks can be dispatched per second."
  type        = number
  default     = 2
}

variable "max_retry_duration" {
  description = "The time limit for retrying a task in seconds"
  type        = string
  default     = "7200s"
}

variable "min_backoff" {
  description = "The minimum amount of time to wait between retries in seconds"
  type        = string
  default     = "30s"
}

variable "max_attempts" {
  description = "The maximum number of retry attempts for a task in case of failure."
  type        = number
  default     = -1
}

variable "cloud_function_debug_level" {
  description = "The debug level for the GCP cloud functions"
  type        = string
  default     = "WARNING"
}