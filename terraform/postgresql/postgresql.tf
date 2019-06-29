output "postgresql_role_redash_password" { value = "${postgresql_role.redash.password}" }

data "aws_db_instance" "fargate_pg" {
  db_instance_identifier = "${var.site_id}-fargate-pg"
}

provider "postgresql" {
  host            = "${data.aws_db_instance.fargate_pg.address}"
  port            = 5432
  database        = "postgres"
  username        = "root"
  password        = "${var.db_root_password}"
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

resource "random_string" "role_redash_password" {
  length  = 32
  special = false
}
resource "postgresql_role" "redash" {
  name     = "redash"
  login    = true
  password = "${random_string.role_redash_password.result}"
}
resource "postgresql_database" "database_redash" {
  name              = "redash"
  owner             = "${postgresql_role.redash.name}"
  allow_connections = true
  lc_collate        = "DEFAULT"
  lc_ctype          = "DEFAULT"

  lifecycle {
    ignore_changes = [
      "lc_collate",
      "lc_ctype"
    ]
  }
}
