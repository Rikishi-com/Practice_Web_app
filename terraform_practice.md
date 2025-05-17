# TerraformでWebアプリ作成

##　VPC設定

```bash
resource "aws_vpc" "RESOURSE_NAME"
...
```
`RESOURCE_NAME`-Terraform内で使用する名前

|項目|型|説明|
|---|---|---|
|cidr_block|string|IPv4 CIDRブロック|
|assign_generated_ipv6_cidr_block|string|IPv6 CIDRブロック|
|instance_tenancy|enum|テナンシー（"default","dedicated"）|
|enable_dns_support|bool|DNS解決|
|enable_dns_hostnames|bool|DNSホスト名|
|tags|object|タグ|
---

## Subnet設定

```bash
resource "aws_subnet" "RESOURSE_NAME"
...
```
|項目|型|説明|
|---|---|---|
|vpc_id|string|VPC ID|
|availability_zone|string|アベイラベリティゾーン|
|cidr_block|string|CIDRブロック|
|map_public_ip_on_launch|bool|自動割り当てIP設定|
|tags|object|タグ|

---
## ルートテーブル

```bash
resource "RESOURCE_TYPE" "RESOURSE_NAME"
...
```

`RESOURCE_TYPE`-以下にルートテーブル作成時に必要なリソース種別をまとめる
|リソース種別|説明|
|---|---|
|aws_route_table|ルートテーブルリソースを提供|
|aws_route_table_association|ルートテーブルとサブネットの関連付けを定義|

`aws_route_table`に必要な項目を以下にまとめる
|項目|型|説明|
|---|---|---|
|vpc_id|string|VPC ID|
|tags|object|タグ|

<br>

`aws_route_table_association`に必要な項目を以下にまとめる
|項目|型|説明|
|---|---|---|
|route_table_id|string|ルートテーブルID|
|subnet_id|string|サブネットID|