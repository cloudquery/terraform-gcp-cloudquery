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

variable "publicly_accessible" {
  description = "Make Cloud SQL publicly accessible (might be needed if you want to connect to it from Grafana, Preset or other tools)."
  type        = bool
  default     = false
}

variable "authorized_networks" {
  description = "If Cloud SQL accessible it is highly advised to specify allowed cidrs from where you are planning to connect"
  type        = list(map(string))
  default     = []
  // For public use
  // [{name = "public", value = "0.0.0.0/0"}]
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
  default     = "0.2.6"
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


# # VPC
# variable "vpc_id" {
#   description = "ID of an existing VPC where resources will be created"
#   type        = string
#   default     = null
# }

# variable "public_subnet_ids" {
#   description = "A list of IDs of existing public subnets inside the VPC"
#   type        = list(string)
#   default     = []
# }

# variable "database_subnet_group" {
#   description = "If vpc_id is specified, path the subnet_group name where the RDS should reside"
#   type        = string
#   default     = ""
# }


# # EKS
# # role_policy_arns
# variable "role_policy_arns" {
#   description = "Policies for the role to use for the EKS service account"
#   type        = list(string)
#   default = [
#     "arn:aws:iam::aws:policy/ReadOnlyAccess"
#   ]
# }