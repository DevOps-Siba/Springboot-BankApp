############################################
# 1️⃣ Get latest Ubuntu 22.04 AMI
############################################
data "aws_ami" "os_image" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################
# 2️⃣ Get Default VPC
############################################
data "aws_vpc" "default" {
  default = true
}

############################################
# 3️⃣ Get Default Subnets
############################################
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################################
# 4️⃣ Key Pair
############################################
resource "aws_key_pair" "deployer" {
  key_name   = "bankapp-automate-key"
  public_key = file("bankapp-automate-key.pub")
}

############################################
# 5️⃣ Security Group
############################################
resource "aws_security_group" "allow_user_to_connect" {
  name        = "bankapp-security"
  description = "Allow SSH, HTTP and HTTPS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bankapp-security"
  }
}

############################################
# 6️⃣ EC2 Instance
############################################
resource "aws_instance" "testinstance" {
  ami           = data.aws_ami.os_image.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  subnet_id = data.aws_subnets.default.ids[0]

  associate_public_ip_address = true   # 👈 ADD THIS

  vpc_security_group_ids = [
    aws_security_group.allow_user_to_connect.id
  ]

  tags = {
    Name = "Bankapp-Automate-Server"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}