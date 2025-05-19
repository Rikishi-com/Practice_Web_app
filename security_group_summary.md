# Terraformによるセキュリティグループ構成（詳細）

## セキュリティグループ一覧と概要

| セキュリティグループ名 | 用途             | 許可する通信内容                                  |
|--------------------------|------------------|---------------------------------------------------|
| web_sg                   | Webサーバ用      | HTTP, HTTPS (全世界), TCP 3000番でapp_sgへ出力   |
| app_sg                   | アプリ用         | 受信・送信ルールは未記載（他SGから接続される）   |
| opmng_sg                 | 運用管理用       | SSH, TCP3000受信（全世界）およびHTTP/HTTPS出力   |
| db_sg                    | データベース用   | TCP 3306 を app_sg からの通信に限定して許可       |

---

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

### 関連ルール

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

※ 明示的なルールはこのファイルには未定義

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

### 関連ルール

- TCP 22（SSH）を全世界から許可
- TCP 3000 番も全世界から許可（モニタリングなど？）
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

### 関連ルール

- TCP 3306（MySQL）を `app_sg` からのみに限定して許可

---

## 補足事項

- セキュリティグループ間の連携には `source_security_group_id` を使用
- `cidr_blocks = ["0.0.0.0/0"]` は開放的な設定のため、運用時はIP制限を考慮すべき
- 通信の方向（ingress/egress）を明確に意識し、必要最小限のポートのみ開放することが推奨される