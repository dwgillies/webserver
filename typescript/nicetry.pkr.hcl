# Packer template: the same app as the Dockerfile, baked into a Compute
# Engine image instead of a container image. Each block below notes which
# Dockerfile instruction it replaces.
#
#   make js                                  # compile main.js and App.js first
#   packer init nicetry.pkr.hcl              # download the googlecompute plugin
#   packer build nicetry.pkr.hcl             # ~5 min; prints the image name
#
# Packer boots a temporary VM, so it needs a network with internet access and
# SSH allowed from this machine ("default" has both if the project still has
# its auto-created default network), and uses Application Default Credentials.

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "project_id" {
  type    = string
  default = "dwgillies-dev"
}

variable "zone" {
  type    = string
  default = "us-west1-b"
}

variable "network" {
  type    = string
  default = "default"
}

# FROM node:22-slim: a container image starts from another image's
# filesystem; a VM image starts from a bootable OS image, and Node is
# installed by the first provisioner below
source "googlecompute" "nicetry" {
  project_id          = var.project_id
  zone                = var.zone
  network             = var.network
  machine_type        = "e2-small" # only for the build VM, deleted afterwards
  source_image_family = "debian-12"
  ssh_username        = "packer"

  image_name   = "nicetry-{{timestamp}}"
  image_family = "nicetry" # Terraform can ask for the newest image in the family

  # LABEL maintainer=...: label values can't contain spaces or @, so the
  # full maintainer goes in the description
  image_description = "nicetry webserver; maintainer Don Gillies <dwgillies@gmail.com>"
  image_labels      = { app = "nicetry" }
}

build {
  sources = ["source.googlecompute.nicetry"]

  # (the node:22-slim part of FROM) Node 22 from NodeSource, plus the
  # unprivileged "node" user that the node image provides
  provisioner "shell" {
    inline = [
      "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo useradd --system --no-create-home --shell /usr/sbin/nologin node",
      # WORKDIR /srv/webserver/typescript
      "sudo mkdir -p /srv/webserver/typescript",
      "mkdir -p /tmp/app",
    ]
  }

  # COPY package.json package-lock.json ./  and  COPY *.js ./
  # (the file provisioner uploads as the ssh user, who can't write to /srv,
  # so files go to /tmp first and are moved with sudo)
  provisioner "file" {
    sources = [
      "${path.root}/package.json",
      "${path.root}/package-lock.json",
      "${path.root}/main.js",
      "${path.root}/App.js",
    ]
    destination = "/tmp/app/"
  }

  # RUN npm ci --omit=dev
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/app/* /srv/webserver/typescript/",
      "cd /srv/webserver/typescript && sudo npm ci --omit=dev",
    ]
  }

  # ENV, USER, EXPOSE and CMD: on a VM, systemd starts the app, so these
  # become a service unit. Restart=always plays the part of
  # docker run --restart unless-stopped
  provisioner "file" {
    content     = <<-EOF
      [Unit]
      Description=nicetry webserver
      After=network-online.target
      Wants=network-online.target

      [Service]
      WorkingDirectory=/srv/webserver/typescript
      Environment=NODE_ENV=production
      User=node
      ExecStart=/usr/bin/node ./main.js
      Restart=always
      # Docker let the non-root node user bind port 80; on a VM that needs
      # this capability (EXPOSE 80 itself was only documentation)
      AmbientCapabilities=CAP_NET_BIND_SERVICE

      [Install]
      WantedBy=multi-user.target
    EOF
    destination = "/tmp/nicetry.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/nicetry.service /etc/systemd/system/",
      "sudo systemctl enable nicetry", # start at every boot
    ]
  }
}
