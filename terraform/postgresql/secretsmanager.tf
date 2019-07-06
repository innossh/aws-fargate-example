output "aws_secretsmanager_secret_fargate_redash_arns" { value = "${aws_secretsmanager_secret.fargate_redash.*.arn}" }

locals {
  secrets = [
    {
      name          = "${var.site_id}-fargate/redash-db-url"
      description   = "The Redash database URL including password"
      secret_string = "postgresql://redash:${random_string.role_redash_password.result}@${data.aws_db_instance.fargate_pg.address}/redash"
    },
    {
      name          = "${var.site_id}-fargate/redash-redis-url"
      description   = "The Redash redis URL"
      secret_string = "redis://${aws_elasticache_replication_group.fargate_redis.primary_endpoint_address}:6379/0"
    },
    {
      name          = "${var.site_id}-fargate/redash-cookie-secret"
      description   = "The value of REDASH_COOKIE_SECRET"
      secret_string = "${random_string.redash_cookie_secret.result}"
    },
    {
      name          = "${var.site_id}-fargate/redash-secret-key"
      description   = "The value of REDASH_SECRET_KEY"
      secret_string = "${random_string.redash_secret_key.result}"
    }
  ]
}

data "aws_elasticache_replication_group" "fargate_redis" {
  replication_group_id = "${var.site_id}-fargate-redis"
}
resource "random_string" "redash_cookie_secret" {
  length  = 32
  special = false
}
resource "random_string" "redash_secret_key" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "fargate_redash" {
  count = "${length(local.secrets)}"

  name        = "${lookup(local.secrets[count.index], "name")}"
  description = "${lookup(local.secrets[count.index], "description")}"

  tags = {
    Owner = "${var.owner}"
  }
}
resource "aws_secretsmanager_secret_version" "fargate_redash" {
  count = "${length(local.secrets)}"

  secret_id     = "${aws_secretsmanager_secret.fargate_redash.*.id[count.index]}"
  secret_string = "${lookup(local.secrets[count.index], "secret_string")}"
}
