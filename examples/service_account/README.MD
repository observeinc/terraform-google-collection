<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.78.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_folder_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_folder"></a> [folder](#input\_folder) | The folder ID to grant the IAM roles to service account in. | `string` | `null` | no |
| <a name="input_folder_collection_roles"></a> [folder\_collection\_roles](#input\_folder\_collection\_roles) | A list of IAM roles to give to the service account for folder collection.  Note that permissions are broad and this account should only be used to set up collection intially and not for anything else. | `set(string)` | <pre>[<br>  "roles/browser",<br>  "roles/cloudasset.owner",<br>  "roles/cloudfunctions.admin",<br>  "roles/cloudscheduler.admin",<br>  "roles/cloudtasks.admin",<br>  "roles/iam.serviceAccountCreator",<br>  "roles/iam.serviceAccountDeleter",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/iam.serviceAccountTokenCreator",<br>  "roles/iam.serviceAccountUser",<br>  "roles/logging.admin",<br>  "roles/monitoring.admin",<br>  "roles/pubsub.admin",<br>  "roles/resourcemanager.folderAdmin",<br>  "roles/resourcemanager.projectCreator",<br>  "roles/resourcemanager.projectDeleter",<br>  "roles/resourcemanager.projectMover",<br>  "roles/serviceusage.serviceUsageAdmin",<br>  "roles/serviceusage.serviceUsageConsumer",<br>  "roles/servicemanagement.admin",<br>  "roles/storage.admin"<br>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | The project ID to create the service account in.  For project collection, this will also assign the IAM roles to the account in the project. | `string` | n/a | yes |
| <a name="input_project_collection_roles"></a> [project\_collection\_roles](#input\_project\_collection\_roles) | A list of IAM roles to give to the service account.  Note that permissions are broad and this account should only be used to set up collection intially and not for anything else. | `set(string)` | <pre>[<br>  "roles/browser",<br>  "roles/cloudasset.owner",<br>  "roles/cloudfunctions.admin",<br>  "roles/cloudscheduler.admin",<br>  "roles/cloudtasks.admin",<br>  "roles/iam.serviceAccountCreator",<br>  "roles/iam.serviceAccountDeleter",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/iam.serviceAccountTokenCreator",<br>  "roles/iam.serviceAccountUser",<br>  "roles/logging.admin",<br>  "roles/monitoring.admin",<br>  "roles/pubsub.admin",<br>  "roles/resourcemanager.projectIamAdmin",<br>  "roles/serviceusage.serviceUsageAdmin",<br>  "roles/serviceusage.serviceUsageConsumer",<br>  "roles/servicemanagement.admin",<br>  "roles/storage.admin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | n/a |
<!-- END_TF_DOCS -->