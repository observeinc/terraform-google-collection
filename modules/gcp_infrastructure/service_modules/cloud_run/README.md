# Cloud Run Sample App Infrastructure
 - `root` - Basic API service using Cloud Run built in Terraform
 - `avocano` (recommended) - Uses the [Google Cloud Sample App](https://github.com/GoogleCloudPlatform/avocano) which uses a CloudSQL database, and additionally spins up loadtests on a scheduled basis.

# Dependencies
 - Terraform
 - Observe GCP App

# Commands
 - Navigate to the `avocano` directory
 - Run `./setup deploy` to deploy resources (takes ~10 minutes), watch for the console to output the website endpoint
 - When they're no longer required, run `gcloud builds submit --config provisioning/destroy.cloudbuild.yaml` to destroy resources
 - Optionally you may prefer to run the simpler version on the root directly using `terraform deploy` from the `service_modules/cloud_run` folder instead
 - Additionally you choose to either update the server code, load tests, or run only the terraform:
  - `./provisioning/server.update.sh` - Deploys any updates to the server code including TF
  - `gcloud builds submit --config provisioning/loadtest.cloudbuild.yaml` - Updates the container for load test scripts
  - `gcloud builds submit --config provisioning/terraform.cloudbuild.yaml` - Runs the terraform modules

For more information, see the Avocano [documentation](avocano/README.md)