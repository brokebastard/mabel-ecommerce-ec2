## =============================================================================
#  Configure the AWS Provider                                                  #
## =============================================================================
terraform {
  required_providers {
    aws = "~> 2.59"
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}
