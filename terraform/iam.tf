output "aws_iam_role_fargate_redash_arn" {
  value = aws_iam_role.fargate_redash.arn
}

resource "aws_iam_role" "fargate_redash" {
  name               = "${var.site_id}-fargate-redash"
  assume_role_policy = data.aws_iam_policy_document.fargate_task_assume_role.json
}

data "aws_iam_policy_document" "fargate_task_assume_role" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_IAM_role.html
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "fargate_redash" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
  role       = aws_iam_role.fargate_redash.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

