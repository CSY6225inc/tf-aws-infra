output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app_load_balancer.dns_name
}

output "lb_zone_id" {
  description = "The Zone ID of the load balancer"
  value       = aws_lb.app_load_balancer.zone_id
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}