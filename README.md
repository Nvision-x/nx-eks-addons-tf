## 📦 nx-eks-addons-tf`

### 📄 `nx-eks-addons-tf/README.md`

# nx-eks-addons-tf

Terraform module to install Kubernetes add-ons on an existing Amazon EKS cluster. This includes:

- Cluster Autoscaler with IAM role and service account (IRSA)
- AWS Load Balancer Controller via Helm
- RBAC manifests for autoscaler

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14.0 |

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.0    |
| AWS CLI   | >= 2.0    |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.6.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

| Name     | Source              |
|----------|---------------------|
| aws      | hashicorp/aws       |
| helm     | hashicorp/helm      |
| kubectl  | gavinbunney/kubectl |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.cluster_role](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.cluster_role_binding](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.deployment](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.role](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.role_binding](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.service_account](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [null_resource.patch_gp2_storageclass](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaler_role_name"></a> [autoscaler\_role\_name](#input\_autoscaler\_role\_name) | Name of IAM role for cluster autoscaler | `string` | n/a | yes |
| <a name="input_autoscaler_service_account"></a> [autoscaler\_service\_account](#input\_autoscaler\_service\_account) | Service account name for cluster autoscaler | `string` | n/a | yes |
| <a name="input_cluster_autoscaler_role_arn"></a> [cluster\_autoscaler\_role\_arn](#input\_cluster\_autoscaler\_role\_arn) | IAM Role ARN for the Cluster Autoscaler | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster Name | `string` | n/a | yes |
| <a name="input_lb_controller_role_arn"></a> [lb\_controller\_role\_arn](#input\_lb\_controller\_role\_arn) | IAM Role ARN for the AWS Load Balancer Controller | `string` | n/a | yes |
| <a name="input_lb_controller_role_name"></a> [lb\_controller\_role\_name](#input\_lb\_controller\_role\_name) | Name of IAM role for load balancer controller | `string` | n/a | yes |
| <a name="input_lb_controller_service_account"></a> [lb\_controller\_service\_account](#input\_lb\_controller\_service\_account) | Service account name for load balancer controller | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where resources will be created | `string` | `"kube-system"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

No outputs.
