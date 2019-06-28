output "aws_elasticache_replication_group_fargate_cache_redis_primary_endpoint_address" { value = "${aws_elasticache_replication_group.fargate_cache_redis.primary_endpoint_address}" }

resource "aws_elasticache_replication_group" "fargate_cache_redis" {
  # "replication_group_id" must contain from 1 to 20 alphanumeric characters or hyphens
  replication_group_id          = "${var.site_id}-fargate-cache"
  replication_group_description = "Redis for Fargate"
  number_cache_clusters         = 2
  node_type                     = "cache.t2.micro"
  auto_minor_version_upgrade    = true
  engine                        = "redis"
  engine_version                = "5.0.4"
  parameter_group_name          = "${aws_elasticache_parameter_group.fargate_cache_redis.name}"
  port                          = 6379
  subnet_group_name             = ""
  security_group_ids = [
    "${aws_security_group.fargate_cache_redis.id}"
  ]
  maintenance_window = "mon:12:00-mon:12:30"

  tags = {
    Owner = "${var.owner}"
  }
}
resource "aws_elasticache_subnet_group" "fargate_cahche_redis" {
  name        = "${var.site_id}-fargate-cache-redis"
  description = "Subnet group for Fargate cache"
  subnet_ids  = "${aws_subnet.main_public.*.id}"
}
resource "aws_elasticache_parameter_group" "fargate_cache_redis" {
  name        = "${var.site_id}-fargate-cache-redis"
  family      = "redis5.0"
  description = "Customized redis5.0 parameter group for Fargate"

  parameter {
    name  = "timeout"
    value = "3600"
  }
}
resource "aws_security_group" "fargate_cache_redis" {
  name        = "${var.site_id}-fargate-cache-redis"
  description = "Security group for Fargate cache"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name  = "${var.site_id}-fargate-cache-redis"
    Owner = "${var.owner}"
  }
}
resource "aws_security_group_rule" "fargate_cache_redis_ingress_fargate_task" {
  type                     = "ingress"
  from_port                = 6379
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.fargate_cache_redis.id}"
  source_security_group_id = "${aws_security_group.fargate_task.id}"
  to_port                  = 6379
  description              = "Allow redis inbound traffic from Fargate task"
}
resource "aws_security_group_rule" "fargate_cache_redis_ingress_office" {
  type = "ingress"
  cidr_blocks = [
    "${var.cidr_office}"
  ]
  from_port         = 6379
  protocol          = "tcp"
  security_group_id = "${aws_security_group.fargate_cache_redis.id}"
  to_port           = 6379
  description       = "Allow redis inbound traffic from my office"
}
