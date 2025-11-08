provider "aws" {
  region = "ap-southeast-1"
}

module "network" {
  source      = "../../modules/network"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
  environment = "dev"
}

module "ec2" {
  source        = "../../modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type

  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id

  key_name = aws_key_pair.my_key.key_name
}
resource "aws_key_pair" "my_key" {
  key_name   = "dev-key"
  public_key = file("D:/Project/DevOps/terraform-aws-infra/my-aws-key.pub")
}
