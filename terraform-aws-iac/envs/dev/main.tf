provider "aws" {
  region = "ap-southeast-1"
}

module "network" {
  source               = "../../modules/network"
  environment          = "dev"
  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  private_subnet_cidr  = var.private_subnet_cidr
}

resource "aws_key_pair" "my_key" {
  key_name   = "dev-key"
  public_key = file("../../modules/my-aws-key.pub")
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = "${var.environment}-ec2-sg"
  }
}

module "eks" {
  source             = "../../modules/eks"
  environment        = var.environment
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
}

module "ec2" {
  source        = "../../modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key.key_name

  subnet_id         = module.network.public_subnet_ids[0]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_ecr_repository" "my_app" {
  name = "my-web-app"

  image_scanning_configuration {
    scan_on_push = true
  }
}
