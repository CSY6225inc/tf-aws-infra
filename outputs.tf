output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app_load_balancer.dns_name
}

output "lb_zone_id" {
  description = "The Zone ID of the load balancer"
  value       = aws_lb.app_load_balancer.zone_id
}