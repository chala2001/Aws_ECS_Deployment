# One map drives everything: add an AZ here and every tier gets a subnet in it.
locals {
  azs = {
    a = "${var.region}a"
    b = "${var.region}b"
  }
  public_cidrs  = { a = "10.0.1.0/24", b = "10.0.2.0/24" }
  private_cidrs = { a = "10.0.11.0/24", b = "10.0.12.0/24" }
  data_cidrs    = { a = "10.0.21.0/24", b = "10.0.22.0/24" }
}

# ---------- The VPC: your private network ----------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true # needed later for RDS endpoints and VPC endpoints

  tags = { Name = "${var.project}-vpc" }
}

# ---------- Internet Gateway: the VPC's two-way door to the internet ----------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}

# ---------- Subnets: 3 tiers x 2 AZs = 6 subnets ----------
resource "aws_subnet" "public" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value
  cidr_block              = local.public_cidrs[each.key]
  map_public_ip_on_launch = true # things launched here get a public IP (ALB, NAT)

  tags = { Name = "${var.project}-public-${each.key}", Tier = "public" }
}

resource "aws_subnet" "private" {
  for_each          = local.azs
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = local.private_cidrs[each.key]

  tags = { Name = "${var.project}-private-${each.key}", Tier = "private-app" }
}

resource "aws_subnet" "data" {
  for_each          = local.azs
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = local.data_cidrs[each.key]

  tags = { Name = "${var.project}-data-${each.key}", Tier = "data" }
}
