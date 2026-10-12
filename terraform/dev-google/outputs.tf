output "site_url" {
  value = local.use_dns ? "${var.enable_https ? "https" : "http"}://${local.site_fqdn}" : "http://${google_compute_global_address.lb.address}"
}

output "lb_ip_address" {
  value = google_compute_global_address.lb.address
}

output "bastion_public_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "web_private_ip" {
  value = google_compute_instance.web.network_interface[0].network_ip
}

output "ssh_to_web" {
  description = "SSH to the web instance through the bastion"
  value       = "ssh -J ${var.ssh_user}@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip} ${var.ssh_user}@${google_compute_instance.web.network_interface[0].network_ip}"
}

output "dns_name_servers" {
  description = "Add these as an NS record for domain_name in the parent zone (Route 53)"
  value       = local.use_dns ? google_dns_managed_zone.site[0].name_servers : []
}
