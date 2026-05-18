resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-public-rt"
    Type = "route-table"
    Tier = "public"
  })
}

resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-private-rt-${count.index + 1}"
    Type = "route-table"
    Tier = "private"
  })
}

resource "aws_route" "private_nat" {
  count = local.nat_gateway_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "public" {
  count = var.public_subnet_count

  subnet_id      = aws_subnet.public_eks[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_eks" {
  count = var.private_subnet_count

  subnet_id      = aws_subnet.private_eks[count.index].id
  route_table_id = aws_route_table.private[count.index % local.nat_gateway_count].id
}

resource "aws_route_table_association" "private_rds" {
  count = var.private_subnet_count

  subnet_id      = aws_subnet.private_rds[count.index].id
  route_table_id = aws_route_table.private[count.index % local.nat_gateway_count].id
}

resource "aws_route_table_association" "private_tunnel" {
  count = var.private_subnet_count

  subnet_id      = aws_subnet.private_tunnel[count.index].id
  route_table_id = aws_route_table.private[count.index % local.nat_gateway_count].id
}
