
locals {
  databases = { for key, value in var.database_values : key => value if contains(var.database_filter, key) }

  # database_set = flatten([
  #   for set in var.instance_set : [
  #     for key, value in local.databases : {
  #       "${key}_${set}" : value
  #     }
  #   ]
  # ])

  # database_set = flatten([
  #   for i in range(0, var.database_instance_count) : {
  #     for key, value in local.databases :
  #     "${key}_${i}" => value

  #   }
  # ])

  # database_map = zipmap(
  #   flatten(
  #     [for item in local.database_set : keys(item)]
  #   ),
  #   flatten(
  #     [for item in local.database_set : values(item)]
  #   )
  # )
}



resource "random_pet" "user_name" {
  for_each = local.databases
  keepers = {
    databases = each.key
  }
  length = 1
}

resource "random_pet" "server_name" {
  for_each = local.databases
  keepers = {
    databases = each.value.recreate
  }
  length = 1
}

resource "random_password" "password" {
  for_each = local.databases
  keepers = {
    databases = each.key
  }
  length  = 8
  special = false
}

resource "random_integer" "this" {
  min = 100
  max = 999
  keepers = {
    # Generate a new integer each time we switch
    listener_arn = var.random_int_keeper
  }
}

locals {
  str_f = "_"
  str_r = "-"
}

resource "google_sql_database_instance" "instances" {
  for_each = local.databases

  name                = format(var.name_format, "instance-${lower(replace(each.key, local.str_f, local.str_r))}-${random_pet.server_name[each.key].id}-${random_integer.this.result}")
  database_version    = each.value.version
  region              = var.region
  project             = var.project_id
  deletion_protection = each.value.deletion_protection
  root_password       = random_password.password[each.key].result
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = each.value.tier

    dynamic "database_flags" {
      for_each = each.value.db_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
    ip_configuration {
      # Add optional authorized networks
      # Update to match the customer's networks
      authorized_networks {
        name  = format(var.name_format, "test")
        value = "0.0.0.0/0"
      }
    }

    user_labels = {
      created_by = "terraform"
      use        = "testing"
      version    = "1"
    }
  }

}

resource "google_sql_database" "instances" {
  for_each = local.databases
  project  = var.project_id
  name     = each.value.database
  instance = google_sql_database_instance.instances[each.key].name
}

resource "google_sql_user" "users" {
  for_each        = local.databases
  project         = var.project_id
  name            = random_pet.user_name[each.key].id
  instance        = google_sql_database_instance.instances[each.key].name
  password        = random_password.password[each.key].result
  deletion_policy = "ABANDON"
}

# locals {
#   db_var = flatten([for key, value in google_sql_database_instance.instances :
#     {
#       db            = key
#       host          = value.public_ip_address
#       username      = google_sql_user.users[key].name
#       password      = google_sql_user.users[key].password
#       database_name = local.databases[key].database
#     }
#   ])
# }

# resource "local_file" "db" {
#   content  = jsonencode(local.db_var)
#   filename = "${dirname(path.module)}/compute/bucket/ip/db_addresses.json"
# }

# resource "google_storage_bucket_object" "db_ips" {

#   depends_on = [local_file.db]

#   name         = "ip/db_addresses.json"
#   bucket       = var.config_bucket_name
#   source       = "${dirname(path.module)}/compute/bucket/ip/db_addresses.json"
#   content_type = "text/plain; charset=utf-8"
# }
