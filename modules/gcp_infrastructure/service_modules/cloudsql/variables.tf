
variable "database_filter" {
  type        = list(any)
  description = "list of database platforms to filter"
  default     = ["MYSQL_8_0", "POSTGRES_14"]
  # default     = ["MYSQL_8_0", "POSTGRES_14", "SQLSERVER_2019_STANDARD"]
}

variable "database_values" {
  type        = map(any)
  description = "list of database platforms to filter"
  default = {
    MYSQL_8_0 = {
      version             = "MYSQL_8_0"
      recreate            = "changetorecreate_12"
      root_user           = null
      deletion_protection = false
      tier                = "db-f1-micro"
      db_flags = {
        log_output           = "FILE"
        general_log          = "ON"
        cloudsql_mysql_audit = "ON"
      }

      database = "cloud_freak"
    }

    POSTGRES_14 = {
      version             = "POSTGRES_14"
      recreate            = "changetorecreate_12"
      root_user           = null
      deletion_protection = false
      tier                = "db-custom-1-3840"

      # https://cloud.google.com/sql/docs/postgres/pg-audit
      #https://kb.objectrocket.com/postgresql/how-to-run-an-sql-file-in-postgres-846
      # https://hub.docker.com/_/postgres
      db_flags = {
        "cloudsql.enable_pgaudit" = "on"
        "pgaudit.log"             = "all"
      }

      database = "cloud_freak"

    }

    SQLSERVER_2019_STANDARD = {
      version             = "SQLSERVER_2019_STANDARD"
      recreate            = "changetorecreate_12"
      root_user           = "sqlserver"
      deletion_protection = false
      tier                = "db-custom-2-7680"

      # https://cloud.google.com/sql/docs/postgres/pg-audit
      #https://kb.objectrocket.com/postgresql/how-to-run-an-sql-file-in-postgres-846
      # https://hub.docker.com/_/postgres
      db_flags = {
      }

      database = "cloud_freak"
    }

  }

}

variable "project_id" {
  type        = string
  description = "GCP project to deploy to"
}

variable "region" {
  type        = string
  description = "GCP region to deploy to"
}

variable "name_format" {
  type        = string
  default     = "gcp-test-%s"
  description = "name prefix"
}

# variable "database_instance_count" {
#   default = 2
# }

variable "random_int_keeper" {
  default     = 1
  type        = number
  description = "random number"
}

# variable "config_bucket_name" {
#   type = string
# }
