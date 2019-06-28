output "aws_security_group_fargate_task_id" { value = "${aws_security_group.fargate_task.id}" }

resource "aws_ecs_cluster" "fargate" {
  name = "${var.site_id}-fargate"

  tags = {
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "fargate_task" {
  name        = "${var.site_id}-fargate-task"
  description = "Security group for Fargate task"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name  = "${var.site_id}-fargate-task"
    Owner = "${var.owner}"
  }
}
resource "aws_security_group_rule" "fargate_task_ingress_http" {
  type = "ingress"
  cidr_blocks = [
    "${var.cidr_office}"
  ]
  from_port         = 5000
  protocol          = "tcp"
  security_group_id = "${aws_security_group.fargate_task.id}"
  to_port           = 5000
  description       = "Allow http inbound traffic from my office"
}
resource "aws_security_group_rule" "fargate_task_egress_all" {
  type = "egress"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.fargate_task.id}"
  to_port           = 0
  description       = "Allow all outbound traffic"
}
