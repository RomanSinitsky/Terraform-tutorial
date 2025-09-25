output "instance_ip_addr_1" {
  value       = aws_instance.my_server[*].public_ip
  description = "The private IP address of the main server instance."
}
