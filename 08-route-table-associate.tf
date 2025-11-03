# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.main_vpc}-public-rt"
  }
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.main_vpc}-private-rt"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  for_each = {
    public1 = aws_subnet.public["public-1"].id
    public2 = aws_subnet.public["public-2"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "r" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#associate private ip to the nat gateway
resource "aws_route_table_association" "private_subnet_assoc" {
  for_each = {
    private1 = aws_subnet.private["private-1"].id
    private2 = aws_subnet.private["private-2"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "r1" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}