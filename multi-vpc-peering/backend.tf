terraform {
  backend "s3" {
    bucket       = "terraform-peering-s3-bucket"
    key          = "multi-vpc-peering/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}