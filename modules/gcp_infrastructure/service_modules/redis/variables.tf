variable "project_id" {
  type        = string
  description = "GCP project to deploy to"
}

variable "region" {
  type        = string
  description = "GCP region to deploy to"
}

variable "zone1" {
  type        = string
  description = "GCP primary zone to deploy to"
}

variable "zone2" {
  type        = string
  description = "GCP alt zone to deploy to"
}

variable "name_format" {
  type        = string
  default     = "gcp-test-%s"
  description = "prefix for resources"
}
