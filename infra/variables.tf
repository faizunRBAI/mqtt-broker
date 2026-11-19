variable "project_name" {
  description = "Project name used as a prefix for all AWS resources"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
}

variable "mqtt_password" {
  description = "Password for the MQTT broker opsagent user"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type — t3.micro minimises cost"
  type        = string
  default     = "t3.micro"
}
