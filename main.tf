provider "aws" {
  region = "ap-northeast-1"
}
resource "aws_instance" "web" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "Practice-Web-Instance"
  }
}