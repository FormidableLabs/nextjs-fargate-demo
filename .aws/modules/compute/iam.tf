# A policy to allow ecs tasks to assume a role
data "aws_iam_policy_document" "execution_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution_role" {
  name        = "${var.prefix}-${var.stage}-ecs-task_execution_role"
  description = "IAM service role for ECS Cluster: ${aws_ecs_cluster.cluster.name}"

  assume_role_policy = data.aws_iam_policy_document.execution_role.json
  tags               = var.tags
}

# A policy to allow our relay to run on ECS and connect to dynamodb
data "aws_iam_policy_document" "execution_role_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_role_policy" "execution_role_policy" {
  name = "${var.prefix}-${var.stage}-ecs-task_execution_role_policy"
  role = aws_iam_role.execution_role.id

  policy = data.aws_iam_policy_document.execution_role_policy.json
}
