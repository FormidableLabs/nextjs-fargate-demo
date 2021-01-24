output "vpc_id" {
  value = module.networking.vpc_id
}

output "vpc_private_subnets" {
  value = module.networking.vpc_private_subnets
}

output "vpc_public_subnets" {
  value = module.networking.vpc_public_subnets
}

output "vpc_security_group_id" {
  value = module.networking.vpc_security_group_id
}
