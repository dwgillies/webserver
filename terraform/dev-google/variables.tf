variable "project_id" {
  description = "Google Cloud project ID (not the project name or number)"
  type        = string
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "nicetry"
}

variable "region" {
  description = "Region for the network, subnets and NAT. us-west1, us-central1 and us-east1 have an always-free e2-micro."
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "Zone for the instances; must be in region"
  type        = string
  default     = "us-west1-b"
}

variable "vpc_cidr" {
  description = "Address range the subnets are carved from"
  type        = string
  default     = "10.1.0.0/16"
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH to the bastion, e.g. \"203.0.113.7/32\". No default, so SSH is never open to the world by accident."
  type        = string
}

variable "ssh_user" {
  description = "Login name created on the instances for the SSH key"
  type        = string
  default     = "admin"
}

variable "ssh_public_key_path" {
  description = "Public key installed on the bastion and the web instance"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "machine_type" {
  description = "Compute Engine machine type for the bastion and the web server"
  type        = string
  default     = "e2-micro"
}

variable "container_image" {
  description = "Docker image the web instance runs"
  type        = string
  default     = "systembuilder22/nicetry:latest"
}

variable "domain_name" {
  description = "Optional DNS zone to create in Cloud DNS, e.g. \"gcp.wgillies.net\". The parent zone (Route 53 for wgillies.net) needs NS records pointing at the dns_name_servers output. Leave empty to use the load balancer's IP address."
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Host name for the site within domain_name, e.g. \"fib\" for fib.gcp.wgillies.net. Empty puts the site at the zone's apex."
  type        = string
  default     = "fib"
}

variable "enable_https" {
  description = "Create a Google-managed certificate and an HTTPS listener. Requires domain_name. The certificate finishes provisioning on its own once DNS resolves to the load balancer, which can take up to an hour."
  type        = bool
  default     = false
}
