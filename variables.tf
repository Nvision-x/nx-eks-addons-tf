variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "namespace" {
  description = "Namespace where resources will be created"
  type        = string
  default     = "kube-system"
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "autoscaler_role_name" {
  description = "Name of IAM role for cluster autoscaler"
  type        = string
}

variable "autoscaler_service_account" {
  description = "Service account name for cluster autoscaler"
  type        = string
}

variable "lb_controller_role_name" {
  description = "Name of IAM role for load balancer controller"
  type        = string
}

variable "lb_controller_service_account" {
  description = "Service account name for load balancer controller"
  type        = string
}

variable "lb_controller_role_arn" {
  description = "IAM Role ARN for the AWS Load Balancer Controller"
  type        = string
}

variable "cluster_autoscaler_role_arn" {
  description = "IAM Role ARN for the Cluster Autoscaler"
  type        = string
}

variable "enable_irsa" {
  description = "Enable IRSA annotations on ServiceAccounts. Set to false for Pod Identity."
  type        = bool
  default     = false
}

variable "cluster_autoscaler_version" {
  description = "Version of the cluster autoscaler image"
  type        = string
  default     = "v1.26.2"
}

variable "autoscaler_replicas" {
  description = "Number of autoscaler replicas"
  type        = number
  default     = 1
}

variable "autoscaler_resources" {
  description = "Resource limits and requests for autoscaler"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "100m"
      memory = "600Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "600Mi"
    }
  }
}

variable "lb_controller_chart_version" {
  description = "AWS Load Balancer Controller Helm chart version. Requires 1.7.0+ for Pod Identity support."
  type        = string
  default     = "1.10.0"
}

variable "autoscaler_log_level" {
  description = "Log verbosity level for cluster autoscaler"
  type        = number
  default     = 4
  validation {
    condition     = var.autoscaler_log_level >= 0 && var.autoscaler_log_level <= 10
    error_message = "Log level must be between 0 and 10."
  }
}

variable "autoscaler_expander" {
  description = "Expander strategy for cluster autoscaler"
  type        = string
  default     = "least-waste"
  validation {
    condition     = contains(["least-waste", "random", "most-pods", "priority"], var.autoscaler_expander)
    error_message = "Invalid expander strategy. Must be one of: least-waste, random, most-pods, priority."
  }
}

variable "autoscaler_skip_nodes_with_local_storage" {
  description = "Skip nodes with local storage when deleting"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}




