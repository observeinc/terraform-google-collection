output "bucket" {
  value = { for key, value in local.buckets : google_storage_bucket.bucket[key].name => google_storage_bucket.bucket[key]
  }
}
