# This file defines the input variables for the Terraform configuration.

# AWS region to deploy resources
variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

# Path to the public key for SSH access
variable "public_key_path" {
  description = "Path to the public key to use for SSH access"
  default     = "~/.ssh/id_rsa.pub"
}
