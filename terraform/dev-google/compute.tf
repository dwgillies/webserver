locals {
  ssh_keys = "${var.ssh_user}:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"

  # how the web container is started, used both by the startup script and by
  # the redeploy_command output (make redeploy), so the two can't drift apart;
  # gcplogs sends the container's output to Cloud Logging, using the VM's
  # service account (roles/logging.logWriter)
  docker_run = join(" ", [
    "docker run -d --restart unless-stopped --name webserver -p 80:80",
    "--log-driver gcplogs",
    var.container_image,
  ])
}

# a dedicated identity for the instances, allowed only to write logs and
# metrics (the default compute service account has broad Editor access)
resource "google_service_account" "instance" {
  account_id   = "${var.name}-instance"
  display_name = "${var.name} instances"
}

resource "google_project_iam_member" "instance" {
  for_each = toset(["roles/logging.logWriter", "roles/monitoring.metricWriter"])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.instance.email}"
}

resource "google_compute_instance" "bastion" {
  name         = "${var.name}-bastion"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["bastion"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.id

    # an empty access_config gives the instance an ephemeral external IP
    access_config {}
  }

  metadata = {
    ssh-keys = local.ssh_keys
  }

  service_account {
    email  = google_service_account.instance.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }
}

resource "google_compute_instance" "web" {
  name         = "${var.name}-web"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-standard"
    }
  }

  # no access_config, so no external IP; outbound traffic goes through Cloud NAT
  network_interface {
    subnetwork = google_compute_subnetwork.private.id
  }

  metadata = {
    ssh-keys = local.ssh_keys
  }

  # changing the startup script re-creates the instance
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    if ! command -v docker >/dev/null; then
      apt-get update
      apt-get install -y docker.io
    fi
    systemctl enable --now docker
    docker rm -f webserver 2>/dev/null || true
    ${local.docker_run}
  EOF

  service_account {
    email  = google_service_account.instance.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  # the instance needs the NAT to install docker and pull the image
  depends_on = [google_compute_router_nat.main]
}

# load balancer backends are instance groups, not individual instances; an
# unmanaged group is the closest match to the AWS target group attachment
resource "google_compute_instance_group" "web" {
  name      = "${var.name}-web"
  zone      = var.zone
  instances = [google_compute_instance.web.self_link]

  named_port {
    name = "http"
    port = 80
  }
}
