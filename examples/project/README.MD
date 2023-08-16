<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.21 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_observe_gcp_collection"></a> [observe\_gcp\_collection](#module\_observe\_gcp\_collection) | observeinc/collection/google | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the Observe collection | `string` | `"observe"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to host resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where resources will be created | `string` | `"us-central1"` | no |
| <a name="input_resource"></a> [resource](#input\_resource) | The identifier of the GCP Resource to monitor. The resource can be a project, folder, or organization. Examples: 'projects/my\_project-123', 'folders/1234567899', 'organizations/34739118321' | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_private_key"></a> [service\_account\_private\_key](#output\_service\_account\_private\_key) | A service account key sent to the pollers for Pub/Sub and Cloud Monitoring |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | The Pub/Sub subscription created by this module. |
<!-- END_TF_DOCS -->