resource "aws_ecr_repository" "ecr" {
  name = var.prefix

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}
