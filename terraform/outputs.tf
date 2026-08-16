# ALBのDNS名
output "alb_dns_name" {
  description = "ALBのDNS名"
  value       = aws_lb.main.dns_name
}

# ECRリポジトリ名、Github Actionsで使う
output "ecr_repository_name" {
  value = aws_ecr_repository.main.name
}

# ECRリポジトリのURL（docker pushの際に使用）
output "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.main.repository_url
}

# VPC ID
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# ECSクラスター名
output "ecs_cluster_name" {
  description = "ECSクラスター名"
  value       = aws_ecs_cluster.main.name
}