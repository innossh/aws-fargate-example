output "aws_iam_role_fargate_task_arn" { value = "${aws_iam_role.fargate_task.arn}" }

resource "aws_iam_role" "fargate_task" {
  name               = "${var.site_id}-fargate-task"
  assume_role_policy = "${data.aws_iam_policy_document.fargate_task_assume_role.json}"
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
resource "aws_iam_role_policy_attachment" "fargate_task" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
  role       = "${aws_iam_role.fargate_task.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy" "fargate_task_secrets_manager" {
  name   = "${aws_iam_role.fargate_task.name}-secrets-manager"
  policy = "${data.aws_iam_policy_document.fargate_task_secrets_manager.json}"

  role = "${aws_iam_role.fargate_task.id}"

}
data "aws_iam_policy_document" "fargate_task_secrets_manager" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = "${aws_secretsmanager_secret.fargate.*.arn}"
  }
}
