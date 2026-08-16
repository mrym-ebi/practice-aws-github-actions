# NATインスタンス用セキュリティグループは security_group.tf で定義するため
# ここではインスタンス本体のみ記述
# プライベートサブネットのタスクがECRへイメージを取得するために用意

resource "aws_instance" "nat" {
  ami                         = "ami-0a21a03072be95559"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1c.id
  source_dest_check           = false  # NATインスタンスに必須
  vpc_security_group_ids      = [aws_security_group.nat.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    # IPフォワーディングを有効にする
    sysctl -w net.ipv4.ip_forward=1
    # 再起動後も有効にする設定
    echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.d/custom-ip-forward.conf
    
    dnf install -y nftables
    # IPマスカレードを有効にする
    nft add table ip nat
    nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
    nft add rule ip nat postrouting oifname "ens5" counter masquerade
  EOF

  tags = {
    Name = "${var.project}-${var.env}-ec2-nat"
  }
}