resource "observe_poller" "gcp_monitoring" {
  workspace = var.workspace.oid
  name      = var.name
  interval  = var.interval_duration

  datastream = var.datastream.oid

  gcp_monitoring {
    project_id = var.project
    json_key   = var.service_account_private_key_json

    include_metric_type_prefixes = var.include_metric_type_prefixes
    exclude_metric_type_prefixes = var.exclude_metric_type_prefixes
  }
}