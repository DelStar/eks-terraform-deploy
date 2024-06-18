# Define local variables
locals {
  create_workspace_flag = var.existing_workspace_id == "" ? true : false
}

# Conditional data source
data "aws_grafana_workspace" "existing" {
  count        = var.existing_workspace_id != "" ? 1 : 0
  workspace_id = var.existing_workspace_id
}

# Local variables to reference the data source conditionally
locals {
  existing_workspace                 = local.create_workspace_flag ? null : (length(data.aws_grafana_workspace.existing) > 0 ? data.aws_grafana_workspace.existing[0] : null)
  existing_workspace_arn             = local.create_workspace_flag ? null : (length(data.aws_grafana_workspace.existing) > 0 ? data.aws_grafana_workspace.existing[0].arn : null)
  existing_workspace_endpoint        = local.create_workspace_flag ? null : (length(data.aws_grafana_workspace.existing) > 0 ? data.aws_grafana_workspace.existing[0].endpoint : null)
  existing_workspace_grafana_version = local.create_workspace_flag ? null : (length(data.aws_grafana_workspace.existing) > 0 ? data.aws_grafana_workspace.existing[0].grafana_version : null)
  existing_workspace_id              = local.create_workspace_flag ? null : (length(data.aws_grafana_workspace.existing) > 0 ? data.aws_grafana_workspace.existing[0].id : null)
}



module "managed_grafana" {
  source = "terraform-aws-modules/managed-service-grafana/aws"

  # Workspace
  name                      = "eks-grafana"
  description               = "AWS Managed Grafana service"
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]

  create_workspace      = local.create_workspace_flag
  create_iam_role       = true
  create_security_group = true
  associate_license     = false
  license_type          = "ENTERPRISE_FREE_TRIAL"
  vpc_configuration = {
    subnet_ids = var.private_subnets
  }

  security_group_rules = {
    egress = {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  # Workspace API keys
  workspace_api_keys = {
    viewer = {
      key_name        = "viewer"
      key_role        = "VIEWER"
      seconds_to_live = 3600
    }
    editor = {
      key_name        = "editor"
      key_role        = "EDITOR"
      seconds_to_live = 3600
    }
    admin = {
      key_name        = "admin"
      key_role        = "ADMIN"
      seconds_to_live = 3600
    }
  }


  # Role associations
  role_associations = {
    "ADMIN" = {
      "group_ids" = [var.sso_admin_group_id]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = var.env_name
  }

}


# Validate existing workspace
resource "null_resource" "validate_grafana_workspace" {
  count = local.create_workspace_flag ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'Using existing Grafana workspace with ID: ${var.existing_workspace_id}'"
  }

