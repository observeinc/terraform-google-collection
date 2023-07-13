locals {
  projects = data.google_projects.my_folder_projects.projects
}

#######################################################################
# 
# The Obseverve GCP Collection that creates the PubSub, Log Sinks,
# and deploys a GCP Cloud Function used to collect Asset Information
# 
#######################################################################

module "observe_gcp_collection" {
  source   = "../../"
  name     = var.name
  resource = "folders/${var.folder_number}"
  project_id = var.project_id
}

data "google_project" "service_project" {
  project_id = var.project_id
}

#####################################################################
# 
# Determines all the sibling GCP Projects inside the folder the 
# service/collection project was deployed
#
#####################################################################

data "google_projects" "my_folder_projects" {
  filter = "parent.id:${data.google_project.service_project.folder_id} lifecycleState:ACTIVE"
}

###############################################################
# 
# This enables all the GCP API Services needed for metrics in
# each project in the Folder the service/collection
# Project is deployed.   
#
##############################################################


module "google_project_service" {
  for_each = {
    for index, project in local.projects :
    project.project_id => project if project.project_id != var.project_id
  }

  source             = "../../modules/gcp_project_services"
  project_id         = each.value.project_id
  services_to_enable = var.metric_services
}


#######################################################################################
# 
# This will add all sibling projects that reside in the same 
# folder as the collection/service project as Metric Montiored Projects.
# 
# The result will be: Metrics for all projects flowing through the collection/service
# project and collected with a single Observe poller.
# 
#######################################################################################

resource "google_monitoring_monitored_project" "primary" {
  for_each = {
    for index, project in local.projects :
    project.project_id => project if project.project_id != var.project_id
  }
  metrics_scope = var.project_id
  name          = each.value.project_id
}

#######################################################################################
#
# The following would replace the steps of creating connections to GPC using Observe
# Pollers inside "Creating the required connections to GCP" 
# found in https://docs.observeinc.com/en/latest/content/integrations/gcp/gcp.html#id1
# 
# The following still requires an Observe Datastream to be created.  The simplest way
# to accomplish this is by installing the Observe Application for GCP. 
# 
# NOTE: YOU NEED TO UNCOMMENT OUT THE Observe PROVIER in versions.tf to use below.
#
#######################################################################################

# locals {
#   workspace  = data.observe_workspace.default
#   datastream = data.observe_datastream.gcp
# }

# data "observe_workspace" "default" {
#   name = "Default"
# }

# data "observe_datastream" "google" {
#   workspace = data.observe_workspace.default.oid
#   name      = "GCP"
# }

# module "observe_gcp_metrics_poller" {
#   workspace                        = data.observe_workspace.default
#   datastream                       = data.observe_datastream.google
#   source                           = "../../modules/observe_metrics_poller"
#   project_id                       = var.project_id
#   name_format                      = "${var.project_id}-poller-%s"
#   service_account_private_key_json = base64decode(module.observe_gcp_collection.service_account_key.private_key)

#   depends_on = [module.observe_gcp_collection]
# }

# module "pubsub_poller" {
#   source                           = "../../modules/observe_pubsub_poller"
#   workspace                        = local.workspace
#   datastream                       = local.datastream
#   name                             = format(var.name_format, "assets-logs")
#   description                      = "terraform only poller"
#   project                          = var.project_id
#   service_account_private_key_json = base64decode(module.observe_gcp_collection.service_account_key.private_key)
#   subscription                     = module.observe_gcp_collection.subscription.name
# }
