data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.fake_service_client.location
  project  = google_cloud_run_service.fake_service_client.project
  service  = google_cloud_run_service.fake_service_client.name

  policy_data = data.google_iam_policy.noauth.policy_data
}


resource "google_cloud_run_service" "fake_service_client" {
  name     = format(var.name_format, "test-cloudrun-srv")
  project  = var.project_id
  location = var.region

  template {
    spec {
      containers {
        image = "nicholasjackson/fake-service:v0.25.1"
        ports {
          container_port = 9090
        }
        env {
          name  = "NAME"
          value = "client"
        }
        env {
          name  = "MESSAGE"
          value = "Hello world from server!"
        }
        env {
          name  = "TIMING_90_PERCENTILE"
          value = "10s"
        }
        env {
          name  = "ERROR_RATE"
          value = "0.25"
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "null_resource" "execute_loadtest" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "ab -n 5000 -c 10 ${google_cloud_run_service.fake_service_client.status[0].url}/"
  }
  triggers = {
    always_run = var.always_run_load_tests ? timestamp() : false
  }

  depends_on = [
    google_cloud_run_service.fake_service_client
  ]
}
