# This file defines the outputs for the Terraform configuration.

# Public IP address of the Sonarqube-Maven build agent server
output "sonar_maven_server_ip" {
  value = aws_instance.sonar_maven_server.public_ip
}