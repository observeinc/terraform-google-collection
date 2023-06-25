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

# list of files to upload
locals {
  list_of_files = [
    { source : "stuff_for_s3/README.md", name : "README.md" },
  ]

  bucket_name = google_storage_bucket.bucket.name
}

# upload list of files
resource "google_storage_bucket_object" "object" {
  for_each = { for key, value in local.list_of_files : key => value }

  name   = each.value.name
  bucket = local.bucket_name
  source = "${path.module}/${each.value.source}" # Add path to the zipped function source code
}

# create file in bucket
# resource "google_storage_bucket_object" "object_script" {

#   name    = "flask/some.sh"
#   bucket  = var.config_bucket_name
#   content = <<-EOF
# #!/bin/bash
# echo "Executing linux host config"
# if systemctl is-active --quiet telegraf && systemctl is-active --quiet osqueryd && systemctl is-active --quiet td-agent-bit;
# then
# echo "service running"
# else
# curl "https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/main/observe_configure_script.sh" | bash -s -- --customer_id "${var.observe.customer_id}" --ingest_token "${var.observe.datastream_token}" --observe_host_name "https://${var.observe.customer_id}.collect.${var.observe.domain}/" --config_files_clean TRUE --ec2metadata FALSE --datacenter GCP --appgroup MY_APP_GROUP
# fi
# EOF
# }

# resource "google_storage_bucket_object" "ips" {
#   depends_on = [local_file.ip]

#   name         = "ip/ip_addresses.json"
#   bucket       = var.config_bucket_name
#   source       = "${path.module}/bucket/ip/ip_addresses.json"
#   content_type = "text/plain; charset=utf-8"
# }

# locals {
#   ip_var = { for key, value in google_compute_instance.instances :
#     key => "${value.network_interface[0].network_ip}"
#   }
# }

# resource "local_file" "ip" {
#   content  = jsonencode(local.ip_var)
#   filename = "${path.module}/bucket/ip/ip_addresses.json"
# }