data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}.${var.sub_domain_name}"
  private_zone = false
}

resource "aws_route53_record" "app_alias" {
  count   = local.is_dev ? 0 : 1
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.app_load_balancer.dns_name
    zone_id                = aws_lb.app_load_balancer.zone_id
    evaluate_target_health = true
  }
}
