variable "prefix" {
  description = "Name prefix for resources"
}

variable "tags" {
  default = {
    Source = "terraform"
  }
}
