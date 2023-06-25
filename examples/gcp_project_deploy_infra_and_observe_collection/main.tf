locals {
  # observe = {
  #   customer_id           = "126329491179"
  #   otel_datastream_token = "ds1J8gzPachy4fscTzSD:csenknPbvhkV8WHdjVxaShMbf5HgBY6B"
  #   host_datastream_token = "ds1oYxW0CSmcWk14uwsX:hUIOgRqLbLZcrCYdNSnfnkJP0TyR_F_-"
  #   domain                = "observeinc.com"
  # }
}

# TO DO
# 2. Fix the zones in Compute and LoadBalancing
# 3. instructions for all

###############################################################
# 
# This enables all the GCP Services needed to deploy sample
# GCP infrastructure below
#
##############################################################


module "google_project_service" {
  source             = "../modules/gcp_project_services"
  project_id         = var.project_id
  services_to_enable = var.gcp_services
}

#####################################################################################
#
# Deploys GCP infrastrucure that will generate requisite data to populate datasets and
# dashboards within the Observe App for GCP
#
#####################################################################################

module "gcp_sample_infrastructure" {
  source      = "../modules/gcp_infrastructure"
  project_id  = var.project_id
  region      = var.region
  zone1       = "${var.region}-a"
  zone2       = "${var.region}-b"
  name_format = var.name_format
  observe     = var.observe
}

#####################################################################################
#
# The following will deploy the Observe GCP Collection that:
# - Deploys Cloud Functions responsible for gathering and sending GCP Asset Inventory
# - A GCP PubSub Topic and Subscription to that Topic
# - Log Sink between Project resources and the Topic
#
#####################################################################################

module "observe_gcp_collection" {
  source   = "../../"
  name     = format(var.name_format, "env")
  resource = "projects/${var.project_id}"
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
