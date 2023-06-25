output "bigquery_dataset" {
  value = google_bigquery_dataset.default
}

output "bigquery_table" {
  value = google_bigquery_table.default
}

output "bigquery_selflink" {
  value = local.table_name
}

output "bigquery_selflink2" {
  value = local.table_name2
}
