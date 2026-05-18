resource "aws_subnet" "private_rds" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-private-subnet-rds-${count.index + 1}${data.aws_availability_zones.available.names[count.index]}"
    Type = "private-subnet"
    Tier = "private"
  })
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment}-${var.project}-rds-subnet-group"
  subnet_ids = aws_subnet.private_rds[*].id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-rds-subnet-group"
  })
}