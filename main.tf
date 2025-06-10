provider "aws" {
  region = "us-east-2"
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key_pair" {
  key_name   = "practice_pair"
  public_key = tls_private_key.key_pair.public_key_openssh
  
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-004364947f82c87a0"  # Ensure this AMI is valid for us-east-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.allow_http.name]

  user_data = <<-EOF
              #!/bin/bash
              # Update system and install Apache
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello World!</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "Terraform"
  }
}



output "private_key_pem" {
  value     = tls_private_key.key_pair.private_key_pem
  sensitive = true
}