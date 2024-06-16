################################################################################
# Workspace
################################################################################

output "workspace_arn" {
  description = "The Amazon Resource Name (ARN) of the Grafana workspace"
  value       = coalesce(local.existing_workspace_arn, module.managed_grafana.workspace_arn)
}

output "workspace_id" {
  description = "The ID of the Grafana workspace"
  value       = coalesce(local.existing_workspace_id, module.managed_grafana.workspace_id)
}

output "workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = coalesce(local.existing_workspace_endpoint, module.managed_grafana.workspace_endpoint)
}

output "workspace_grafana_version" {
  description = "The version of Grafana running on the workspace"
  value       = coalesce(local.existing_workspace_grafana_version, module.managed_grafana.workspace_grafana_version)
}

################################################################################
# Workspace Network
################################################################################

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.managed_grafana.security_group_id
}