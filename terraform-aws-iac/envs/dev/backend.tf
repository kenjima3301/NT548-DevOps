terraform {
  backend "s3" {
    bucket = "nt548-my-tfstate-bucket-2025-unique"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"

    use_lockfile = true
  }
}
