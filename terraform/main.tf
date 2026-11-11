# ---------------------------------------------------------------------------
# Network: the VPC and a public subnet (we do NOT create a VPC)
# ---------------------------------------------------------------------------

# The default VPC of the account (used when var.vpc_id is not set)
data "aws_vpc" "selected" {
  id      = var.vpc_id
  default = var.vpc_id == null ? true : null
}

# A public subnet in that VPC (used when var.subnet_id is not set)
data "aws_subnet" "selected" {
  id                = var.subnet_id
  vpc_id            = var.subnet_id == null ? data.aws_vpc.selected.id : null
  availability_zone = var.subnet_id == null ? var.availability_zone : null
  default_for_az    = var.subnet_id == null && var.vpc_id == null ? true : null
}

# Your current public IP, so only you can reach the server
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  allowed_cidr = coalesce(var.allowed_cidr, "${chomp(data.http.my_ip.response_body)}/32")
}

# ---------------------------------------------------------------------------
# AMI: latest Amazon Linux 2023 (supports Docker)
# ---------------------------------------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------------------------------------------------------------------------
# SSH key pair
# ---------------------------------------------------------------------------

# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key on your machine (builder_key.pem is in .gitignore)
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

# Upload only the PUBLIC key to AWS
resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# ---------------------------------------------------------------------------
# Security group: SSH (22) and the app (5001) from your IP only
# ---------------------------------------------------------------------------
resource "aws_security_group" "builder_sg" {
  name        = "builder-sg"
  description = "SSH and Flask app access for the builder instance"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }

  ingress {
    description = "Flask app from my IP"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }

  egress {
    description = "All outbound traffic (package downloads, Docker Hub, GitHub)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "builder-sg"
  }
}

# ---------------------------------------------------------------------------
# EC2 instance "builder"
# user_data.sh installs Docker and Docker Compose on the first boot
# ---------------------------------------------------------------------------
resource "aws_instance" "builder" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.builder_sg.id]
  key_name                    = aws_key_pair.builder_key.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "builder"
  }
}
