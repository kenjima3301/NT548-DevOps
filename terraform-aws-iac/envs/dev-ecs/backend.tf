terraform {
  backend "s3" {
    bucket = "nt548-my-tfstate-bucket-2025-unique"
    key    = "dev-ecs/terraform.tfstate"
    region = "ap-southeast-1"

    dynamodb_table = "nt548-terraform-lock-table"
  }
}
