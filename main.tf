provider "aws" {

region = "us-east-1"

}


resource "aws_instance" "web" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t3.medium"
  count = 1
  vpc_security_group_ids = [
    "sg-0a6afd996f8086e94"
  ]
  key_name = "onekey"
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
 tags = {
    Name = "webinstance"
  }

}


resource "aws_instance" "db" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t3.medium"
  count = 1
  vpc_security_group_ids = [
    "sg-0a6afd996f8086e94"
  ]
key_name = "onekey"
subnet_id = aws_subnet.private.id
 tags = {
    Name = "dbinstance"
  }

}


resource "aws_subnet" "public" {
    vpc_id = "vpc-0f1f4563855f22c8a"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}


resource "aws_subnet" "private" {
    vpc_id = "vpc-0f1f4563855f22c8a"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = false
}






resource "aws_internet_gateway" "ig" {
  vpc_id = "vpc-0f1f4563855f22c8a"
  tags = {
    Name        = "igw"
  }
}


resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}


/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public.id}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
  }
}




resource "aws_route_table" "private" {
  vpc_id = "vpc-0f1f4563855f22c8a"
  tags = {
    Name        = "private-route-table"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "vpc-0f1f4563855f22c8a"
  tags = {
    Name        = "public-route-table"
  }
}




resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}





resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}
