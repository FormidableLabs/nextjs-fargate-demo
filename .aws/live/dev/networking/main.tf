provider "aws" {
  version = "~> 3.5"
  region  = "us-east-1"
}

module "networking" {
  source = "../../../modules/networking"

  prefix = "nextjs-fargate-demo"
  tags = {
    Source  = "terraform"
    Service = "nextjs-fargate-demo"
    Stage   = "dev"
  }
}
