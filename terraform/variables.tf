variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS CLIのプロファイル名"
  type        = string
  default     = "default"
}

# variable "allow_ip" {
#   description = "自分のIP（テスト用）"
#   type        = string
#   default     = "/32"
# }

variable "allow_ip" {
  description = "インバウンド通信を許可するIP"
  type        = string
  default     = "0.0.0.0/0"
}

variable "project" {
  description = "プロジェクト名"
  type        = string
  default     = "myapp"
}

variable "env" {
  description = "環境名"
  type        = string
  default     = "dev"
}

variable "ecr_repository_name" {
  description = "ECRリポジトリ名"
  type        = string
  default     = "docker-web-php"
}

# Github Actionsでコミットのハッシュを入れる用
variable "image_tag" {
  description = "コンテナイメージのタグ"
  type        = string
}