# Full GCP Integration

This configuration documents a method for setting up infrastructure on Google,
the Observe pollers, and the Observe datasets.

### Usage

1. Copy the terraform config below into the relevant module. 
      - The config defines a Google provider, the Observe Google Collection module, and the Observe pollers.
      - These components combined enables collection of logs, metrics, and resource updates from Google Cloud.
1. In the Observe UI, Create the GCP data stream.
      - If your customer ID is 101, then you can create it in https://101.observeinc.com/settings/datastreams
      - If the name of your datastream is not "GCP", you will need to the observe_datastream data source in the terraform config.
1. Get an Observe access key.
      - Currently [this Observe FAQ answer](https://docs.observeinc.com/en/latest/content/common-topics/FAQ.html?highlight=access#how-do-i-create-an-access-token-that-can-do-more-than-just-ingest-data) works.
      - Note: the token here isn't an "ingest token" (that only allows ingest.) You want an authtoken.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.18.0 |
| <a name="requirement_observe"></a> [observe](#requirement\_observe) | >= 0.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_observe"></a> [observe](#provider\_observe) | >= 0.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_google"></a> [google](#module\_google) | github.com/observeinc/terraform-observe-google | main |
| <a name="module_observe_gcp_collection"></a> [observe\_gcp\_collection](#module\_observe\_gcp\_collection) | github.com/observeinc/terraform-google-collection | main |

## Resources

| Name | Type |
|------|------|
| observe_poller.gcp_metrics | resource |
| observe_poller.pubsub_poller | resource |
| observe_datastream.gcp | data source |
| observe_workspace.default | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_exclude_metric_type_prefixes"></a> [exclude\_metric\_type\_prefixes](#input\_exclude\_metric\_type\_prefixes) | GCP metric endpoints to ignore. This takes precedence over include\_metric\_type\_prefixes | `list(any)` | <pre>[<br>  "aws.googleapis.com/"<br>]</pre> | no |
| <a name="input_gcp_project"></a> [gcp\_project](#input\_gcp\_project) | GCP project | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | GCP region | `string` | n/a | yes |
| <a name="input_include_metric_type_prefixes"></a> [include\_metric\_type\_prefixes](#input\_include\_metric\_type\_prefixes) | GCP metric endpoints to pull data from | `list(any)` | <pre>[<br>  "logging.googleapis.com/",<br>  "iam.googleapis.com/",<br>  "monitoring.googleapis.com/",<br>  "pubsub.googleapis.com/",<br>  "storage.googleapis.com/"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name | `string` | n/a | yes |
| <a name="input_observe_customer"></a> [observe\_customer](#input\_observe\_customer) | Observe Customer ID | `string` | n/a | yes |
| <a name="input_observe_domain"></a> [observe\_domain](#input\_observe\_domain) | Observe Domain | `string` | `"observeinc.com"` | no |
| <a name="input_observe_services"></a> [observe\_services](#input\_observe\_services) | Map of services to create Observe datasets for.	See the services variable in https://github.com/observeinc/terraform-observe-google. | `map(bool)` | `{}` | no |
| <a name="input_observe_token"></a> [observe\_token](#input\_observe\_token) | Observe token | `string` | n/a | yes |
| <a name="input_observe_workspace"></a> [observe\_workspace](#input\_observe\_workspace) | Name of the workspace to create datasets for | `string` | `"Default"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
