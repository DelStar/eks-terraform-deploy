terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    profile        = "default"
    key            = "terraformstatefile"
    bucket         = "daleystream"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
  }
}
