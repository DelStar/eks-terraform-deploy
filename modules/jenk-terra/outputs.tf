# This file defines the outputs for the Terraform configuration.

# Public IP address of the Jenkins server
output "jenkins_server_ip" {
  value = aws_instance.jenkins_server.public_ip
}

# Public IP address of the Terraform node
output "terraform_node_ip" {
  value = aws_instance.terraform_node.public_ip
}
