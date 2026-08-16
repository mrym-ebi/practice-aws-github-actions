# 既存のホストゾーンをdataで参照
data "aws_route53_zone" "main" {
  name = "everbeacon.net"
}

# ALBへのAレコード
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "everbeacon.net"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}