data "aws_iam_role" "fargate_redash" {
  name = "${var.site_id}-fargate-redash"
}

resource "aws_iam_role_policy" "fargate_redash_secrets_manager" {
  name   = "${data.aws_iam_role.fargate_redash.name}-secrets-manager"
  policy = data.aws_iam_policy_document.fargate_redash_secrets_manager.json
  role   = data.aws_iam_role.fargate_redash.id
}

data "aws_iam_policy_document" "fargate_redash_secrets_manager" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = aws_secretsmanager_secret.fargate_redash.*.arn
  }
}

