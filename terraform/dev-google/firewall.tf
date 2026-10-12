# Google VPCs deny all ingress and allow all egress by default, so only
# ingress rules are needed. Rules select instances by network tag instead of
# attaching to them like AWS security groups.

resource "google_compute_firewall" "ssh_to_bastion" {
  name      = "${var.name}-ssh-to-bastion"
  network   = google_compute_network.main.id
  direction = "INGRESS"

  source_ranges = [var.admin_cidr]
  target_tags   = ["bastion"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "ssh_bastion_to_web" {
  name      = "${var.name}-ssh-bastion-to-web"
  network   = google_compute_network.main.id
  direction = "INGRESS"

  source_tags = ["bastion"]
  target_tags = ["web"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# the load balancer's proxies and health checkers connect from these
# Google-owned ranges, not from the client's address
resource "google_compute_firewall" "lb_to_web" {
  name      = "${var.name}-lb-to-web"
  network   = google_compute_network.main.id
  direction = "INGRESS"

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["web"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
