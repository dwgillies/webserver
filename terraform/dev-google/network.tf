resource "google_project_service" "apis" {
  for_each = toset(["compute.googleapis.com", "dns.googleapis.com"])

  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "main" {
  name                    = var.name
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

# Google subnets are regional and span every zone in the region, so one of
# each is the equivalent of the AWS pair-per-AZ layout. "Public" only means
# instances here may have external IPs; routing is the same for both.
resource "google_compute_subnetwork" "public" {
  name          = "${var.name}-public"
  network       = google_compute_network.main.id
  region        = var.region
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, 0)
}

resource "google_compute_subnetwork" "private" {
  name          = "${var.name}-private"
  network       = google_compute_network.main.id
  region        = var.region
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, 10)

  # reach Google APIs without going through the NAT
  private_ip_google_access = true
}

# Cloud NAT gives the private subnet outbound internet access (to install
# docker and pull the image); it's a managed service, not an instance, and
# is highly available within the region
resource "google_compute_router" "main" {
  name    = var.name
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_router_nat" "main" {
  name   = var.name
  router = google_compute_router.main.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
