output "aws_secretsmanager_secret_fargate_arns" { value = "${aws_secretsmanager_secret.fargate.*.arn}" }

locals {
  secrets = [
    {
      name          = "${var.site_id}-fargate/db-password"
      description   = "Password of the Redash database"
      secret_string = "${random_string.role_redash_password.result}"
    }
  ]
}

resource "aws_secretsmanager_secret" "fargate" {
  count = "${length(local.secrets)}"

  name        = "${lookup(local.secrets[count.index], "name")}"
  description = "${lookup(local.secrets[count.index], "description")}"

  tags = {
    Owner = "${var.owner}"
  }
}
resource "aws_secretsmanager_secret_version" "fargate" {
  count = "${length(local.secrets)}"

  secret_id     = "${aws_secretsmanager_secret.fargate.*.id[count.index]}"
  secret_string = "${lookup(local.secrets[count.index], "secret_string")}"
}
