#!/bin/bash
echo "DESTROYING THE RESOURCES..."
echo "PLEASE WAIT..."

cd modules/jenkins-terraform-servers
terraform destroy -auto-approve
echo "JENKINS SERVER AND TERRAFORM BUILD AGENT ARE DESTROYED!"