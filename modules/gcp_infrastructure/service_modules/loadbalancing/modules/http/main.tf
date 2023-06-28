
# used to forward traffic to the correct load balancer for HTTP load balancing 
resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name       = format(var.name_format, "global-forwarding-rule")
  project    = var.project_id
  target     = google_compute_target_http_proxy.target_http_proxy.self_link
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "global_forwarding_rule_8080" {
  name       = format(var.name_format, "global-forwarding-rule2")
  project    = var.project_id
  target     = google_compute_target_http_proxy.target_http_proxy2.self_link
  port_range = "8080"
}

# used by one or more global forwarding rule to route incoming HTTP requests to a URL map
resource "google_compute_target_http_proxy" "target_http_proxy" {
  name    = format(var.name_format, "proxy")
  project = var.project_id
  url_map = google_compute_url_map.url_map.self_link
}

# used by one or more global forwarding rule to route incoming HTTP requests to a URL map
resource "google_compute_target_http_proxy" "target_http_proxy2" {
  name    = format(var.name_format, "proxy2")
  project = var.project_id
  url_map = google_compute_url_map.url_map2.self_link
}

# determine whether instances are responsive and able to do work
resource "google_compute_health_check" "healthcheck" {
  project            = var.project_id
  name               = format(var.name_format, "healthcheck")
  timeout_sec        = 5
  check_interval_sec = 5
  http_health_check {
    port = 80
  }
  log_config {
    enable = true
  }
}

resource "google_compute_health_check" "healthcheck_8080" {
  project            = var.project_id
  name               = format(var.name_format, "healthcheck-8080")
  timeout_sec        = 5
  check_interval_sec = 5
  http_health_check {
    port = 8080
  }
}

resource "google_compute_url_map" "url_map2" {
  name            = format(var.name_format, "load-balancer2")
  project         = var.project_id
  default_service = google_compute_backend_service.backend_service_flask.self_link
}
# used to route requests to a backend service based on rules that you define for the host and path of an incoming URL
resource "google_compute_url_map" "url_map" {
  name            = format(var.name_format, "load-balancer")
  project         = var.project_id
  default_service = google_compute_backend_service.backend_service_apache.self_link
}


# creates a group of dissimilar virtual machine instances
resource "google_compute_instance_group" "web_private_group" {
  project     = var.project_id
  name        = format(var.name_format, "vm-group")
  description = "Web servers instance group"
  zone        = "${var.region}-a"

  instances = var.target_group_instances

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "flask"
    port = "8080"
  }
}

# resource "google_compute_backend_service" "backend_service" {
#   name          = format(var.name_format, "backend-service")
#   project       = var.project_id
#   port_name     = "http"
#   protocol      = "HTTP"
#   health_checks = ["${google_compute_health_check.healthcheck.self_link}"]

#   backend {
#     group                 = google_compute_instance_group.web_private_group.self_link
#     balancing_mode        = "RATE"
#     max_rate_per_instance = 5
#   }
# }

# defines a group of virtual machines that will serve traffic for load balancing
resource "google_compute_backend_service" "backend_service_apache" {
  name          = format(var.name_format, "backend-service-apache")
  project       = var.project_id
  port_name     = "http"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.healthcheck.self_link]

  backend {
    group                 = google_compute_instance_group.web_private_group.self_link
    balancing_mode        = "RATE"
    max_rate_per_instance = 5
  }
}

resource "google_compute_backend_service" "backend_service_flask" {
  name          = format(var.name_format, "backend-service-flask")
  project       = var.project_id
  port_name     = "flask"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.healthcheck_8080.self_link]

  backend {
    group                 = google_compute_instance_group.web_private_group.self_link
    balancing_mode        = "RATE"
    max_rate_per_instance = 5
  }
}
