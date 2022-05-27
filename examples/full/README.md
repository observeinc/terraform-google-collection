# Full GCP Integration

This configuration documents a method for setting up infrastructure on Google,
the Observe pollers, and the Observe datasets.

### Usage

1. Copy the terraform config below into the relevant module. 
      - The config defines a Google provider, the Observe Google Collection module, and the Observe pollers.
      - These components combined enables collection of logs, metrics, and resource updates from Google Cloud.
1. In the Observe UI, Create the GCP data stream.
      - If your customer ID is 101, then you can create it in https://101.observeinc.com/settings/datastreams
      - If the name of your datastream is not "GCP", you will need to the observe_datastream data source in the terraform config.
1. Get an Observe access key.
      - Currently [this Observe FAQ answer](https://docs.observeinc.com/en/latest/content/common-topics/FAQ.html?highlight=access#how-do-i-create-an-access-token-that-can-do-more-than-just-ingest-data) works.
      - Note: the token here isn't an "ingest token" (that only allows ingest.) You want an authtoken.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
