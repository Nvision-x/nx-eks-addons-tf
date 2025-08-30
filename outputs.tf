output "cluster_autoscaler_deployment" {
  description = "Cluster autoscaler deployment name"
  value       = "cluster-autoscaler"
}

output "cluster_autoscaler_namespace" {
  description = "Namespace where cluster autoscaler is deployed"
  value       = var.namespace
}

output "cluster_autoscaler_service_account" {
  description = "Service account name for cluster autoscaler"
  value       = var.autoscaler_service_account
}

output "load_balancer_controller_release" {
  description = "Helm release name for AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.name
}

output "load_balancer_controller_namespace" {
  description = "Namespace where AWS Load Balancer Controller is deployed"
  value       = helm_release.aws_load_balancer_controller.namespace
}

output "load_balancer_controller_version" {
  description = "Version of AWS Load Balancer Controller Helm chart"
  value       = helm_release.aws_load_balancer_controller.version
}