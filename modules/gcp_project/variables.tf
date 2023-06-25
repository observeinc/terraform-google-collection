variable "org_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "project_owner" {
  default = []
}

variable "project_editor" {
  default = []
}
