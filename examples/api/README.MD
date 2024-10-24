<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_service.enabled_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | The project ID where apis will be enabled. | `string` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | The list of APIs to enable for observe collection | `set(string)` | <pre>[<br>  "cloudasset.googleapis.com",<br>  "iam.googleapis.com",<br>  "logging.googleapis.com",<br>  "monitoring.googleapis.com",<br>  "pubsub.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "cloudfunctions.googleapis.com",<br>  "cloudbuild.googleapis.com",<br>  "cloudscheduler.googleapis.com",<br>  "storage.googleapis.com",<br>  "sqladmin.googleapis.com",<br>  "compute.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "container.googleapis.com",<br>  "redis.googleapis.com",<br>  "run.googleapis.com",<br>  "cloudtasks.googleapis.com"<br>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
