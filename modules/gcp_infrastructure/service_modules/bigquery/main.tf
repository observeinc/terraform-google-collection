locals {
  # variables for string replacement in naming
  str_f = "_"
  str_r = "-"
}

# creates a big query dataset
resource "google_bigquery_dataset" "default" {
  project                     = var.project_id
  dataset_id                  = replace(format(var.name_format, "dataset"), local.str_r, local.str_f)
  friendly_name               = format(var.name_format, "bq-sample-dataset")
  description                 = "This is a test description"
  location                    = "US"
  default_table_expiration_ms = 432000000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = format(var.name_format, "table")

  deletion_protection = false

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "ip_address",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "IP address for resource"
  },
  {
    "name": "resource_name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Unique identifier for resource"
  },
    {
    "name": "timestamp",
    "type": "DATETIME",
    "mode": "NULLABLE",
    "description": "insert time"
  }
]
EOF

}

resource "google_bigquery_table" "second" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = format(var.name_format, "table-2")

  deletion_protection = false

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "ID for entry"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "name for entry"
  },
    {
    "name": "timestamp",
    "type": "DATETIME",
    "mode": "NULLABLE",
    "description": "insert time"
  }
]
EOF

}

resource "google_service_account" "bqowner" {
  project    = var.project_id
  account_id = "bqowner"
}

locals {
  table_name  = "${google_bigquery_table.default.project}.${google_bigquery_table.default.dataset_id}.${google_bigquery_table.default.table_id}"
  table_name2 = "${google_bigquery_table.second.project}.${google_bigquery_table.second.dataset_id}.${google_bigquery_table.second.table_id}"

}
