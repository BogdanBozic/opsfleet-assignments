## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.instance_state_change](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.rebalance_recommendation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.scheduled_change](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.spot_interruption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.instance_state_change_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.rebalance_recommendation_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.scheduled_change_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.spot_interruption_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.karpenter_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.karpenter_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.karpenter_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.karpenter_interruption_handler_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.karpenter_ec2nodeclass](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.karpenter_nodepool_amd64](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.karpenter_nodepool_arm64](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_iam_policy_document.interruption_handler_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amd_ami_id"></a> [amd\_ami\_id](#input\_amd\_ami\_id) | Pinned Bottlerocket AMI ID for amd64 (x86\_64) worker nodes. | `string` | n/a | yes |
| <a name="input_arm_ami_id"></a> [arm\_ami\_id](#input\_arm\_ami\_id) | Pinned Bottlerocket AMI ID for arm64 (Graviton) worker nodes. | `string` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | List of availability zones in which Karpenter is allowed to provision EC2 instances. | `list(string)` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | EKS cluster metadata including name, endpoint, and Kubernetes version. | `any` | n/a | yes |
| <a name="input_karpenter_helm_version"></a> [karpenter\_helm\_version](#input\_karpenter\_helm\_version) | Version of the Karpenter Helm chart to deploy into the EKS cluster. | `string` | n/a | yes |
| <a name="input_node_pod_execution_profile"></a> [node\_pod\_execution\_profile](#input\_node\_pod\_execution\_profile) | IAM instance profile used by Karpenter-managed EC2 nodes. | <pre>object({<br/>    arn  = string<br/>    name = string<br/>  })</pre> | n/a | yes |
| <a name="input_node_pod_execution_role"></a> [node\_pod\_execution\_role](#input\_node\_pod\_execution\_role) | IAM role assumed by Karpenter-managed worker nodes for accessing AWS services. | <pre>object({<br/>    arn  = string<br/>    name = string<br/>  })</pre> | n/a | yes |
| <a name="input_oidc_provider"></a> [oidc\_provider](#input\_oidc\_provider) | OIDC provider configuration for the EKS cluster, used by Karpenter and other components for IAM roles for service accounts (IRSA). | <pre>object({<br/>    arn = string<br/>    url = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags applied to all AWS resources created by this module. | `map(string)` | n/a | yes |

## Outputs

No outputs.
