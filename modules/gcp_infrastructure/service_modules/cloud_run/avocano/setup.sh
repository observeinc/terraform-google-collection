#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## This script automates some basic setup for new projects,
## then runs Cloud Build, Terraform, and initial deployment.
##
## For updates, just run `gcloud builds submit`

# Make sure the script stops if any command fails
set -e

# Some commands are noisy, so make them quiet.
function quiet {
  $* >/dev/null 2>&1
}

function deploy {
  echo "Configuring active project and region..."
  export PROJECT_ID=${PROJECT_ID:=$(gcloud config get project)}
  export REGION=${REGION:=us-central1} # default us-central1 region if not defined
  export PROJECTNUM=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')

  echo "Enabling required service APIs..."
  gcloud services enable \
    firebase.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudbuild.googleapis.com \
    iam.googleapis.com \
    --project=$PROJECT_ID

  echo "Running setup.sh against ${PROJECT_ID} in ${REGION}"

  echo "Setup Firebase Builder"
  gcloud builds submit --config provisioning/firebase-builder.cloudbuild.yaml --no-source

  echo "Build client image"
  gcloud builds submit --config provisioning/client-image.cloudbuild.yaml

  echo "Build load test image"
  gcloud builds submit --config provisioning/loadtest.cloudbuild.yaml

  echo "Configuring Terraform"
  export TFSTATE_BUCKET=terraform-${PROJECT_ID}-avocano
  gsutil mb gs://$TFSTATE_BUCKET || true

  echo "Granting Cloud Build permissions"
  export CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID \
    --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
  quiet gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$CLOUDBUILD_SA --role roles/owner
  quiet gsutil iam ch \
    serviceAccount:${CLOUDBUILD_SA}:roles/storage.admin \
    gs://$TFSTATE_BUCKET

  echo "Running Cloud Build for the Application"
  gcloud builds submit --config provisioning/deploy.cloudbuild.yaml --substitutions _REGION=${REGION}

  echo "Setting up database"
  gcloud beta run jobs execute setup --wait --region $REGION

  echo "Runing UI tests"
  gcloud builds submit --config provisioning/test-deployment.yaml --substitutions _REGION="${REGION}"

  echo "Website now available at https://${PROJECT_ID}.firebaseapp.com"
}

function destroy {
  echo "Configuring active project and region..."
  export PROJECT_ID=${PROJECT_ID:=$(gcloud config get project)}
  export REGION=${REGION:=us-central1} # default us-central1 region if not defined
  export PROJECTNUM=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')

  echo "Terminating any running loadtest jobs from us-east1"
  gcloud beta run jobs executions list \
    --region us-east1 \
    --job loadtest \
    --format json | jq -r '.[] | select(.status.completionTime | . == null) | objects | .metadata.name' |
    xargs -I {} gcloud beta run jobs executions delete --region us-east1 "{}" --quiet

  echo "Configuring Terraform"
  export TFSTATE_BUCKET=terraform-${PROJECT_ID}-avocano
  gsutil mb gs://$TFSTATE_BUCKET || true

  echo "Granting Cloud Build permissions"
  export CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
  gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$CLOUDBUILD_SA --role roles/owner
  gsutil iam ch serviceAccount:${CLOUDBUILD_SA}:roles/storage.admin gs://$TFSTATE_BUCKET

  echo "Destroying TF resources against ${PROJECT_ID} in ${REGION}"
  gcloud builds submit --config provisioning/destroy.cloudbuild.yaml --substitutions _REGION=${REGION}
}

function usage() {
  echo "Usage: ./setup.sh [deploy|destroy]"
  exit 1
}

[[ $# -eq 0 ]] && usage

# Invoke is_file_exits
if [ "$1" = "deploy" ]; then
  deploy
elif [ "$1" = "destroy" ]; then
  destroy
else
  usage
fi
