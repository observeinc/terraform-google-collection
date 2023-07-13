# locals {
#   domain     = "observeinc.com"
#   customer   = "126329491179"
#   user_email = "user@observeinc.com"
# }

# provider "aws" {
#   region = "us-west-2"
# }

# data "aws_secretsmanager_secret" "secret" {
#   name = format("tf-password-%s-%s", local.domain, local.customer)
# }

# data "aws_secretsmanager_secret_version" "secret" {
#   secret_id = data.aws_secretsmanager_secret.secret.id
# }

# provider "observe" {
#   customer      = local.customer
#   domain        = local.domain
#   user_email    = local.user_email
#   user_password = data.aws_secretsmanager_secret_version.secret.secret_string
# }

# provider "google"{
#   project = "joe-test-proj"
# }