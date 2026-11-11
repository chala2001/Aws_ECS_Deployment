# ---------- NAT: one per AZ, so losing one AZ doesn't cut off the other ----------
resource "aws_eip" "nat" {
  for_each = local.azs
  domain   = "vpc"
  tags     = { Name = "${var.project}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each      = local.azs
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id # NAT lives in the PUBLIC subnet
  depends_on    = [aws_internet_gateway.igw]

  tags = { Name = "${var.project}-nat-${each.key}" }
}

# ---------- Public route table: internet traffic -> Internet Gateway ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project}-rt-public" }
}

resource "aws_route_table_association" "public" {
  for_each       = local.azs
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# ---------- Private route tables: internet traffic -> NAT in the SAME AZ ----------
resource "aws_route_table" "private" {
  for_each = local.azs
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }
  tags = { Name = "${var.project}-rt-private-${each.key}" }
}

resource "aws_route_table_association" "private" {
  for_each       = local.azs
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# ---------- Data route table: NO internet route at all ----------
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-rt-data" }
}

resource "aws_route_table_association" "data" {
  for_each       = local.azs
  subnet_id      = aws_subnet.data[each.key].id
  route_table_id = aws_route_table.data.id
}
