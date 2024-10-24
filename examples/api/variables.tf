
variable "project" {
    type = string
    description = <<-EOF
    The project ID to create the service account in.  For project collection, this will also assign the IAM roles to the account in the project.
    EOF
}

variable "services" {
  description = "The list of APIs to enable for observe collection"
  type = set(string)
  default = [
    "cloudasset.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com",
    "cloudtasks.googleapis.com"
  ]
}