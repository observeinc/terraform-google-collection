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

variable "project_owners" {
  type    = list(string)
  default = []
}

variable "project_editors" {
  type    = list(string)
  default = []
}
