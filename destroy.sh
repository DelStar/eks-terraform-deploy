#!/bin/bash
echo "Destroying the resources..."
echo "Please wait..."

cd users
terraform destroy -auto-approve
echo "IAM Users and Roles destoyed!"

cd ../eks-cluster
terraform destroy -auto-approve
echo "Cluster with the Autoscaler destroyed!"

cd ../vpc
terraform  destroy -auto-approve
echo "VPC destroyed!"

cd ../s3-bucket
terraform  destroy -auto-approve
echo "S3 Bucket with destroyed!"

echo "All destroying complete!"
echo "Thank you for using this script!"
