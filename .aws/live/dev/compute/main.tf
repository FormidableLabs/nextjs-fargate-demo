provider "aws" {
  version = "~> 3.5"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "nextjs-fargate-demo-XXXXX-terraform-state"
    key            = "compute/terraform.tfststate"
    region         = "us-east-1"
    dynamodb_table = "nextjs-fargate-demo-terraform-locks"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "nextjs-fargate-demo-${local.account_id}-terraform-state"
    key    = "networking/terraform.tfststate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "nextjs-fargate-demo"
  stage      = "dev"
}

module "compute" {
  source = "../../../modules/compute"

  image                  = "${data.terraform_remote_state.networking.outputs.repository_url}:${var.image_version}"
  instance_count         = 2
  prefix                 = local.prefix
  stage                  = local.stage
  vpc_id                 = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_private_subnet_ids = data.terraform_remote_state.networking.outputs.vpc_private_subnets
  vpc_public_subnet_ids  = data.terraform_remote_state.networking.outputs.vpc_public_subnets

  tags = {
    Source  = "terraform"
    Service = "${local.prefix}-compute"
    Stage   = local.stage
  }
}
