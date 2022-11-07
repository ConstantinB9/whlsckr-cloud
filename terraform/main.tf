terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  backend "s3" {
    bucket = "whlsckr-terraform"
    region = "eu-central-1"
    key    = "terraform.tfstate"
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}