output "instance_ip_addr_1" {
  value       = aws_instance.my_server[0].public_ip
  description = "The private IP address of the main server instance."
}

output "instance_ip_addr_2" {
  value       = aws_instance.my_server[1].public_ip
  description = "The private IP address of the backup server instance."
}