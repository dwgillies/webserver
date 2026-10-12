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
