# provider.tf
provider "aws" {
  region = var.aws_region
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# variables.tf
variable "aws_region" {
  default = "us-east-1"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

# main.tf
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_security_group" "open_all" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.open_all.id]
}

resource "aws_instance" "backend" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.open_all.id]
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "data-bucket"
  acl    = "public-read"
}

resource "aws_db_instance" "postgres_db" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "unsafe-password"
  publicly_accessible  = true
}

# users.tf
resource "aws_iam_user" "user_one" {
  name = "user_one"
}

resource "aws_iam_user_policy" "user_one_policy" {
  user   = aws_iam_user.user_one.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "*",
      Resource = "*",
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_user" "user_two" {
  name = "user_two"
}

resource "aws_iam_user_policy" "user_two_policy" {
  user   = aws_iam_user.user_two.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "*",
      Resource = "*",
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_user" "user_three" {
  name = "user_three"
}

resource "aws_iam_user_policy" "user_three_policy" {
  user   = aws_iam_user.user_three.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "*",
      Resource = "*",
      Effect = "Allow"
    }]
  })
}

# outputs.tf
output "frontend_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_ip" {
  value = aws_instance.backend.public_ip
}

