# Observe Google Collection

This module creates a log sink, pub/sub topic, and pub/sub subscription needed to
facilitate the collection of asset inventory records, metrics and logs from GCP for a
given project.

This module also creates a Cloud Function to fetch some data through the GCP REST API.

## Usage

Here is an example manifest for collecting data from a Google Cloud organization.

After running `terraform apply`, data should start flowing into Pub/Sub. In the Observe
UI, one would set up the GCP app. The info from the `terraform output` and `terraform output -raw service_account_private_key` are needed to set up the GCP App pollers.

```hcl
provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "YOUR_DEFAULT_REGION"
}

module "observe_gcp_collection" {
  source  = "observeinc/collection/google"
  name    = "observe"

  resource = "projects/YOUR_PROJECT_ID"
}

output "project" {
  description = "The Pub/Sub project of the subcription (to be passed to the Pub/Sub poller)"
  value       = module.observe_gcp_collection.project
}

# To extract correct value - terraform output -json | jq -r '.subscription.value.name' 
output "subscription" {
  description = "The Pub/Sub subscription created by this module (to be passed to the Pub/Sub poller)"
  value       = module.observe_gcp_collection.subscription
}

# To extract properly formatted string - terraform output -json | jq -r '.service_account_private_key.value'
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
| <a name="provider_google"></a> [google](#provider\_google) | 4.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_scheduler_job.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloudfunctions_function.gcs_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function_iam_member.cloud_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function_iam_member) | resource |
| [google_folder_iam_member.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_logging_folder_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_folder_sink) | resource |
| [google_logging_organization_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_logging_project_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_organization_iam_member.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_member.poller_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.cloudfunction_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_pubsub_topic_iam_member.sink_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.cloud_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.bucket_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.gcs_function_bucket_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_folder.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_function"></a> [enable\_function](#input\_enable\_function) | Whether to enable the Cloud function | `bool` | `true` | no |
| <a name="input_folder_include_children"></a> [folder\_include\_children](#input\_folder\_include\_children) | Whether to include all children Projects of a Folder when collecting logs | `bool` | `true` | no |
| <a name="input_function_available_memory_mb"></a> [function\_available\_memory\_mb](#input\_function\_available\_memory\_mb) | Memory (in MB), available to the function. Default value is 512. Possible values include 128, 256, 512, 1024, etc. | `number` | `512` | no |
| <a name="input_function_bucket"></a> [function\_bucket](#input\_function\_bucket) | GCS bucket containing the Cloud Function source code | `string` | `"observeinc"` | no |
| <a name="input_function_disable_logging"></a> [function\_disable\_logging](#input\_function\_disable\_logging) | Whether to disable function logging. | `bool` | `false` | no |
| <a name="input_function_max_instances"></a> [function\_max\_instances](#input\_function\_max\_instances) | The limit on the maximum number of function instances that may coexist at a given time. | `number` | `5` | no |
| <a name="input_function_object"></a> [function\_object](#input\_function\_object) | GCS object key of the Cloud Function source code zip file | `string` | `"google-cloud-functions-v0.3.0-alpha.8.zip"` | no |
| <a name="input_function_roles"></a> [function\_roles](#input\_function\_roles) | A list of IAM roles to give the Cloud Function. | `set(string)` | <pre>[<br>  "roles/compute.viewer",<br>  "roles/iam.serviceAccountViewer",<br>  "roles/cloudscheduler.viewer",<br>  "roles/cloudasset.viewer",<br>  "roles/browser",<br>  "roles/logging.viewer",<br>  "roles/monitoring.viewer",<br>  "roles/storage.objectCreator",<br>  "roles/storage.objectViewer",<br>  "roles/storage.objectAdmin",<br>  "roles/storage.admin"<br>]</pre> | no |
| <a name="input_function_schedule_frequency"></a> [function\_schedule\_frequency](#input\_function\_schedule\_frequency) | Cron schedule for the job | `string` | `"0 * * * *"` | no |
| <a name="input_function_timeout"></a> [function\_timeout](#input\_function\_timeout) | Timeout (in seconds) for the function. Default value is 300 seconds. Cannot be more than 540 seconds. | `number` | `300` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to add to resources (https://cloud.google.com/resource-manager/docs/creating-managing-labels)"<br><br>Note: Many, but not all, Google Cloud SDK resources support labels. | `map(string)` | `{}` | no |
| <a name="input_logging_exclusions"></a> [logging\_exclusions](#input\_logging\_exclusions) | Log entries that match any of these exclusion filters will not be exported.<br><br>If a log entry is matched by both logging\_filter and one of logging\_exclusions it will not be exported.<br><br>Relevant docs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/billingAccounts.exclusions#LogExclusion | <pre>list(object({<br>    name        = string<br>    description = string<br>    filter      = string<br>    disabled    = string<br>  }))</pre> | `[]` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | An advanced logs filter. The only exported log entries are those that are<br>in the resource owning the sink and that match the filter.<br><br>Relevant docs: https://cloud.google.com/logging/docs/view/building-queries | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Module name. Used as a name prefix. | `string` | `"observe-collection"` | no |
| <a name="input_poller_roles"></a> [poller\_roles](#input\_poller\_roles) | A list of IAM roles to give the Observe poller (through the service account key output). | `set(string)` | <pre>[<br>  "roles/monitoring.viewer"<br>]</pre> | no |
| <a name="input_pubsub_ack_deadline_seconds"></a> [pubsub\_ack\_deadline\_seconds](#input\_pubsub\_ack\_deadline\_seconds) | Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `number` | `60` | no |
| <a name="input_pubsub_maximum_backoff"></a> [pubsub\_maximum\_backoff](#input\_pubsub\_maximum\_backoff) | Retry policy maximum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"600s"` | no |
| <a name="input_pubsub_message_retention_duration"></a> [pubsub\_message\_retention\_duration](#input\_pubsub\_message\_retention\_duration) | Message retention for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"86400s"` | no |
| <a name="input_pubsub_minimum_backoff"></a> [pubsub\_minimum\_backoff](#input\_pubsub\_minimum\_backoff) | Retry policy minimum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"10s"` | no |
| <a name="input_resource"></a> [resource](#input\_resource) | The identifier of the GCP Resource to monitor.<br><br>The resource can be a project, folder, or organization.<br><br>Examples: "projects/my\_project-123", "folders/1234567899", "organizations/34739118321" | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | The ID of the Project in which resources were created |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | The Pub/Sub subscription created by this module. |
| <a name="output_topic"></a> [topic](#output\_topic) | The Pub/Sub topic created by this module. |
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.21 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.15 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.15 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_asset_folder_feed.folder_feed](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_asset_folder_feed) | resource |
| [google_cloud_asset_project_feed.project_feed](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_asset_project_feed) | resource |
| [google_cloud_scheduler_job.rest_of_assets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloud_scheduler_job.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloud_tasks_queue.task_queue](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_tasks_queue) | resource |
| [google_cloudfunctions_function.gcs_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function.rest_of_assets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_cloudfunctions_function_iam_member.cloud_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function_iam_member) | resource |
| [google_cloudfunctions_function_iam_member.cloud_scheduler_rest_of_assets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function_iam_member) | resource |
| [google_folder_iam_member.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_logging_folder_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_folder_sink) | resource |
| [google_logging_organization_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_logging_project_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_organization_iam_member.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_member.poller_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.cloudfunction_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_pubsub_topic_iam_member.sink_pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.cloud_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.cloudfunction](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.poller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.bucket_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.gcs_function_bucket_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [random_id.cloudtasks_queue](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_folder.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_lifecycle_abort_upload_days"></a> [bucket\_lifecycle\_abort\_upload\_days](#input\_bucket\_lifecycle\_abort\_upload\_days) | The number of days to wait before deleting AbortIncompleteMultipartUpload. | `number` | `7` | no |
| <a name="input_bucket_lifecycle_delete_days"></a> [bucket\_lifecycle\_delete\_days](#input\_bucket\_lifecycle\_delete\_days) | The number of days to wait before Delete of temporary bucket files. | `number` | `14` | no |
| <a name="input_cloud_function_debug_level"></a> [cloud\_function\_debug\_level](#input\_cloud\_function\_debug\_level) | The debug level for the GCP cloud functions | `string` | `"WARNING"` | no |
| <a name="input_enable_asset_tracking"></a> [enable\_asset\_tracking](#input\_enable\_asset\_tracking) | Whether to enable the Cloud function that tracks GCP assets. | `bool` | `true` | no |
| <a name="input_enable_function"></a> [enable\_function](#input\_enable\_function) | DEPRECATED: This variable has been renamed to 'enable\_asset\_tracking'. Please update your configuration to use 'enable\_asset\_tracking' instead. | `bool` | `null` | no |
| <a name="input_folder_include_children"></a> [folder\_include\_children](#input\_folder\_include\_children) | Whether to include all children Projects of a Folder when collecting logs | `bool` | `true` | no |
| <a name="input_function_available_memory_mb"></a> [function\_available\_memory\_mb](#input\_function\_available\_memory\_mb) | Memory (in MB), available to the function. Default value is 512. Possible values include 128, 256, 512, 1024, etc. | `number` | `4096` | no |
| <a name="input_function_bucket"></a> [function\_bucket](#input\_function\_bucket) | GCS bucket containing the Cloud Function source code | `string` | `"observeinc"` | no |
| <a name="input_function_disable_logging"></a> [function\_disable\_logging](#input\_function\_disable\_logging) | Whether to disable function logging. | `bool` | `false` | no |
| <a name="input_function_max_instances"></a> [function\_max\_instances](#input\_function\_max\_instances) | The limit on the maximum number of function instances that may coexist at a given time. | `number` | `100` | no |
| <a name="input_function_object"></a> [function\_object](#input\_function\_object) | GCS object key of the Cloud Function source code zip file. Will use the latest release unless modified. | `string` | `"google-cloud-functions-latest.zip"` | no |
| <a name="input_function_roles"></a> [function\_roles](#input\_function\_roles) | A list of IAM roles to give the Cloud Function. | `set(string)` | <pre>[<br/>  "roles/compute.viewer",<br/>  "roles/iam.serviceAccountViewer",<br/>  "roles/cloudscheduler.viewer",<br/>  "roles/cloudasset.viewer",<br/>  "roles/browser",<br/>  "roles/logging.viewer",<br/>  "roles/monitoring.viewer",<br/>  "roles/storage.objectCreator",<br/>  "roles/storage.objectViewer",<br/>  "roles/storage.objectAdmin",<br/>  "roles/storage.admin",<br/>  "roles/cloudfunctions.invoker",<br/>  "roles/cloudtasks.enqueuer",<br/>  "roles/cloudtasks.viewer",<br/>  "roles/cloudtasks.taskDeleter",<br/>  "roles/iam.serviceAccountUser"<br/>]</pre> | no |
| <a name="input_function_schedule_frequency"></a> [function\_schedule\_frequency](#input\_function\_schedule\_frequency) | Cron schedule for the job | `string` | `"0 * * * *"` | no |
| <a name="input_function_schedule_frequency_rest_of_assets"></a> [function\_schedule\_frequency\_rest\_of\_assets](#input\_function\_schedule\_frequency\_rest\_of\_assets) | Cron schedule for the job | `string` | `"*/5 * * * *"` | no |
| <a name="input_function_timeout"></a> [function\_timeout](#input\_function\_timeout) | Timeout (in seconds) for the function. Default value is 300 seconds. Cannot be more than 540 seconds. | `number` | `300` | no |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The location where the Task Queue will be created. | `string` | `"us-central1"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels to add to resources (https://cloud.google.com/resource-manager/docs/creating-managing-labels)"<br/><br/>Note: Many, but not all, Google Cloud SDK resources support labels. | `map(string)` | `{}` | no |
| <a name="input_logging_exclusions"></a> [logging\_exclusions](#input\_logging\_exclusions) | Log entries that match any of these exclusion filters will not be exported.<br/><br/>If a log entry is matched by both logging\_filter and one of logging\_exclusions it will not be exported.<br/><br/>Relevant docs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/billingAccounts.exclusions#LogExclusion | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>    filter      = string<br/>    disabled    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | An advanced logs filter. The only exported log entries are those that are<br/>in the resource owning the sink and that match the filter.<br/><br/>Relevant docs: https://cloud.google.com/logging/docs/view/building-queries | `string` | `""` | no |
| <a name="input_max_attempts"></a> [max\_attempts](#input\_max\_attempts) | The maximum number of retry attempts for a task in case of failure. | `number` | `-1` | no |
| <a name="input_max_concurrent_dispatches"></a> [max\_concurrent\_dispatches](#input\_max\_concurrent\_dispatches) | The maximum number of tasks that can be dispatched concurrently. | `number` | `2` | no |
| <a name="input_max_dispatches_per_second"></a> [max\_dispatches\_per\_second](#input\_max\_dispatches\_per\_second) | The maximum rate at which tasks can be dispatched per second. | `number` | `2` | no |
| <a name="input_max_retry_duration"></a> [max\_retry\_duration](#input\_max\_retry\_duration) | The time limit for retrying a task in seconds | `string` | `"7200s"` | no |
| <a name="input_min_backoff"></a> [min\_backoff](#input\_min\_backoff) | The minimum amount of time to wait between retries in seconds | `string` | `"30s"` | no |
| <a name="input_name"></a> [name](#input\_name) | Module name. Used as a name prefix. | `string` | `"obs"` | no |
| <a name="input_poller_roles"></a> [poller\_roles](#input\_poller\_roles) | A list of IAM roles to give the Observe poller (through the service account key output). | `set(string)` | <pre>[<br/>  "roles/monitoring.viewer"<br/>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Billing Project ID needed for asset feed. | `string` | `null` | no |
| <a name="input_pubsub_ack_deadline_seconds"></a> [pubsub\_ack\_deadline\_seconds](#input\_pubsub\_ack\_deadline\_seconds) | Ack deadline for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `number` | `60` | no |
| <a name="input_pubsub_maximum_backoff"></a> [pubsub\_maximum\_backoff](#input\_pubsub\_maximum\_backoff) | Retry policy maximum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"600s"` | no |
| <a name="input_pubsub_message_retention_duration"></a> [pubsub\_message\_retention\_duration](#input\_pubsub\_message\_retention\_duration) | Message retention for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"86400s"` | no |
| <a name="input_pubsub_minimum_backoff"></a> [pubsub\_minimum\_backoff](#input\_pubsub\_minimum\_backoff) | Retry policy minimum backoff for the Pub/Sub subscription (https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions) | `string` | `"10s"` | no |
| <a name="input_resource"></a> [resource](#input\_resource) | The identifier of the GCP Resource to monitor.<br/><br/>The resource can be a project, folder, or organization.<br/><br/>Examples: "projects/my\_project-123", "folders/1234567899", "organizations/34739118321" | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | The ID of the Project in which resources were created |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | A service account key to be passed to the pollers for Pub/Sub and Cloud Monitoring |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | The Pub/Sub subscription created by this module. |
| <a name="output_topic"></a> [topic](#output\_topic) | The Pub/Sub topic created by this module. |
<!-- END_TF_DOCS -->