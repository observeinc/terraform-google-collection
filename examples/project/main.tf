module "observe_gcp_collection" {
  #source = "../../"
  source = "observeinc/collection/google"

  name     = var.name
  resource = var.resource
}
