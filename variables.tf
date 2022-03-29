variable "prefix" {
  description = "Name prefix for the resources created by this modules"
  type        = string
  default     = "observe-collection"
}

variable "observe_customer" {
  description = "Observe Customer ID"
  type        = string
}

variable "observe_token" {
  description = "Observe Token"
  type        = string
}

variable "observe_domain" {
  description = "Observe Domain"
  type        = string
  default     = "observeinc.com"
}

variable "region" {
  description = "The Google Cloud region to deploy resources to"
  type        = string
}
