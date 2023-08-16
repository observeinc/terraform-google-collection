variable "project_collection_roles" {
  description = <<-EOF
    A list of IAM roles to give to the service account.  Note that permissions are broad and this account should only be used to set up collection intially and not for anything else.
  EOF
  type        = set(string)

  default = [
    "roles/browser",
    "roles/cloudasset.owner",
    "roles/cloudfunctions.admin",
    "roles/cloudscheduler.admin",
    "roles/cloudtasks.admin",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountDeleter",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/logging.admin",
    "roles/monitoring.admin",
    "roles/pubsub.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/servicemanagement.admin",
    "roles/storage.admin",
  ]
}

variable "folder_collection_roles" {
  description = <<-EOF
    A list of IAM roles to give to the service account for folder collection.  Note that permissions are broad and this account should only be used to set up collection intially and not for anything else.
  EOF
  type        = set(string)

  default = [
    "roles/browser",
    "roles/cloudasset.owner",
    "roles/cloudfunctions.admin",
    "roles/cloudscheduler.admin",
    "roles/cloudtasks.admin",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountDeleter",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/logging.admin",
    "roles/monitoring.admin",
    "roles/pubsub.admin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectDeleter",
    "roles/resourcemanager.projectMover",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/servicemanagement.admin",
    "roles/storage.admin",
  ]
}

variable "project" {
    type = string
    description = <<-EOF
    The project ID to create the service account in.  For project collection, this will also assign the IAM roles to the account in the project.
    EOF
}

variable "folder" {
    type = string
    description = <<-EOF
    The folder ID to grant the IAM roles to service account in.
    EOF
    default = null
}