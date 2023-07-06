locals {
  buckets = flatten([
    for i in range(0, var.bucket_count) : [
      {
        bucket_name : format(var.name_format, "bucket-${random_id.bucket_prefix[i].hex}-${i}")
      }
    ]
  ])
}

resource "random_id" "bucket_prefix" {
  count       = var.bucket_count
  byte_length = 8
}

resource "google_storage_bucket" "bucket" {
  for_each                    = { for key, value in local.buckets : key => value }
  name                        = each.value.bucket_name # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
  project                     = var.project_id
  force_destroy               = var.force_destroy
}

resource "google_storage_bucket_iam_binding" "landing_page_iam_binding" {
  for_each = google_storage_bucket.bucket
  bucket   = each.value.name
  role     = "roles/storage.objectAdmin"
  members = [
    "allUsers"
  ]
}