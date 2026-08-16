# ALB用セキュリティグループ
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.env}-sg-alb"
  description = "for ALB"
  vpc_id      = aws_vpc.main.id

  # ingress {
  #   description = "HTTP from allow_ip"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [var.allow_ip]
  # }

  ingress {
    description = "HTTPS from allow_ip"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allow_ip]
  }

  # egress {
  #   description = "To ECS container"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   security_groups = [aws_security_group.container.id]
  # }

  tags = {
    Name = "${var.project}-${var.env}-sg-alb"
  }
}

# コンテナ用セキュリティグループ
resource "aws_security_group" "container" {
  name        = "${var.project}-${var.env}-sg-container"
  description = "Private container SG: HTTP in, all out to NAT Instance"
  vpc_id      = aws_vpc.main.id

  # ingress {
  #   description     = "HTTP from ALB"
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.alb.id]
  # }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-container"
  }
}

# ALB、コンテナのSG参照エラー回避のためにルールを後書き
resource "aws_security_group_rule" "alb_egress_to_ecs" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.container.id
}
resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.container.id
  source_security_group_id = aws_security_group.alb.id
}




# NATインスタンス用セキュリティグループ
resource "aws_security_group" "nat" {
  name        = "${var.project}-${var.env}-sg-nat"
  description = "for NAT instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "All TCP from container SG"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.container.id]
  }

  ingress {
    description     = "SSH from ICE"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.ice.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-nat"
  }
}

# EC2 Instance Connect Endpoint用セキュリティグループ
resource "aws_security_group" "ice" {
  name        = "${var.project}-${var.env}-sg-ice"
  description = "for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.main.id

  # ingress {
  #   description = "SSH from my IP"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [var.my_ip]
  # }

  egress {
    description = "SSH to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-ice"
  }
}

# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.public_1c.id
  security_group_ids = [aws_security_group.ice.id]

  tags = {
    Name = "${var.project}-${var.env}-ice"
  }
}

# EC2 Instance ConnectのマネージドプレフィックスリストをAWSから取得
data "aws_ec2_managed_prefix_list" "ice" {
  name = "com.amazonaws.ap-northeast-1.ec2-instance-connect"
}