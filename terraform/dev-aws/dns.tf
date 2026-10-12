locals {
  use_dns   = var.domain_name != ""
  site_fqdn = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
}

# after the first apply, set your registrar's name servers to the
# hosted_zone_name_servers output
resource "aws_route53_zone" "site" {
  count = local.use_dns ? 1 : 0

  name = var.domain_name
}

resource "aws_route53_record" "site" {
  count = local.use_dns ? 1 : 0

  zone_id = aws_route53_zone.site[0].zone_id
  name    = local.site_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "site" {
  count = var.enable_https ? 1 : 0

  domain_name       = local.site_fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = local.use_dns
      error_message = "enable_https requires domain_name."
    }
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = var.enable_https ? {
    for o in aws_acm_certificate.site[0].domain_validation_options : o.domain_name => o
  } : {}

  zone_id = aws_route53_zone.site[0].zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "site" {
  count = var.enable_https ? 1 : 0

  certificate_arn         = aws_acm_certificate.site[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# delegates gcp.<domain_name> to the Cloud DNS zone created by dev-google
resource "aws_route53_record" "gcp_delegation" {
  count = local.use_dns && length(var.gcp_name_servers) > 0 ? 1 : 0

  zone_id = aws_route53_zone.site[0].zone_id
  name    = "gcp.${var.domain_name}"
  type    = "NS"
  ttl     = 300
  records = var.gcp_name_servers
}
