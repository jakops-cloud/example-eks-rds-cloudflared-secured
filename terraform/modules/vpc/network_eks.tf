# Public Subnets
resource "aws_subnet" "public_eks" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-public-subnet-eks-${count.index + 1}${data.aws_availability_zones.available.names[count.index]}"
    Type = "public-subnet"
    Tier = "public"
    "kubernetes.io/cluster/${var.environment}-${var.project}-eks" = "owned"
    "kubernetes.io/role/elb" = "1"
  })
}

# Private Subnets
resource "aws_subnet" "private_eks" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-private-subnet-eks-${count.index + 1}${data.aws_availability_zones.available.names[count.index]}"
    Type = "private-subnet"
    Tier = "private"
    "kubernetes.io/cluster/${var.environment}-${var.project}-eks" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery" = "${var.environment}-${var.project}-eks"
  })
}