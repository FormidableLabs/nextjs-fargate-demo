data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Create a locking table for terraform runs
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "nextjs-fargate-demo-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Create a state bucket for terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket = "nextjs-fargate-demo-${local.account_id}-terraform-state"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Export the name so we can use it later
output "state_bucket" {
  value = aws_s3_bucket.terraform_state.id
}
