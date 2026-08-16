# ECSクラスター
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.env}-cluster"

  tags = {
    Name = "${var.project}-${var.env}-cluster"
  }
}

# タスク定義
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project}-${var.env}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "php-container"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.ecr_repository_name}:${var.image_tag}"
      essential = true
      
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
    }
  ])

  tags = {
    Name = "${var.project}-${var.env}-task"
  }
}

# ECSサービス
resource "aws_ecs_service" "main" {
  name            = "${var.project}-${var.env}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      aws_subnet.private_1c.id,
      aws_subnet.private_1d.id
    ]
    security_groups  = [aws_security_group.container.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "php-container"
    container_port   = 80
  }

  tags = {
    Name = "${var.project}-${var.env}-service"
  }

  depends_on = [
    aws_lb_listener.https
  ]
}

# AWSアカウントIDをdataで取得（ECRのURLに使用）
data "aws_caller_identity" "current" {}