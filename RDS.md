# TerraformでRDS構築

## 今回作成したコード
```bash
# パラメータグループ
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

# オプショングループ
resource "aws_db_option_group" "mysql_standalone_option_group" {
  name                 = "${var.project}-mysql-standalone-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0" # 使用するMySQLのバージョンに合わせて変更
}

# サブネットグループ
resource "aws_db_subnet_group" "mysql_standalone_subnet_group" {
  name       = "${var.project}-mysql-standalone-subnet-group"
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

# ランダムなパスワード生成
resource "random_string" "db_password" {
  length  = 16
  special = false
}

# RDSインスタンス
resource "aws_db_instance" "mysql_standalone" {
  identifier              = "${var.project}-mysql-standalone"

  engine                 = "mysql"
  engine_version         = "8.0.42" # 使用するMySQLのバージョンに合わせて変更

  instance_class         = "db.t3.micro" # インスタンスのクラスを指定

  allocated_storage       = 20  # ストレージサイズを指定
  max_allocated_storage   = 50  # 最大ストレージサイズを指定
  storage_type            = "gp2" # ストレージタイプを指定
  storage_encrypted       = false # ストレージを暗号化

  multi_az               = false # マルチAZ配置を無効にする
  availability_zone      = "ap-northeast-1a" # アベイラビリティゾーンを指定

  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnet_group.name # サブネットグループを指定
  vpc_security_group_ids = [aws_security_group.db_sg.id] # セキュリティグループを指定
  publicly_accessible    = false
  port                   = 3306 # MySQLのデフォルトポートを指定

  parameter_group_name = aws_db_parameter_group.mysql_standalone_parameter_group.name # パラメータグループを指定
  option_group_name    = aws_db_option_group.mysql_standalone_option_group.name   # オプショングループを指定

  username                = var.db_username            # ユーザー名を指定
  password                = random_string.db_password.result # パスワードをランダムに生成したものを使用
  db_name                 = var.db_name

  backup_window           = "04:00-05:00" # バックアップウィンドウを指定
  backup_retention_period = 7             # バックアップ保持期間を指定

  maintenance_window         = "Mon:05:00-Mon:08:00" # メンテナンスウィンドウを指定
  auto_minor_version_upgrade = false        # 自動でマイナーバージョンをアップグレードするか

  deletion_protection     = false # 削除保護を有効にする
  skip_final_snapshot     = true  # 最終スナップショットを取得するか

  apply_immediately       = true  # 変更を即時適用する

  tags = {
    Name    = "${var.project}-mysql-standalone"
    Project = var.project
    Env     = var.environment
  }
}
```

---
#　パラメータグループ
### 作成したコード
```bash
# パラメータグループ
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

```
## aws_db_parameter_group
MySQL用のパラメータグループを定義するリソースです。パラメータ名と値を細かく制御できます。

|項目|型|説明|
|---|---|---|
|name *|string|パラメータグループの名前|
|family *|string|MySQLのバージョンに対応するファミリー|
|description|string|リソースの説明文|
|parameter *|block|個別パラメータ(name, value)の設定|

---

# オプショングループ
### 作成したコード
```bash
#オプショングループ
resource "aws_db_option_group" "mysql_standalone_option_group" {
  name                 = "${var.project}-mysql-standalone-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0" # 使用するMySQLのバージョンに合わせて変更
}
```
## aws_db_option_group
RDSのオプショングループを定義するリソースです。データベースエンジンの追加機能を管理できます。

|項目|型|説明|
|---|---|---|
|name *|string|オプショングループの名前|
|engine_name *|string|エンジン名(mysql等)|
|major_engine_version *|string|対象となるエンジンのバージョン|

---

# サブネットグループ
## 作成したコード
```bash
# サブネットグループ
resource "aws_db_subnet_group" "mysql_standalone_subnet_group" {
  name       = "${var.project}-mysql-standalone-subnet-group"
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
```
## aws_db_subnet_group
RDSインスタンスが配置されるサブネットグループを定義するリソースです。

|項目|型|説明|
|---|---|---|
|name *|string|サブネットグループの名前|
|subnet_ids *|list(string)|属するサブネットのIDリスト|
|tags *|map(string)|リソースに付与するタグ|

