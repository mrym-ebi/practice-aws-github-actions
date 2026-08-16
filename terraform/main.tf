terraform {
    required_version = ">= 1.15.3"

    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
        bucket         = "myapp-tfstate-102870292384-102870292384-ap-northeast-1-an"
        key            = "terraform.tfstate"
        region         = "ap-northeast-1"
        use_lockfile = true
        encrypt        = true
    }
}

provider "aws" {
    region  = var.region

    default_tags {
      tags = {
        Project   = var.project
        Env       = var.env
        ManagedBy = "Terraform"
      }
    }
}