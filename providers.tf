terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}
