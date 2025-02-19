# this is a data source which brings all the zones in a region and we are passsing the filter:state value:avaliable using which we can get all the avilable zones in that particular region
data "aws_availability_zones" "available" {
  state = "available"
}
# creating local scopedd variables to access whithin the same file 
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  subnet_newbits = var.subnet_prefix_length - tonumber(split("/", var.vpc_cidr)[1])

  public_subnets  = [for i in range(3) : cidrsubnet(var.vpc_cidr, local.subnet_newbits, i)]
  private_subnets = [for i in range(3) : cidrsubnet(var.vpc_cidr, local.subnet_newbits, i + 3)]
}

# main-VPC creation using tag to identify on the console
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

resource "aws_subnet" "public" {
  count                   = length(local.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.vpc_name}-public-${local.azs[count.index]}" }
}

resource "aws_subnet" "private" {
  count             = length(local.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]
  tags              = { Name = "${var.vpc_name}-private-${local.azs[count.index]}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.vpc_name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}