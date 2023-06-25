# create service account for cloud function
resource "google_service_account" "cloudfunction" {
  project     = var.project_id
  account_id  = format(var.name_format, "func-sa")
  description = "Used by the Observe Cloud Functions"
}

# add service account to roles
resource "google_project_iam_member" "cloudfunction" {
  for_each = var.function_roles

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudfunction.email}"
}

# create a bucket for function code
resource "google_storage_bucket" "bucket" {
  name                        = format(var.name_format, "func-bucket") # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
  project                     = var.project_id
  force_destroy               = true
}

# create zip file for code
data "archive_file" "init" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.output_path
}

# create bucket object with zip file
resource "google_storage_bucket_object" "object" {
  depends_on = [
    data.archive_file.init
  ]
  name   = format(var.name_format, "function-source.zip")
  bucket = google_storage_bucket.bucket.name
  source = var.output_path # Add path to the zipped function source code
}

# create function using code
resource "google_cloudfunctions_function" "this" {

  region                = var.region
  project               = var.project_id
  name                  = format(var.name_format, "func")
  description           = var.description
  service_account_email = google_service_account.cloudfunction.email

  runtime = var.runtime

  environment_variables = merge({}, var.environment_variables)

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" # Needed for Cloud Scheduler to work

  available_memory_mb = var.function_available_memory_mb
  timeout             = var.function_timeout
  max_instances       = var.function_max_instances

  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.object.name
  entry_point           = "main"
  lifecycle {
    replace_triggered_by = [
      google_storage_bucket_object.object
    ]
  }
  #   labels = var.labels

  # vpc connector allows function to connect to redis instance
  vpc_connector = var.vpc_connector_id
}