---

# ランダムパスワード
## 作成したコード
```bash
# ランダムなパスワード生成
resource "random_string" "db_password" {
  length  = 16
  special = false
}
```
## random_string.db_password
RDS用のパスワードをランダムに生成するリソースです。

|項目|型|説明|
|---|---|---|
|length *|number|生成する文字列の長さ|
|special |bool  |特殊文字を含めるかどうか|

---

# RDSインスタンス
## 作成したコード
```bash
# RDSインスタンス
resource "aws_db_instance" "mysql_standalone" {
  identifier              = "${var.project}-mysql-standalone"

  engine                 = "mysql"
  engine_version         = "8.0.42" # 使用するMySQLのバージョンに合わせて変更

  instance_class         = "db.t3.micro" # インスタンスのクラスを指定

  allocated_storage       = 20  # ストレージサイズを指定
  max_allocated_storage   = 50  # 最大ストレージサイズを指定
  storage_type            = "gp2" # ストレージタイプを指定
  storage_encrypted       = false # ストレージを暗号化

  multi_az               = false # マルチAZ配置を無効にする
  availability_zone      = "ap-northeast-1a" # アベイラビリティゾーンを指定

  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnet_group.name # サブネットグループを指定
  vpc_security_group_ids = [aws_security_group.db_sg.id] # セキュリティグループを指定
  publicly_accessible    = false
  port                   = 3306 # MySQLのデフォルトポートを指定

  parameter_group_name = aws_db_parameter_group.mysql_standalone_parameter_group.name # パラメータグループを指定
  option_group_name    = aws_db_option_group.mysql_standalone_option_group.name   # オプショングループを指定

  username                = var.db_username            # ユーザー名を指定
  password                = random_string.db_password.result # パスワードをランダムに生成したものを使用
  db_name                 = var.db_name

  backup_window           = "04:00-05:00" # バックアップウィンドウを指定
  backup_retention_period = 7             # バックアップ保持期間を指定

  maintenance_window         = "Mon:05:00-Mon:08:00" # メンテナンスウィンドウを指定
  auto_minor_version_upgrade = false        # 自動でマイナーバージョンをアップグレードするか

  deletion_protection     = false # 削除保護を有効にする
  skip_final_snapshot     = true  # 最終スナップショットを取得するか

  apply_immediately       = true  # 変更を即時適用する

  tags = {
    Name    = "${var.project}-mysql-standalone"
    Project = var.project
    Env     = var.environment
  }
}
```
## aws_db_instance
RDSインスタンスを作成するメインリソースです。インスタンスサイズやストレージ、可用性などを設定します。

|項目|型|説明|
|---|---|---|
|identifier *|string|RDSインスタンス識別子|
|engine *|string|データベースエンジン名|
|engine_version|string|エンジンのバージョン|
|instance_class *|string|インスタンスタイプ|
|allocated_storage *|number|初期ストレージサイズ(GB)|
|max_allocated_storage|number|自動増加時の最大ストレージサイズ(GB)|
|storage_type|string|ストレージタイプ|
|storage_encrypted|bool |ストレージ暗号化の有無|
|multi_az|bool |マルチAZ配置の有無|
|availability_zone|string|配置先AZ|
|db_subnet_group_name|string|サブネットグループ名|
|vpc_security_group_ids|list(string)|紐付けるセキュリティグループのID|
|publicly_accessible|bool|パブリックアクセスの可否|
|port|number|データベースポート番号|
|parameter_group_name|string|適用するパラメータグループ名|
|option_group_name|string|適用するオプショングループ名|
|username|string|管理者ユーザー名|
|password|string|管理者パスワード|
|db_name|string|初期データベース名|
|backup_window|string|バックアップ実行ウィンドウ|
|backup_retention_period|number|バックアップ保持期間(日数)|
|maintenance_window|string|メンテナンスウィンドウ|
|auto_minor_version_upgrade|bool|マイナーバージョン自動アップグレードの有無|
|deletion_protection|bool|削除保護の有無|
|skip_final_snapshot|bool|削除時のスナップショット作成の有無|
|apply_immediately|bool|変更の即時適用の有無|
|tags|map(string)|リソースに付与するタグ|
