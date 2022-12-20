locals {
  base_roles = [
    "roles/storage.objectViewer",
    "roles/pubsub.publisher",
  ]

  function_env_vars = {
    "PROJECT_ID" = var.project_id
    "TOPIC_ID"   = data.google_pubsub_topic.my.id

  }

  entry_point = {
    export-instance-groups = {
      description     = "function for exporting compute instance groups and thier instances"
      entry_point     = "list_instance_group"
      zip_file        = "instance-group-function-source.zip"
      output_path     = "${path.module}/zipfiles/instance-group-function.zip"
      dependent_roles = ["roles/compute.viewer"]
    }

    export-service-accounts = {
      description     = "function for exporting service accounts"
      entry_point     = "list_service_accounts"
      zip_file        = "service-account-function-source.zip"
      output_path     = "${path.module}/zipfiles/service-account-function-source.zip"
      dependent_roles = ["roles/iam.serviceAccountViewer"]
    }

    export-cloud-scheduler = {
      description     = "function for exporting cloud scheduler jobs"
      entry_point     = "list_cloud_scheduler_jobs"
      zip_file        = "cloud-scheduler-function-source.zip"
      output_path     = "${path.module}/zipfiles/cloud-scheduler-function-source.zip"
      dependent_roles = ["roles/cloudscheduler.viewer"]
    }

  }

  extensions       = { for key, value in local.entry_point : key => value if contains(var.extensions_to_include, key) }
  extensions_roles = flatten([for k, v in local.extensions : [v.dependent_roles]])
  roles            = toset(distinct(concat(local.base_roles, local.extensions_roles)))
}

data "google_pubsub_topic" "my" {
  project = var.project_id
  name    = "test-stg-"
}

resource "google_service_account" "cloud_functions" {
  project     = var.project_id
  account_id  = format(var.name_format, "pub-sub-func")
  description = "A service account for the Observe Cloud Functions"
}

resource "google_project_iam_member" "cloud_functions" {
  for_each = local.roles
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.cloud_functions.email}"
}


resource "google_cloudfunctions_function" "function" {
  for_each   = local.extensions

  name                  = format(var.name_format, "${each.key}-v2")
  region                = var.region
  description           = each.value.description
  project               = var.project_id
  service_account_email = google_service_account.cloud_functions.email

  runtime               = "python310"
  environment_variables = local.function_env_vars

  available_memory_mb   = 512
  source_archive_bucket = "observeinc"
  source_archive_object = "google-cloud-functions.zip"
  trigger_http          = true
  ingress_settings      = "ALLOW_ALL"
  timeout               = 120
  entry_point           = each.value.entry_point

}
