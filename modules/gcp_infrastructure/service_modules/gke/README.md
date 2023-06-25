
## Make sure you can interact with GKE cluster install auth plugin
gcloud components install gke-gcloud-auth-plugin

## Get credentials - stores locally so kubectl will work
gcloud container clusters get-credentials test-stg-gke --region us-west1


### Sample commands
kubectl get namespace

kubectl get pods

## Google supplied sample app

https://github.com/GoogleCloudPlatform/microservices-demo

## To install using kubectl
kubectl apply -f ./release/kubernetes-manifests.yaml

## Install Observe collector
export OBSERVE_CUSTOMER=[YOURS]\
export OBSERVE_TOKEN=[YOURS] \
export  OBSERVE_COLLECTOR_HOST=[YOURS] \
kubectl apply -k https://github.com/observeinc/manifests/stack && \
	kubectl -n observe create secret generic credentials \
	--from-literal=OBSERVE_CUSTOMER=$OBSERVE_CUSTOMER \
	--from-literal=OBSERVE_TOKEN=$OBSERVE_TOKEN \
  	--from-literal=OBSERVE_COLLECTOR_HOST=$OBSERVE_COLLECTOR_HOST

kubectl annotate namespace observe observeinc.com/cluster-name="gcp-cost-test-cluster1"

kubectl annotate namespace observe eksClusterArn="gcp-cost-test-cluster1"

kubectl annotate namespace observe observeinc.com/cluster-name="arn:aws:eks:us-west-2:384876807807:cluster/arthur-k8s-test-1"

kubectl annotate namespace observe observeinc.com/gks-cluster-="43915b45797b41b1a34306bbd51c7e180b77f77f7fd3407ab7f340e2b83cd87f"

## If you need to overwrite
kubectl annotate --overwrite=true namespace observe observeinc.com/cluster-name="//container.googleapis.com/projects/content-testpproj-stage-1/locations/us-west1/clusters/test-stg-gke"

### SUPER IMPORTANT - You must annotate kube-system namespace in order for link through to other resources like node
kubectl annotate --overwrite=true namespace kube-system observeinc.com/cluster-name="//container.googleapis.com/projects/content-testpproj-stage-1/locations/us-west1/clusters/test-stg-gke"

## Add persistent volume
https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes

kubectl apply -f pvc-pod-demo.yaml
## Reference
https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/

https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke