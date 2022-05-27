locals {
  pubsub_poller_name = "${var.name}-pubsub"
  metric_poller_name = "${var.name}-metrics"
  name_format        = "${var.name}/%s"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
provider "observe" {
  customer = var.observe_customer
  domain   = var.observe_domain
  token    = var.observe_token
}

module "observe_gcp_collection" {
  source = "github.com/observeinc/terraform-google-collection?ref=main"
  name   = var.name
}

data "observe_workspace" "default" {
  name = var.observe_workspace
}

data "observe_datastream" "gcp" {
  workspace = data.observe_workspace.default.oid
  name      = "GCP"
}

resource "observe_poller" "pubsub_poller" {
  workspace = data.observe_workspace.default.oid
  name      = local.pubsub_poller_name

  datastream = data.observe_datastream.gcp.oid

  pubsub {
    project_id      = module.observe_gcp_collection.project
    subscription_id = module.observe_gcp_collection.subscription.name
    json_key        = base64decode(module.observe_gcp_collection.service_account_key.private_key)
  }
}

resource "observe_poller" "gcp_metrics" {
  workspace = data.observe_workspace.default.oid
  name      = local.metric_poller_name
  interval  = "1m0s"

  datastream = data.observe_datastream.gcp.oid

  gcp_monitoring {
    project_id = module.observe_gcp_collection.project
    json_key   = base64decode(module.observe_gcp_collection.service_account_key.private_key)

    include_metric_type_prefixes = var.include_metric_type_prefixes
    exclude_metric_type_prefixes = var.exclude_metric_type_prefixes
  }
}

module "google" {
  source      = "github.com/observeinc/terraform-observe-google?ref=main"
  workspace   = data.observe_workspace.default
  name_format = local.name_format
  datastream  = data.observe_datastream.gcp

  services = var.observe_services
}
