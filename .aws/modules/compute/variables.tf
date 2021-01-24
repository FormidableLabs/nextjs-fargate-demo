variable "image" {
  description = "The ECS image to deploy"
}

variable "prefix" {
  description = "Name prefix for resources"
}

variable "tags" {
  default = {
    Source = "terraform"
  }
}

variable "vpc_id" {
  description = "The VPC to attach to"
}

variable "vpc_private_subnet_ids" {
  description = "The subnets to attach to"
}

variable "vpc_public_subnet_ids" {
  description = "The subnets to attach to"
}
