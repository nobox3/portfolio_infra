locals {
  nat_gateway_azs = var.single_nat_gateway ? { keys(var.azs)[0] = values(var.azs)[0] } : var.azs
}

data "aws_region" "current" {}

# ----------------------------------------
# VPC
# ----------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_id}-main"
  }
}

# ----------------------------------------
# Internet Gateway
# ----------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = aws_vpc.this.tags.Name
  }
}

# ----------------------------------------
# Subnets
# ----------------------------------------
resource "aws_subnet" "public" {
  for_each = var.azs

  availability_zone       = "${data.aws_region.current.region}${each.key}"
  cidr_block              = each.value.public_cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.azs

  availability_zone       = "${data.aws_region.current.region}${each.key}"
  cidr_block              = each.value.private_cidr
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}

# ----------------------------------------
# NAT Gateway
# ----------------------------------------
resource "aws_eip" "nat_gateway" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {}

  domain = "vpc"

  tags = {
    Name = "${aws_vpc.this.tags.Name}-nat-gateway-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {}

  allocation_id = aws_eip.nat_gateway[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-${each.key}"
  }
}

# ----------------------------------------
# Route Tables
# ----------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public"
  }
}

resource "aws_route" "internet_gateway_public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  for_each = var.azs

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}

resource "aws_route_table" "private" {
  for_each = var.azs

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}

resource "aws_route" "nat_gateway_private" {
  for_each = var.enable_nat_gateway ? var.azs : {}

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? keys(var.azs)[0] : each.key].id
  route_table_id         = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = var.azs

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}

# ----------------------------------------
# Subnet Associations
# ----------------------------------------
resource "aws_db_subnet_group" "this" {
  name = aws_vpc.this.tags.Name

  subnet_ids = [for s in aws_subnet.private : s.id]

  tags = {
    Name = aws_vpc.this.tags.Name
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name = replace(aws_vpc.this.tags.Name, "_", "-")

  subnet_ids = [for s in aws_subnet.private : s.id]
}
