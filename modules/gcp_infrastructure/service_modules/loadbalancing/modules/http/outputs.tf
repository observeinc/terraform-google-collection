output "http_load_balancer_ip_address" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}

output "http_load_balancer_ip_address_8080" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule_8080.ip_address
}
