provider "aws" {
  version = "~> 3.5"
  region  = "us-east-1"
}

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../networking/terraform.tfstate"
  }
}

module "compute" {
  source = "../../../modules/compute"

  image                  = var.image
  prefix                 = "nextjs-fargate-demo"
  vpc_id                 = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_private_subnet_ids = data.terraform_remote_state.networking.outputs.vpc_private_subnets
  vpc_public_subnet_ids  = data.terraform_remote_state.networking.outputs.vpc_public_subnets

  tags = {
    Source  = "terraform"
    Service = "nextjs-fargate-demo"
    Stage   = "dev"
  }
}
