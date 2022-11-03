resource "local_file" "main_py" {
  content  = file("${var.src_path}/main.py")
  filename = "${path.module}/tmp/main.py"
}

resource "local_file" "r_txt" {
  content  = file("${var.src_path}/requirements.txt")
  filename = "${path.module}/tmp/requirements.txt"
}

data "archive_file" "init" {
  depends_on = [local_file.main_py, local_file.r_txt]
  for_each = { for key, value in local.entry_point : key => value }

  type        = "zip"
  source_dir  = "${path.module}/tmp"
  output_path = each.value.output_path
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "pub_sub_bucket" {
  name                        = format(var.name_format, "${random_id.bucket_prefix.hex}-pubsub-source") # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
  project                     = var.project_id
  force_destroy               = true
}

resource "google_storage_bucket_object" "object" {
  depends_on = [
    data.archive_file.init
  ]

  for_each = { for key, value in local.entry_point : key => value }
  name   = format(var.name_format, each.value.zip_file)
  bucket = google_storage_bucket.pub_sub_bucket.name
  source = each.value.output_path # Add path to the zipped function source code
}