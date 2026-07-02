variable "project_id" {
  description = "GCP Project ID (globally unique)"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name (Dev, Stage, Prod)"
  type        = string
  default     = "dev"
}
