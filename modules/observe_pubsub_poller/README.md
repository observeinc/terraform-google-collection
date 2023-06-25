Before setting up this [poller](https://docs.observeinc.com/en/latest/content/common-topics/ObserveGlossary.html) you
typically should follow the [GCP App installation prerequisites](https://docs.observeinc.com/en/latest/content/integrations/gcp/gcp.html#installation) to collect your GCP data.

This poller can also be used to ingest custom data from any pull-based Pub/Sub topic.
It is a useful, lower-cost way to get large amounts of data from GCP into Observe.

The GCP Pub/Sub poller periodically fetches messages from a pull-based Pub/Sub subscription.  

You will need the name of the Pub/Sub subscription and a service account private key in Json format to set up this poller.
The service account should have permission to read messages from the subscription.
