module "monitoring_poller" {
  source      = "./monitoring"
  workspace   = var.workspace
  datastream  = var.datastream
  name        = format(var.name_format, "metrics")
  description = "terraform only poller"
  project     = var.project_id
  #service_account_private_key_json = base64decode(module.observe_gcp_collection.service_account_key.private_key)
  service_account_private_key_json = var.service_account_private_key_json

  include_metric_type_prefixes = var.metric_prefixes
}
