# Creates a cloudwatch log group for tasks
resource "aws_cloudwatch_log_group" "app" {
  name = "/aws/ecs/${var.prefix}"
  tags = var.tags
}

# Creates the ECS task with the given resources
resource "aws_ecs_task_definition" "app" {
  family = var.prefix

  container_definitions = templatefile("${path.module}/tasks/app.tmpl", {
    LOG_GROUP   = aws_cloudwatch_log_group.app.name,
    LOG_REGION  = data.aws_region.current.name,
    LOG_SERVICE = "task",
    IMAGE       = var.image
  })

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.execution_role.arn
  tags                     = var.tags
}

# Build a cluster where tasks can run
resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}-cluster"
  tags = var.tags
}

# Setup a security group for the cluster
resource "aws_security_group" "cluster" {
  name   = "${var.prefix}-sg"
  vpc_id = var.vpc_id

  # inbound https
  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.lb.id]
  }

  # allow egress to the internet
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Setup a service where the cluster can live on our VPC
resource "aws_ecs_service" "service" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.cluster.id]
    subnets         = var.vpc_private_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "nextjs"
    container_port   = 3000
  }
}
