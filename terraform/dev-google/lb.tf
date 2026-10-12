# Global external Application Load Balancer. Where AWS has one aws_lb with
# listeners, Google chains separate resources:
#   forwarding rule (IP:port) -> target proxy (HTTP/HTTPS) -> URL map (routing)
#   -> backend service (pool + health check) -> instance group
#
# resources that reference nothing else need depends_on the API enablement,
# or a fresh project creates them before the Compute Engine API is on

resource "google_compute_global_address" "lb" {
  name = "${var.name}-lb"

  depends_on = [google_project_service.apis]
}

# same timing as the AWS target group: every 15s, 5s timeout, 3 passes to
# mark healthy and 3 failures to mark unhealthy
resource "google_compute_health_check" "web" {
  name                = "${var.name}-web"
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/health"
  }

  depends_on = [google_project_service.apis]
}

resource "google_compute_backend_service" "web" {
  name                  = "${var.name}-web"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 60 # matches the AWS ALB's 60s idle timeout
  health_checks         = [google_compute_health_check.web.id]

  backend {
    group           = google_compute_instance_group.web.self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "web" {
  name            = "${var.name}-web"
  default_service = google_compute_backend_service.web.id
}

# with HTTPS on, port 80 only redirects
resource "google_compute_url_map" "https_redirect" {
  count = var.enable_https ? 1 : 0

  name = "${var.name}-https-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }

  depends_on = [google_project_service.apis]
}

resource "google_compute_target_http_proxy" "web" {
  name    = "${var.name}-http"
  url_map = var.enable_https ? google_compute_url_map.https_redirect[0].id : google_compute_url_map.web.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.name}-http"
  ip_address            = google_compute_global_address.lb.id
  port_range            = "80"
  target                = google_compute_target_http_proxy.web.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_managed_ssl_certificate" "site" {
  count = var.enable_https ? 1 : 0

  name = "${var.name}-site"

  managed {
    domains = [local.site_fqdn]
  }

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = local.use_dns
      error_message = "enable_https requires domain_name."
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_compute_ssl_policy" "modern" {
  count = var.enable_https ? 1 : 0

  name            = "${var.name}-modern"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"

  depends_on = [google_project_service.apis]
}

resource "google_compute_target_https_proxy" "web" {
  count = var.enable_https ? 1 : 0

  name             = "${var.name}-https"
  url_map          = google_compute_url_map.web.id
  ssl_certificates = [google_compute_managed_ssl_certificate.site[0].id]
  ssl_policy       = google_compute_ssl_policy.modern[0].id
}

resource "google_compute_global_forwarding_rule" "https" {
  count = var.enable_https ? 1 : 0

  name                  = "${var.name}-https"
  ip_address            = google_compute_global_address.lb.id
  port_range            = "443"
  target                = google_compute_target_https_proxy.web[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
