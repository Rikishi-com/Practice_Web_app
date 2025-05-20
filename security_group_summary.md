# Terraformによるセキュリティグループ構成

## 今回作成したコード
```bash
#Webサーバー用のセキュリティグループを作成する
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-${var.environment}-web-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-web-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_in_https" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_out_tcp3000" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = aws_security_group.app_sg.id
}

#アプリケーション用のセキュリティグループを作成する
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.environment}-app-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-app-sg"
    Project = var.project
    Env     = var.environment
  }
}

#運用管理用のセキュリティグループを作成する
resource "aws_security_group" "opmng_sg" { #oparation and management group
  name        = "${var.project}-${var.environment}-opmng-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-opmng-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "opmng_in_ssh" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_in_tcp3000" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_out_http" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_out_https" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

#DB用のセキュリティグループを作成する
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-${var.environment}-db-sg"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-db-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "db_in_tcp3306" {
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.app_sg.id
}

```


## 今回作成したセキュリティグループ一覧と概要

| セキュリティグループ名 | 用途             | 許可する通信内容                                  |
|--------------------------|------------------|---------------------------------------------------|
| web_sg                   | Webサーバ用      | HTTP, HTTPS (全世界), TCP 3000番でapp_sgへ出力   |
| app_sg                   | アプリ用         | 受信・送信ルールは未記載（他SGから接続される）   |
| opmng_sg                 | 運用管理用       | SSH, TCP3000受信（全世界）およびHTTP/HTTPS出力   |
| db_sg                    | データベース用   | TCP 3306 を app_sg からの通信に限定して許可       |

<br>

## 使用するリソースブロック
|リソース種別|説明|
|---|---|
|aws_security_group|セキュリティグループリソースを提供|
|aws_security_group_rule|セキュリティグループのルール定義|

<br>

## セキュリティグループ作成
```bash
resource "aws_security_group" "RESOURSE_NAME" {
  ...
}
```
|項目|型|説明|
|---|---|---|
|name|string|セキュリティグループ名|
|description|string|説明|
|vpc_id|string|対応させるVPCのID|
|tags|object|タグ|

※全てオプションのため設定がなければTerraformはランダムを入力

<br>

## セキュリティグループルール作成
```bash
resource "aws_security_group_rule" "RESOURCE_NAME" {
  ...
}
```
|項目|型|説明|
|---|---|---|
|security_group_id *|string|セキュリティグループID|
|type *|enum|ingress（インバウンド）,egress（アウトバウンド）|
|protocol *|enum|"tcp","udp","icmp"など|
|from_port *|number|開始ポート番号，もしくは開始ICMP番号|
|to_port *|number|終了ポート番号，もしくは終了ICMP番号|
|cidr_blocks|string|CIDRブロック|
|source_security_group_id|string|アクセス許可したいセキュリティグループID|

※`from port`と`to port`は1ポートのみ開けるときは同一の数字．連続した複数のポートを開放したいときはその分開ける

---

# 実例
## Webサーバ用: `web_sg`

```hcl
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-${var.environment}-web-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-web-sg"
    Project = var.project
    Env     = var.environment
  }
}
```

<br>

### 関連ルール
```bash
resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress" #インバウンドルール
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_in_https" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_out_tcp3000" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "egress" #アウトバウンドルール
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = aws_security_group.app_sg.id #TCP3000ポートかつapp_sgのみを対象とするという意味
}
```
- HTTP（80番）とHTTPS（443番）を全世界から受け入れ
- TCP 3000番ポートで `app_sg` に対して送信許可

---

## アプリケーション用: `app_sg`

```hcl
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.environment}-app-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-app-sg"
    Project = var.project
    Env     = var.environment
  }
}
```

※ 明示的なルールはこのファイルには一旦未定義

---

## 運用管理用: `opmng_sg`

```hcl
resource "aws_security_group" "opmng_sg" {
  name        = "${var.project}-${var.environment}-apmng-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-apmng-sg"
    Project = var.project
    Env     = var.environment
  }
}
```

<br>

### 関連ルール
```bash
resource "aws_security_group_rule" "opmng_in_ssh" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_in_tcp3000" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_out_http" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_out_https" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}
```

- TCP 22（SSH）を全世界から許可
- TCP 3000 番も全世界から許可
- HTTP/HTTPS でインターネットへの出力許可

---

## データベース用: `db_sg`

```hcl
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-${var.environment}-db-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-db-sg"
    Project = var.project
    Env     = var.environment
  }
}
```

<br>

### 関連ルール
```bash
resource "aws_security_group_rule" "db_in_tcp3306" {
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.app_sg.id
}
```

- TCP 3306（MySQL）を `app_sg` からのみに限定して許可

---

## 補足事項

- セキュリティグループ間の連携には `source_security_group_id` を使用
- `cidr_blocks = ["0.0.0.0/0"]` は開放的な設定のため、運用時はIP制限を考慮すべき
- 通信の方向（ingress/egress）を明確に意識し、必要最小限のポートのみ開放することが推奨される