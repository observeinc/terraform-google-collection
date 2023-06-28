output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "gcloud_set_cluster" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location}"
}

output "ip_address" {
  value = google_container_cluster.primary.endpoint
}

output "sockshop_commands" {
  value = {
    dir              = "cd /Users/arthur/content_eng/content-eng-tools/microservices-otel/microservices-demo/deploy/kubernetes"
    apply_socksshop  = "kubectl apply -k sockshop-k8s-demo"
    apply_ingress    = "kubectl apply -f ingress/ingress_gke.yaml"
    describe_ingress = "kubectl describe ingress --namespace=sock-shop"
    notion           = "https://www.notion.so/observeinc/Multi-Cloud-K8-Environment-Setup-52d435d52556480f95bcb32de0a7b60d#befae42f8a9647989f0abd0787025c8b"
    id               = google_container_cluster.primary.id
  }
}
