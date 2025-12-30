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

module "s3_media" {
  source      = "../../modules/s3"
  bucket_name = "dorashop-media-assets-${var.environment}"
  environment = var.environment
}

resource "aws_ecr_repository" "my_app" {
  name         = "my-web-app"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "cluster_bootstrap" {
  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
  }

  provisioner "local-exec" {
    command = "bash ../../../scripts/validate-kustomize.sh && bash ../../../scripts/setup_cluster.sh && bash ../../../scripts/deploy-argocd-apps.sh ${module.eks.cluster_name} ${var.aws_region} ${aws_ecr_repository.my_app.repository_url} > setup.log 2>&1"

    environment = {
      MY_APP_ACCESS_KEY = var.app_s3_access_key
      MY_APP_SECRET_KEY = var.app_s3_secret_key
    }
  }

  depends_on = [module.eks, aws_ecr_repository.my_app]
}

resource "null_resource" "show_outputs" {
  depends_on = [null_resource.cluster_bootstrap]

  triggers = {
    bootstrap_id = null_resource.cluster_bootstrap.id
  }

  provisioner "local-exec" {
    command = "cat access_info.txt"
  }
}
