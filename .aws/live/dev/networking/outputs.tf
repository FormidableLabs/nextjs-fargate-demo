output "repository_url" {
  value = module.networking.ecr_repository_url
}

output "vpc_id" {
  value = module.networking.vpc.vpc_id
}

output "vpc_private_subnets" {
  value = module.networking.vpc.private_subnets
}

output "vpc_public_subnets" {
  value = module.networking.vpc.public_subnets
}

output "vpc_security_group_id" {
  value = module.networking.vpc.default_security_group_id
}
