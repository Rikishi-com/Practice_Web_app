variable "instance_type" {
  default = "t2.micro"
}

variable "aws_ami" {
  description = "Amazon Linux 2023 AMI ID"
  default     = "ami-0c1638aa346a43fe8"
}

variable "key_name" {
  description = "practice"
}

variable "project" {
  description = "Project name"
}

variable "environment" {
  description = "Environment name"
}

