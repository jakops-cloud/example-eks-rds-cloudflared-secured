# Private Subnets
resource "aws_subnet" "private_tunnel" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-private-subnet-tunnel-${count.index + 1}${data.aws_availability_zones.available.names[count.index]}"
    Type = "private-subnet"
    Tier = "private"
    "kubernetes.io/cluster/${var.environment}-${var.project}-tunnel" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  })
}