variable "billing_account" {
  type = string
}

variable "org_id" {
  type        = string
  description = "Org ID from GCP console"
}

variable "folder_id" {
  type        = string
  description = "GCP folder id to deploy service project"
}


variable "project_id" {
  type        = string
  description = "GCP project used as a service/collection project"
}

variable "project_owners" {
  description = "Add the user emails of of the project owners"
  type        = list(string)
}