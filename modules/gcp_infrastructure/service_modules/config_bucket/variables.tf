variable "project_id" {
  type        = string
  description = "GCP project to deploy sample env"
}

# variable "region" {
#   type = string
#   description = "GCP region to deploy sample env"
# }

variable "name_format" {
  type        = string
  default     = "gcp-test-%s"
  description = "Name format"
}