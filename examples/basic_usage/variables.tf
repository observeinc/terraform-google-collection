variable "name" {
  description = "The name of the observe collection"
  type        = string
}

variable "project_id" {
  description = "The project id to be observed"
  type        = string
}

variable "region" {
  type        = string
  description = "GCP region"
}
