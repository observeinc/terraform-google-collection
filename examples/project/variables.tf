variable "name" {
  description = "Name for the Observe collection"
  type        = string
  default     = "observe"
}

variable "resource" {
  description = "The identifier of the GCP Resource to monitor. The resource can be a project, folder, or organization. Examples: 'projects/my_project-123', 'folders/1234567899', 'organizations/34739118321'"
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

variable "project_id" {
  description = "The project ID to host resources"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "us-central1"
}
