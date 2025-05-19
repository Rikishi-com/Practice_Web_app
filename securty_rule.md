# Terraformを使ってWebアプリ作成

## Securityグループ設定

|リソース種別|説明|
|---|---|
|aws_security_group|セキュリティグループリソースを提供|
|aws_security_group_rule|セキュリティグループのルール定義|

`aws_security_group`
|項目|型|説明|
|---|---|---|
|name|string|セキュリティグループ名|
|description|string|説明|
|vpc_id|string|VPC ID|
|tags|object|タグ|

`aws_security_group_rule`
|項目|型|説明|
|---|---|---|
|security_group_id|string|セキュリティグループID|
|type|enum|ingress（インバウンド）,egress（アウトバウンド）|
|protocol|enum|"tcp","udp","icmp"など|
|from_port|number|開始ポート番号，もしくは開始ICMP番号|
|to_port|number|終了ポート番号，もしくは終了ICMP番号|
|cidr_blocks|string|CIDRブロック|
|source_security_group_id|string|アクセス許可したいセキュリティグループID|