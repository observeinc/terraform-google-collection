variable "services_to_enable" {
  description = "List of Google API Services to enable"
  type        = list(string)
}

variable "project_id" {
  type        = string
  description = "GCP project_id"
}