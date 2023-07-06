output "http_load_balancer_ip" {
  value = google_compute_global_address.my_ip
}

output "http_load_balancer_ip_address" {
  #   value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  value = module.http_load_balancer.http_load_balancer_ip_address
}

output "http_curl_load_balancer_ip_address" {
  #   value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  value = "curl -m1 ${module.http_load_balancer.http_load_balancer_ip_address}"
}

output "http_curl_load_balance_ip_address_8080" {
  #   value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  value = "curl -m1 ${module.http_load_balancer.http_load_balancer_ip_address_8080}"
}

output "network_load_balancer_ip" {
  value = google_compute_global_address.my_ip
}

output "network_load_balancer_ip_address" {
  #   value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  value = module.network_load_balancer.network_load_balancer_ip_address
}

output "network_curl_load_balancer_ip_address" {
  #   value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  value = "curl -m1 ${module.network_load_balancer.network_load_balancer_ip_address}"
}

output "load_balancer_list" {
  #   value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  value = [
    { port = "80", address = "http://${module.network_load_balancer.network_load_balancer_ip_address}" },
    { port = "8080", address = "http://${module.http_load_balancer.http_load_balancer_ip_address_8080}" },
  { port = "80", address = "http://${module.http_load_balancer.http_load_balancer_ip_address}" }]
}


