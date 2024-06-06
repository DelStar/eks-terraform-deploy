terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    profile        = "default"
    key            = "terraformstatefile"
    bucket         = "daleysphere-terraform-backend-bucket"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
  }
}
