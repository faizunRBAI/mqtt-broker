output "instance_ip" {
  description = "Public IP of the EC2 instance (pre-EIP association, used for SSH during configure)"
  value       = aws_instance.broker.public_ip
}

output "elastic_ip" {
  description = "Stable Elastic IP address of the MQTT broker"
  value       = aws_eip.broker.public_ip
}
