output "connection_string" {
  value = { for key, value in google_sql_database_instance.instances : key =>
    {
      host          = value.public_ip_address
      username      = google_sql_user.users[key].name
      password      = google_sql_user.users[key].password
      database_name = local.databases[key].database
  } }
  sensitive = true
}

output "cloudsql_instance_names" {
  value = { for key, value in google_sql_database_instance.instances : key =>
    {
      database_name = value.name
  } }
}

# output "database_map" {
#   value = local.database_map
# }

output "database_list" {
  value = flatten([for key, value in google_sql_database_instance.instances :
    {
      db            = key
      host          = value.public_ip_address
      username      = google_sql_user.users[key].name
      password      = google_sql_user.users[key].password
      database_name = local.databases[key].database
    }
  ])
}
