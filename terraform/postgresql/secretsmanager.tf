output "aws_secretsmanager_secret_fargate_redash_arns" { value = "${aws_secretsmanager_secret.fargate_redash.*.arn}" }

locals {
  secrets = [
    {
      name          = "${var.site_id}-fargate/redash-db-url"
      description   = "The Redash database URL including password"
      secret_string = "postgresql://redash:${random_string.role_redash_password.result}@${data.aws_db_instance.fargate_pg.address}/redash"
    }
  ]
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
