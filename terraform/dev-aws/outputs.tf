output "site_url" {
  value = local.use_dns ? "${var.enable_https ? "https" : "http"}://${local.site_fqdn}" : "http://${aws_lb.main.dns_name}"
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}

output "ssh_to_web" {
  description = "SSH to the web instance through the bastion"
  value       = "ssh -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.web.private_ip}"
}

output "hosted_zone_name_servers" {
  description = "Set these as the name servers at your domain registrar"
  value       = local.use_dns ? aws_route53_zone.site[0].name_servers : []
}

# run by "make redeploy" on the web instance: pull the image first, so a failed
# pull (e.g. the NAT is off) leaves the old container running, then replace the
# container and wait for it to answer /health
output "redeploy_command" {
  value = join(" && ", [
    "sudo docker pull ${var.container_image}",
    "sudo docker rm -f webserver",
    "sudo ${replace(local.docker_run, " \\\n  ", " ")}",
    "for i in 1 2 3 4 5 6 7 8 9 10; do curl -sf localhost/health && break; sleep 1; done",
  ])
}
