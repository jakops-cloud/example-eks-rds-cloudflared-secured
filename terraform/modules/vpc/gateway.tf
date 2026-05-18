resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-igw"
    Type = "internet-gateway"
  })
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-nat-eip-${count.index + 1}"
    Type = "elastic-ip"
  })
}

resource "aws_nat_gateway" "main" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_eks[count.index].id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-nat-gateway-${count.index + 1}"
    Type = "nat-gateway"
  })

  depends_on = [aws_internet_gateway.main]
}
