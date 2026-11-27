variable "region" {
  description = "AWS region (the exam uses us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 size. t3.micro is free-tier eligible and enough for Docker + this app"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = <<-EOT
    VPC to use. Leave null to use the account's default VPC (personal account).
    In the college lab account set it to the exam VPC: vpc-044604d0bfb707142
  EOT
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Public subnet for the instance. Leave null to use the default subnet of availability_zone"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Used only when subnet_id is null. us-east-1a supports t3 instances"
  type        = string
  default     = "us-east-1a"
}

variable "allowed_cidr" {
  description = "Who may reach ports 22 and 5001. Leave null to allow only your current public IP (/32)"
  type        = string
  default     = null
}
