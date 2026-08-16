# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project}-${var.env}-vpc"
  }
}

# パブリックサブネット
resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project}-${var.env}-subnet-pub-1c"
  }
}

resource "aws_subnet" "public_1d" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1d"

  tags = {
    Name = "${var.project}-${var.env}-subnet-pub-1d"
  }
}

# プライベートサブネット
resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project}-${var.env}-subnet-pri-1c"
  }
}

resource "aws_subnet" "private_1d" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1d"

  tags = {
    Name = "${var.project}-${var.env}-subnet-pri-1d"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-igw"
  }
}

# ルートテーブル（パブリック用）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project}-${var.env}-rtb-public"
  }
}

# ルートテーブル（プライベート用）
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = {
    Name = "${var.project}-${var.env}-rtb-private"
  }
}

# パブリックサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1d" {
  subnet_id      = aws_subnet.public_1d.id
  route_table_id = aws_route_table.public.id
}

# プライベートサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1d" {
  subnet_id      = aws_subnet.private_1d.id
  route_table_id = aws_route_table.private.id
}







