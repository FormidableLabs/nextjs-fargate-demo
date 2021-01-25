variable "image" {
  description = "The ECS image to deploy"
}

variable "instance_count" {
  description = "The number of containers to run"
}

variable "prefix" {
  description = "Name prefix for resources"
}

variable "stage" {
  description = "The application environment stage"
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
