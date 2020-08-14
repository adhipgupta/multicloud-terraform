resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags       = var.tags
}

resource "aws_subnet" "subnet" {
  count             = length(var.subnet_names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(keys(var.subnet_names), count.index)
  availability_zone = element(values(var.subnet_zones), count.index)
  tags = {
    "Name" = element(values(var.subnet_names), count.index)
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

//This security group allows IKE and SSH traffic from all IP addresses.
resource "aws_security_group" "allowSSHIpsecIcmp" {
  name        = "allow_ipsec_ssh_ping"
  description = "Allow SSH/ICMP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "icmp"
    from_port   = "-1"
    to_port     = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

//SSH Route through the IGW
resource "aws_route" "defaultRoute" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet[0].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair1"
  public_key = var.public_key
}

resource "aws_instance" "vm" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet[0].id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.key_name
  vpc_security_group_ids      = [aws_security_group.allowSSHIpsecIcmp.id]
}
