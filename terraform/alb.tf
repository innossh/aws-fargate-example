output "aws_lb_fargate_redash_arn" { value = "${aws_lb.fargate_redash.arn}" }

locals {
  elb_account_ids = {
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
    "ap-northeast-1" = "582318560864"
  }
}

data "aws_s3_bucket" "lb_fargate_log" {
  bucket = "${var.s3_bucket_name}"
}
resource "aws_lb" "fargate_redash" {
  name               = "${var.site_id}-fargate-redash"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_fargate_redash.id}"]
  access_logs {
    bucket  = "${var.s3_bucket_name}"
    prefix  = "fargate-redash"
    enabled = true
  }
  subnets         = "${aws_subnet.main_private.*.id}"
  ip_address_type = "ipv4"

  tags = {
    Owner = "${var.owner}"
  }
}
resource "aws_security_group" "lb_fargate_redash" {
  name        = "${var.site_id}-lb-fargate-redash"
  description = "Security group of LB for Redash on Fargate"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name  = "${var.site_id}-lb-fargate-redash"
    Owner = "${var.owner}"
  }
}
resource "aws_security_group_rule" "lb_fargate_redash_ingress_http" {
  type = "ingress"
  cidr_blocks = [
    "${var.cidr_office}"
  ]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.lb_fargate_redash.id}"
  to_port           = 80
  description       = "Allow http inbound traffic from my office"
}
resource "aws_security_group_rule" "lb_fargate_redash_egress_all" {
  type = "egress"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.lb_fargate_redash.id}"
  to_port           = 0
  description       = "Allow all outbound traffic"
}
resource "aws_s3_bucket_policy" "lb_fargate_redash_log" {
  bucket = "${data.aws_s3_bucket.lb_fargate_log.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${data.aws_s3_bucket.lb_fargate_log.id}/fargate-redash/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "AWS": [
          "${lookup(local.elb_account_ids, var.aws_region)}"
        ]
      }
    }
  ]
}
POLICY
}
resource "aws_lb_listener" "fargate_redash_http" {
  load_balancer_arn = "${aws_lb.fargate_redash.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.fargate_redash_http.arn}"
  }
}
resource "aws_lb_target_group" "fargate_redash_http" {
  name = "fargate-redash-http"
  port = 5000
  protocol = "HTTP"
  vpc_id = "${aws_vpc.main.id}"
  target_type = "ip"
}
