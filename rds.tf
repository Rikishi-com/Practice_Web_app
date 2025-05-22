#パラメータグループ

resource "aws_db_parameter_group" "mysql_standalone_parameter_group" {
  name        = "${var.project}-mysql-standalone-parameter-group"
  family      = "mysql8.0" # 使用するMySQLのバージョンに合わせて変更
  description = "MySQL parameter group for ${var.project} in ${var.environment}"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4" # デフォルトの文字セットをutf8mb4に設定
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4" # デフォルトの文字セットをutf8mb4に設定
  }

}

#オプショングループ
resource "aws_db_option_group" "mysql_standalone_option_group" {
  name                 = "${var.project}-mysql-standalone-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0" # 使用するMySQLのバージョンに合わせて変更 
}

#サブネットグループ
resource "aws_db_subnet_group" "mysql_standalone_subnet_group" {
  name = "${var.project}-mysql-standalone-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ] # 公開サブネットを指定

  tags = {
    Name    = "${var.project}-mysql-standalone-subnet-group"
    Project = var.project
    Env     = var.environment
  }
}

#ランダムなパスワードを生成
resource "random_string" "db_password" {
  length  = 16
  special = false
}