output "aws_db_instance_fargate_pg_address" { value = "${aws_db_instance.fargate_pg.address}" }
output "aws_db_instance_fargate_pg_password" { value = "${aws_db_instance.fargate_pg.password}" }

resource "random_string" "fargate_pg_password" {
  length  = 32
  special = false
}

resource "aws_db_instance" "fargate_pg" {
  allocated_storage          = 50
  apply_immediately          = true
  auto_minor_version_upgrade = true
  availability_zone          = "${var.aws_region}${local.vpc_az[0]}"
  backup_retention_period    = 7
  backup_window              = "00:05-00:35"
  db_subnet_group_name       = "${aws_db_subnet_group.fargate_pg.name}"
  engine                     = "postgres"
  engine_version             = "11.2"
  final_snapshot_identifier  = "${var.site_id}-fargate-pg-final"
  identifier                 = "${var.site_id}-fargate-pg"
  instance_class             = "db.t2.micro"
  maintenance_window         = "mon:12:00-mon:12:30"
  multi_az                   = false
  parameter_group_name       = "${aws_db_parameter_group.fargate_pg.name}"
  password                   = "${random_string.fargate_pg_password.result}"
  port                       = 5432
  publicly_accessible        = true
  storage_type               = "gp2"
  username                   = "root"
  vpc_security_group_ids = [
    "${aws_security_group.fargate_pg.id}"
  ]

  tags = {
    Owner = "${var.owner}"
  }
}
resource "aws_db_subnet_group" "fargate_pg" {
  name       = "${var.site_id}-fargate-pg"
  subnet_ids = "${aws_subnet.main_public.*.id}"

  tags = {
    Owner = "${var.owner}"
  }
}
resource "aws_db_parameter_group" "fargate_pg" {
  name   = "${var.site_id}-faragate-pg"
  family = "postgres11"

  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = 3000
  }

  tags = {
    Owner = "${var.owner}"
  }
}

resource "aws_security_group" "fargate_pg" {
  name        = "${var.site_id}-fargate-pg"
  description = "Security group for Fargate database"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name  = "${var.site_id}-fargate-pg"
    Owner = "${var.owner}"
  }
}
resource "aws_security_group_rule" "fargate_pg_ingress_fargate_redash" {
  type                     = "ingress"
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.fargate_pg.id}"
  source_security_group_id = "${aws_security_group.fargate_redash.id}"
  to_port                  = 5432
  description              = "Allow postgres inbound traffic from Redash on Fargate"
}
resource "aws_security_group_rule" "fargate_pg_ingress_office" {
  type = "ingress"
  cidr_blocks = [
    "${var.cidr_office}"
  ]
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = "${aws_security_group.fargate_pg.id}"
  to_port           = 5432
  description       = "Allow postgres inbound traffic from my office"
}
