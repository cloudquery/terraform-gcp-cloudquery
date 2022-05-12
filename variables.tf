variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "name" {
  description = "Name to use on all resources created"
  type        = string
  default     = "cloudquery"
}

variable "labels" {
  description = "A map of labels to use on all resources"
  type        = map(string)
  default     = {}
}

// DB
variable "db_name" {
  description = "Name to database"
  type        = string
  default     = "cloudquery"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "cloudquery"
}

variable "postgres_major_engine_version" {
  description = "Major version of Google Cloud SQL Postgres engine to use"
  type        = string
  default     = "13"
}

variable "postgres_instance_tier" {
  description = "Postgresql instance tier"
  type        = string
  default     = "db-custom-1-3840"
}

variable "authorized_networks" {
  default = [{
    name  = "sample-gcp-health-checkers-range"
    value = "130.211.0.0/28"
  }]
  type        = list(map(string))
  description = "List of mapped public networks authorized to access to the instances. Default - short range of GCP health-checkers IPs"
}

// Helm
variable "config_file" {
  description = "Path to the CloudQuery config.hcl"
  type        = string
}

variable "chart_version" {
  description = "The version of CloudQuery helm chart"
  type        = string
  default     = "0.1.10"
}

variable "chart_values" {
  description = "Variables to pass to the helm chart"
  type        = string
  default     = ""
}

variable "install_helm_chart" {
  description = "Enable/Disable helm chart installation"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for CloudQuery resources"
  type        = string
  default     = "cloudquery"
}