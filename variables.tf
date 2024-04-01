variable "resource_group_name" {
  description = "The resource group name"
  type        = string
}

variable "location" {
  description = "The Azure location"
  type        = string
}

variable "environment" {
  description = "Dev, Stage, or Prod"
  type        = string
}