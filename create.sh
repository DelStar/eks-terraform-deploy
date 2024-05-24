#!/bin/bash
# To create s3 bucket and IAM role with permissions and policies

cd s3-bucket || exit
terraform init
terraform fmt
terraform validate && terraform plan >s3_plan.hcl

if [ "$?" -eq "0" ]; then
  echo "Your code has been successfully validated"
  echo "You can view the plan file in s3_plan.hcl"
  sleep 2
else
  echo "The code needs some review!"
  exit
fi
terraform apply -auto-approve

# Change directory to vpc
cd ../vpc || exit

# Create the vpc 
terraform init
terraform fmt
terraform validate && terraform plan >vpc_plan.hcl

if [ "$?" -eq "0" ]; then
  echo "The code has been successfully validated"
  echo "You can review the plan file in vpc_plan.hcl"
  sleep 2
else
  echo "The code needs some review!"
  exit
fi
terraform apply -auto-approve

echo "VPC is successfully created"

# Change directory to eks-cluster
cd ../eks-cluster || exit

# Create the eks cluster along with Cluster Autoscaler
terraform init
terraform fmt
terraform validate && terraform plan >eks-cluster_plan.hcl

if [ "$?" -eq "0" ]; then
  echo "The code has been successfully validated"
  echo "You can review the plan file in cluster_plan.hcl"
  sleep 2
else
  echo "The code needs some review!"
  exit
fi
terraform apply -auto-approve

# Change directory to users
cd ../users || exit

# Create IAM Users and Roles along with their policies
terraform init
terraform fmt
terraform validate && terraform plan >users_plan.hcl

if [ "$?" -eq "0" ]; then
  echo "The code has been successfully validated"
  echo "You can review the plan file in users_plan.hcl"
  sleep 2
else
  echo "The code needs some review!"
  exit
fi
terraform apply -auto-approve
echo "IAM and RBAC Users with policies created successfully"

exit
