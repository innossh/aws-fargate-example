output "aws_subnet_main_public_id_0" {
  value = aws_subnet.main_public[0].id
}

output "aws_subnet_main_public_id_1" {
  value = aws_subnet.main_public[1].id
}

output "aws_subnet_main_public_id_2" {
  value = aws_subnet.main_public[2].id
}

output "aws_subnet_main_private_id_0" {
  value = aws_subnet.main_private[0].id
}

output "aws_subnet_main_private_id_1" {
  value = aws_subnet.main_private[1].id
}

output "aws_subnet_main_private_id_2" {
  value = aws_subnet.main_private[2].id
}

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false

  tags = {
    Name  = "${var.site_id}-main"
    Owner = var.owner
  }
}

resource "aws_subnet" "main_public" {
  count = length(local.vpc_az)

  availability_zone       = "${var.aws_region}${local.vpc_az[count.index]}"
  cidr_block              = local.vpc_subnet_public_cidr_blocks[local.vpc_az[count.index]]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name  = "${var.site_id}-main-public-${local.vpc_az[count.index]}"
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Owner = var.owner
    Name  = "${var.site_id}-main"
  }
}

resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "main_private" {
  count = length(local.vpc_az)

  availability_zone       = "${var.aws_region}${local.vpc_az[count.index]}"
  cidr_block              = local.vpc_subnet_private_cidr_blocks[local.vpc_az[count.index]]
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name  = "${var.site_id}-main-private-${local.vpc_az[count.index]}"
    Owner = var.owner
  }
}

resource "aws_route_table" "main_private" {
  count = length(local.vpc_az)

  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_public[count.index].id
  }
}

resource "aws_route_table_association" "main_private" {
  count = length(local.vpc_az)

  subnet_id      = aws_subnet.main_private[count.index].id
  route_table_id = aws_route_table.main_private[count.index].id
}

resource "aws_nat_gateway" "main_public" {
  count = length(local.vpc_az)

  allocation_id = aws_eip.main_public_nat_gw[count.index].id
  subnet_id     = aws_subnet.main_public[count.index].id

  tags = {
    Name  = "${var.site_id}-main-public-${local.vpc_az[count.index]}"
    Owner = var.owner
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "main_public_nat_gw" {
  count = length(local.vpc_az)

  vpc = true
  tags = {
    Name  = "${var.site_id}-main-public-nat-gw-${local.vpc_az[count.index]}"
    Owner = var.owner
  }
}

