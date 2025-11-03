# ---------- Create Subnets (Public & Private) ----------
locals {
  public_subnets = {
    public-1 = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    public-2 = { cidr = "10.0.2.0/24", az = "us-east-1b" }
  }

  private_subnets = {
    private-1 = { cidr = "10.0.3.0/24", az = "us-east-1a" }
    private-2 = { cidr = "10.0.4.0/24", az = "us-east-1b" }
  }
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.main_vpc}-public"
  }
}

resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.main_vpc}-private"
  }
}
