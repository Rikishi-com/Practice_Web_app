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
  ]

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

#RDSインスタンス
resource "aws_db_instance" "mysql_standalone" {
  identifier              = "${var.project}-mysql-standalone"

  engine                 = "mysql"
  engine_version         = "8.0.42" # 使用するMySQLのバージョンに合わせて変更

  instance_class         = "db.t3.micro" # インスタンスのクラスを指定

  allocated_storage       = 20 # ストレージサイズを指定
  max_allocated_storage = 50 # 最大ストレージサイズを指定
  storage_type           = "gp2" # ストレージタイプを指定
  storage_encrypted      = false # ストレージを暗号化

  multi_az = false # マルチAZ配置を無効にする
  availability_zone = "ap-northeast-1a" # アベイラビリティゾーンを指定
  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnet_group.name # サブネットグループを指定
  vpc_security_group_ids = [aws_security_group.db_sg.id] # セキュリティグループを指定
  publicly_accessible = false
  port = 3306 # MySQLのデフォルトポートを指定

  parameter_group_name = aws_db_parameter_group.mysql_standalone_parameter_group.name # パラメータグループを指定
  option_group_name    = aws_db_option_group.mysql_standalone_option_group.name # オプショングループを指定


  username               = var.db_username # ユーザー名を指定
  password               = random_string.db_password.result # パスワードをランダムに生成したものを使用
  db_name                = var.db_name

  backup_window = "04:00-05:00" # バックアップウィンドウを指定
  backup_retention_period = 7 # バックアップ保持期間を指定
  maintenance_window = "Mon:05:00-Mon:08:00" # メンテナンスウィンドウを指定
  auto_minor_version_upgrade = false

  deletion_protection = false # 削除保護を有効にする
  skip_final_snapshot    = true # 最終スナップショットを取得する

  apply_immediately = true # 変更を即時適用する

  tags = {
    Name    = "${var.project}-mysql-standalone"
    Project = var.project
    Env     = var.environment
  }
  
}