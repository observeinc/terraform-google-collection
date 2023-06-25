# provider "google"{
#   project = "joe-test-proj"
#   credentials = file("/Users/joe/.config/gcloud/application_default_credentials.json")
#   #billing_project = "01801F-9A90AB-CAFEC6"
#   #billing_project = "content-eng-billing-report"
# }

# provider "google" {
#   alias       = "asset_folder_feed"
#   credentials = file("/Users/joe/Downloads/joe-test-proj-da952aedf9fa.json")
#   project     = var.project_id
#   region      = var.region
# }