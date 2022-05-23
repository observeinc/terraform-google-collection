# Observe Google Collection

This module assembles different methods of collecting data from Google into Observe. It is intended as both a starting point and as a reference.

The module sets up the following forwarding methods:

- A Pub/Sub topic and pull-type Pub/Sub subscription (which the Observe poller, in a different module, can pull from)
- A Logging sink
- A Cloud Asset Feed
- A pair of Cloud Functions which periodical take snapshots of Cloud Asset resources


## Usage

```hcl
provider "google" {}

module "observe_gcp_collection" {
  source = "github.com/observeinc/terraform-google-collection"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.21 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_asset_project_feed.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_asset_project_feed) | resource |
| [google_cloud_scheduler_job.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloudfunctions_function.process_export](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function.start_export](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_logging_project_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_member.cloud_functions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.cloud_scheduler_cloud_function_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.sink_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.cloud_functions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.cloud_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.asset_inventory_export](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asset_content_types"></a> [asset\_content\_types](#input\_asset\_content\_types) | A list of types of Cloud Asset content types that will be exported to observe.<br><br>See https://cloud.google.com/asset-inventory/docs/reference/rest/v1p7beta1/TopLevel/exportAssets#ContentType for a description of possible content types.<br>Content type RELATIONSHIP is not supported. | `list(string)` | <pre>[<br>  "RESOURCE",<br>  "IAM_POLICY",<br>  "ORG_POLICY",<br>  "ACCESS_POLICY"<br>]</pre> | no |
| <a name="input_asset_names"></a> [asset\_names](#input\_asset\_names) | A list of full names of Cloud Asset assets that will be exported to Observe.<br><br>For example: //compute.googleapis.com/projects/my\_project\_123/zones/zone1/instances/instance1. See https://cloud.google.com/apis/design/resourceNames#fullResourceName for more info.<br><br>By default, all supported assets are fetched (https://cloud.google.com/asset-inventory/docs/supported-asset-types) | `list(string)` | `[]` | no |
| <a name="input_asset_types"></a> [asset\_types](#input\_asset\_types) | A list of types of Cloud Asset assets that will be exported to Observe.<br><br>For example: "compute.googleapis.com/Disk". See https://cloud.google.com/asset-inventory/docs/supported-asset-types for a list of all supported asset types.<br><br>By default, all supported assets are fetched (https://cloud.google.com/asset-inventory/docs/supported-asset-types) | `list(string)` | <pre>[<br>  ".*"<br>]</pre> | no |
| <a name="input_cloud_function_max_instances"></a> [cloud\_function\_max\_instances](#input\_cloud\_function\_max\_instances) | Max number of instances per Cloud Function (https://cloud.google.com/functions/docs/configuring/max-instances) | `number` | `5` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to add to resources (https://cloud.google.com/resource-manager/docs/creating-managing-labels)"<br><br>Note: Many, but not all, Google Cloud SDK resources support labels. | `map(string)` | `{}` | no |
| <a name="input_logging_exclusions"></a> [logging\_exclusions](#input\_logging\_exclusions) | Log entries that match any of these exclusion filters will not be exported.<br><br>If a log entry is matched by both logging\_filter and one of logging\_exclusions it will not be exported.<br><br>Relevant docs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/billingAccounts.exclusions#LogExclusion | <pre>list(object({<br>    name        = string<br>    description = string<br>    filter      = string<br>    disabled    = string<br>  }))</pre> | `[]` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | An advanced logs filter. The only exported log entries are those that are<br>in the resource owning the sink and that match the filter.<br><br>Relevant docs: https://cloud.google.com/logging/docs/view/building-queries | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Module name. Used as a name prefix. | `string` | `"observe-collection"` | no |
| <a name="input_pubsub_ack_deadline_seconds"></a> [pubsub\_ack\_deadline\_seconds](#input\_pubsub\_ack\_deadline\_seconds) | Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `number` | `60` | no |
| <a name="input_pubsub_maximum_backoff"></a> [pubsub\_maximum\_backoff](#input\_pubsub\_maximum\_backoff) | Retry policy maximum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"600s"` | no |
| <a name="input_pubsub_message_retention_duration"></a> [pubsub\_message\_retention\_duration](#input\_pubsub\_message\_retention\_duration) | Message retention for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"86400s"` | no |
| <a name="input_pubsub_minimum_backoff"></a> [pubsub\_minimum\_backoff](#input\_pubsub\_minimum\_backoff) | Retry policy minimum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"10s"` | no |
| <a name="input_storage_retention_in_days"></a> [storage\_retention\_in\_days](#input\_storage\_retention\_in\_days) | How long to retain files in the Cloud Storage bucket | `number` | `7` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | The ID of the Project in which resources were created |
| <a name="output_region"></a> [region](#output\_region) | The region in which resources were created |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | The Pub/Sub subscription created by this module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.