terraform {
  backend "s3" {
    bucket       = "aws-accelerator-terraform-state-907480720489-us-east-2"
    key          = "tfstate/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}