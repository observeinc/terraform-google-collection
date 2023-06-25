output "cloud_function_module" {
  value = google_cloudfunctions_function.this
}

output "cloud_function_name" {
  value = google_cloudfunctions_function.this.name
}

output "cloud_function_trigger" {
  value = google_cloudfunctions_function.this.https_trigger_url
}

output "bucket_object" {
  value = google_storage_bucket_object.object
}
