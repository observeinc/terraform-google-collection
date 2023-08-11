module "observe_gcp_collection" {
  source = "../../"
  #source = "observeinc/collection/google"

  name       = var.name
  resource   = var.resource
  project_id = var.project_id
  function_available_memory_mb = 2048
}
