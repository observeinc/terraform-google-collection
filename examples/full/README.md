# Full GCP Integration

This configuration documents a method for setting up infrastructure on Google for use by 
Observe pollers and the Observe datasets.

### Usage

1. Install gCloud CLI to create auth token for Terraform.
      - https://cloud.google.com/sdk/gcloud
      - run gcloud auth login https://cloud.google.com/sdk/gcloud/reference/auth/login
1. `terraform init`
1. `terraform apply`


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.18.0 |

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
| <a name="input_name"></a> [name](#input\_name) | Name | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_private_key"></a> [service\_account\_private\_key](#output\_service\_account\_private\_key) | A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | The Pub/Sub subscription created by this module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
