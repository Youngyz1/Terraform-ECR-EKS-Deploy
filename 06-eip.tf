resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.main_vpc}-nat_eip"
  }
}