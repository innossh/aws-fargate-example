output "aws_security_group_fargate_redash_id" {
  value = aws_security_group.fargate_redash.id
}

resource "aws_ecs_cluster" "fargate" {
  name = "${var.site_id}-fargate"

  tags = {
    Owner = var.owner
  }
}

resource "aws_security_group" "fargate_redash" {
  name        = "${var.site_id}-fargate-redash"
  description = "Security group for Redash on Fargate"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name  = "${var.site_id}-fargate-redash"
    Owner = var.owner
  }
}

resource "aws_security_group_rule" "fargate_redash_ingress_http" {
  type                     = "ingress"
  from_port                = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fargate_redash.id
  source_security_group_id = aws_security_group.lb_fargate_redash.id
  to_port                  = 5000
  description              = "Allow http inbound traffic from load balancer"
}

resource "aws_security_group_rule" "fargate_redash_egress_all" {
  type = "egress"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fargate_redash.id
  to_port           = 0
  description       = "Allow all outbound traffic"
}

