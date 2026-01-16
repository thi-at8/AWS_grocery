terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"  # angepasst an deine Wahl
  profile = "default"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "EC2-to-RDS-VPC"
  }
}


# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = "eu-central-1a"
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = "eu-central-1b"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "Private Subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = "eu-central-1c"
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "Private Subnet-2"
  }
}


# Internet Gateway & Route Tables
resource "aws_internet_gateway" "ig_2tier" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Internet Gateway for EC2-to-RDS VPC"
  }
}

# Public route table    #### What the heck?####
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Public route_table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_2tier.id
}

# Private route table       #### What the heck?####
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Private route_table"
  }
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}


# Security Groups
# EC2 SG
resource "aws_security_group" "sg_for_ec2" {
  name   = "launch-wizard-1"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "SSH from anywhere (replace with your IP for production)"
    from_port   = 22
    to_port     = 22
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

# RDS SG
resource "aws_security_group" "sg_for_rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    security_groups = [aws_security_group.sg_for_ec2.id]
  }
}

# EC2 Instance
resource "aws_instance" "ec2" {
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_for_ec2.id]

  tags = {
    Name = "Terraform_EC2-for-RDS"
  }
}


# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}


# RDS Instance (PostgreSQL)
resource "aws_db_instance" "my_db_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  db_name                = "grocerymate_db"
  username               = "grocery_user"
  password               = "grocery_test"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_for_rds.id]

  tags = {
    Name = "ec2_to_postgres_rds"
  }
}


# Outputs
output "rds_endpoint" {
  value     = aws_db_instance.my_db_instance.endpoint
  sensitive = true
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}
