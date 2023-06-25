resource "random_id" "bucket_prefix" {
  byte_length = 8
}

# Bucket for files to transfer to compute instances
resource "google_storage_bucket" "bucket" {
  name                        = format(var.name_format, "${random_id.bucket_prefix.hex}-compute-source") # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
  project                     = var.project_id
  force_destroy               = true
}