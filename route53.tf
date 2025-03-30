resource "aws_route53_zone" "main" {
  name = var.domain_name
}


resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "dev.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.instance_public_ip]
}

resource "aws_route53_record" "demo" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "demo.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.instance_public_ip]
}