terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.35.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}
