# Observe Google Collection

This module creates a service account, log sink and pub/sub topic and subscription needed to facilitate the collection of asset inventory records, metrics and logs from GCP for a given project.

## Usage

```hcl
provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "YOUR_DEFAULT_REGION"
}

module "observe_gcp_collection" {
  source           = "observeinc/collection/google"
}

output "subscription" {
  description = "The Pub/Sub subscription created by this module."
  value       = module.observe_gcp_collection.subscription
}

output "service_account_private_key" {
  description = "A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring"
  value       = base64decode(module.observe_gcp_collection.service_account_key.private_key)
  sensitive   = true
}
```
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
| [google_logging_project_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_member.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.sink_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to add to resources (https://cloud.google.com/resource-manager/docs/creating-managing-labels)"<br><br>Note: Many, but not all, Google Cloud SDK resources support labels. | `map(string)` | `{}` | no |
| <a name="input_logging_exclusions"></a> [logging\_exclusions](#input\_logging\_exclusions) | Log entries that match any of these exclusion filters will not be exported.<br><br>If a log entry is matched by both logging\_filter and one of logging\_exclusions it will not be exported.<br><br>Relevant docs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/billingAccounts.exclusions#LogExclusion | <pre>list(object({<br>    name        = string<br>    description = string<br>    filter      = string<br>    disabled    = string<br>  }))</pre> | `[]` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | An advanced logs filter. The only exported log entries are those that are<br>in the resource owning the sink and that match the filter.<br><br>Relevant docs: https://cloud.google.com/logging/docs/view/building-queries | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Module name. Used as a name prefix. | `string` | `"observe-collection"` | no |
| <a name="input_pubsub_ack_deadline_seconds"></a> [pubsub\_ack\_deadline\_seconds](#input\_pubsub\_ack\_deadline\_seconds) | Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `number` | `60` | no |
| <a name="input_pubsub_maximum_backoff"></a> [pubsub\_maximum\_backoff](#input\_pubsub\_maximum\_backoff) | Retry policy maximum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"600s"` | no |
| <a name="input_pubsub_message_retention_duration"></a> [pubsub\_message\_retention\_duration](#input\_pubsub\_message\_retention\_duration) | Message retention for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"86400s"` | no |
| <a name="input_pubsub_minimum_backoff"></a> [pubsub\_minimum\_backoff](#input\_pubsub\_minimum\_backoff) | Retry policy minimum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"10s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | The ID of the Project in which resources were created |
| <a name="output_region"></a> [region](#output\_region) | The region in which resources were created |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | The Pub/Sub subscription created by this module. |
