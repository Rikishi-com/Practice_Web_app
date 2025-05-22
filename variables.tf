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
  default     = "practice"
}

variable "environment" {
  description = "Environment name"
  default     = "Web_app"
}

variable "db_username" {
  description = "DB username"
  default     = "ueno"
}

variable "db_name"{
  description = "DB name"
  default     = "practice"
}
