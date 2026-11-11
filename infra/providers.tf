terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = "test"
  secret_key = "test"

  # MiniStack is not real AWS, so skip the checks that call real AWS
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Send every service we use to MiniStack instead of AWS
  endpoints {
    ec2            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    ecs            = "http://localhost:4566"
    ecr            = "http://localhost:4566"
    elbv2          = "http://localhost:4566"
    logs           = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    rds            = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Project = "ecs-lab"
    }
  }
}
