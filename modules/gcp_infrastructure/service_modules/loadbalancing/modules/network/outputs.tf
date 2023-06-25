output "network_load_balancer_ip_address" {
  value = google_compute_forwarding_rule.default.ip_address
}
