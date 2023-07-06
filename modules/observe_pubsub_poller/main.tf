resource "observe_poller" "pubsub_poller" {
  workspace = var.workspace.oid
  name      = var.name

  datastream = var.datastream.oid

  pubsub {
    project_id      = var.project
    subscription_id = var.subscription
    json_key        = var.service_account_private_key_json
  }
}
