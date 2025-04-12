locals {
  is_dev = var.profile == "dev"
}


data "aws_acm_certificate" "issued" {
  count    = local.is_dev ? 1 : 0
  domain   = "${var.domain_name}.${var.sub_domain_name}"
  statuses = ["ISSUED"]
}

locals {
  cert_arn = local.is_dev ? data.aws_acm_certificate.issued[0].arn : var.certificate_arn
}

