# This file defines the input variables for the Terraform configuration.

# AWS region to deploy resources
variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

# The name of an existing key pair to use for SSH access
variable "my_key_pair" {
  description = "myKeyPair"
  type        = string
  default     = "myKeyPair"
}
