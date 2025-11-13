resource "aws_ecr_repository" "main" {
  name = "${var.environment}-${var.app_name}"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-${var.app_name}"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  tags = {
    Name = "${var.environment}-cluster"
  }
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.environment}-${var.app_name}-task-sg"
  description = "Allow traffic from ALB to Fargate Task"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.app_port
    to_port   = var.app_port
    protocol  = "tcp"

    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-task-sg"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-${var.app_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.environment}-${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = var.app_name,
      # Link tới "Kho chứa" (Bước 1)
      image     = "${aws_ecr_repository.main.repository_url}:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = var.app_port,
          hostPort      = var.app_port
        }
      ]
      # (Bạn sẽ thêm 'logConfiguration' ở đây để gửi log sang CloudWatch)
    }
  ])

  tags = {
    Name = "${var.environment}-${var.app_name}-task"
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.environment}-${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn

  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]
}


