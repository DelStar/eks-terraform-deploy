################################################################################
# General Variables from root module
################################################################################
variable "main-region" {
  type = string
}

variable "env_name" {
  type = string
}

################################################################################
# EKS Cluster Variables
################################################################################


################################################################################
# VPC Variables
################################################################################
variable "private_subnets" {
  description = "Private subnets to create grafana workspace"
  type        = list(string)
}


################################################################################
# Variables from other Modules
################################################################################

variable "sso_admin_group_id" {
  description = "AWS_SSO Admin Group ID"
  type        = string
}

# Variables for existing workspace ID
variable "existing_workspace_id" {
  description = "The ID of an existing Grafana workspace, if any."
  type        = string
  default     = ""
}
