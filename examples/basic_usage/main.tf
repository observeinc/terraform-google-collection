module "observe_collection_example" {
  source = "../../"

  name   = var.name
  resource = "projects/${var.project_id}"
}
