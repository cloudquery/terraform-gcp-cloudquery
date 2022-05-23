# CloudQuery GCP Module

This folder contains a Terraform module to deploy a CloudQuery cluster in GCP on top of GKE autopilot and Cloud SQL.

## Usage 

Examples are included in the example folder, but simple usage is as follows:

```hcl
module "cloudquery" {
  source = "cloudquery/gcp"
  version = "~> 0.5"
  name       = "cloudquery-complete-example"
  project_id = var.project_id

  config_file = "config.hcl"
}


### Run Helm Seperately

## Examples

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.21 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.21 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.11 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.21 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.5 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_network"></a> [gcp\_network](#module\_gcp\_network) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster | ~> 20.0 |
| <a name="module_gke_auth"></a> [gke\_auth](#module\_gke\_auth) | terraform-google-modules/kubernetes-engine/google//modules/auth | n/a |
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql) | GoogleCloudPlatform/sql-db/google//modules/postgresql | n/a |
| <a name="module_private_service_access"></a> [private\_service\_access](#module\_private\_service\_access) | GoogleCloudPlatform/sql-db/google//modules/private_service_access | n/a |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | n/a |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_binding.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_secret_manager_secret.cloudquery](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.cloudquery](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account_iam_binding.workload_identity_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [helm_release.cloudquery](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_string.pg_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_service_account.gke_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Variables to pass to the helm chart | `string` | `""` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of CloudQuery helm chart | `string` | `"0.2.1"` | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Path to the CloudQuery config.hcl | `string` | `""` | no |
| <a name="input_gke_version"></a> [gke\_version](#input\_gke\_version) | Version` of GKE to use for the GitLab cluster` | `string` | `"1.21"` | no |
| <a name="input_install_helm_chart"></a> [install\_helm\_chart](#input\_install\_helm\_chart) | Enable/Disable helm chart installation | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use on all resources created (VPC, RDS, etc) | `string` | `"cloudquery"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which resources will be provisioned. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"us-east1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Troubleshooting

If helm installtion is stuck in some hanging state you can run the following commands:

```bash
# check if helm is installed in cloudquery namespace
helm ls -n cloudquery
# If yes uninstall with the your release name
helm uninstall YOUR_RELEASE_NAME -n cloudquery
```

## Authors

[CloudQuery Team](https://github.com/cloudquery/cloudquery).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/cloudquery/terraform-gcp-cloudquery/tree/main/LICENSE) for full details.