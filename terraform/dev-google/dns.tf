locals {
  use_dns   = var.domain_name != ""
  site_fqdn = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
}

# wgillies.net is already served by Route 53, so this zone is meant for a
# subdomain such as gcp.wgillies.net; delegate it by adding an NS record for
# that name in the Route 53 zone with the dns_name_servers output
resource "google_dns_managed_zone" "site" {
  count = local.use_dns ? 1 : 0

  name     = replace(var.domain_name, ".", "-")
  dns_name = "${var.domain_name}."

  depends_on = [google_project_service.apis]
}

resource "google_dns_record_set" "site" {
  count = local.use_dns ? 1 : 0

  managed_zone = google_dns_managed_zone.site[0].name
  name         = "${local.site_fqdn}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb.address]
}
