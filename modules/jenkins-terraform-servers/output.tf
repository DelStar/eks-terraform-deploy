# This file defines the outputs for the Terraform configuration.

# Public IP address of the Jenkins server
output "jenkins_server_ip" {
  value = aws_instance.jenkins_server.public_ip
}

# Public IP address of the Terraform build agent
output "terraform_build_agent_ip" {
  value = aws_instance.terraform_build_agent.public_ip
}
