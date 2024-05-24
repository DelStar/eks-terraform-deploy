#!/bin/bash
# To create Jenkins server and Terraform build agent server

cd modules/jenkins-terraform-servers || exit
terraform init
terraform fmt
terraform validate && terraform plan >s3_plan.hcl

if [ "$?" -eq "0" ]; then
  echo "Your code has been successfully validated"
  echo "You can view the plan file in JT_plan.hcl"
  sleep 2
else
  echo "The code needs some review!"
  exit
fi
terraform apply -auto-approve