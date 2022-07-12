variable "name" {
  description = "Name to use on all resources created (VPC, RDS, etc)"
  type        = string
  default     = "cloudquery"
}

variable "project_id" {
  description = "The ID of the project in which resources will be provisioned."
  type        = string
}

variable "region" {
  type        = string
  description = "The region to host the cluster in (optional if zonal cluster / required if regional)"
  default     = "us-east1"
}

variable "zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster), by default will pick one of the zones in the region"
  default     = []
}

variable "gke_version" {
  type        = string
  description = "Version` of GKE to use for the GitLab cluster"
  default     = "1.21"
}

variable "machine_type" {
  type        = string
  description = "Machine type to use for the cluster"
  default     = "n2-highcpu-4"
}

variable "authorized_networks" {
  description = "If Cloud SQL accessible it is highly advised to specify allowed cidrs from where you are planning to connect"
  type        = list(map(string))
  default     = []
  # For public use
  # [{name = "public", value = "0.0.0.0/0"}]
}

# variable "tags" {
#   description = "A map of tags to use on all resources"
#   type        = map(string)
#   default     = {}
# }

# # Helm

variable "install_helm_chart" {
  description = "Enable/Disable helm chart installation"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "The version of CloudQuery helm chart"
  type        = string
  default     = "0.2.12" # Do not change CloudQuery helm chart version as it is automatically updated by Workflow
}

variable "config_file" {
  description = "Path to the CloudQuery config.hcl"
  type        = string
  default     = ""
}

variable "chart_values" {
  description = "Variables to pass to the helm chart"
  type        = string
  default     = ""
}

