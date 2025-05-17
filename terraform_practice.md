# TerraformでWebアプリ作成

##　VPC設定

```bash
resource <RESOURCE_TYPE> <RESOURSE_NAME>
...
```
`RESOURCE_NAME`-Terraform内で使用する名前
以下にVPC作成時に使う`RESOURCE_TYPE`をまとめる

|項目|型|説明|
|---|---|---|
|cidr_block|string|IPv4 CIDRブロック|
|assign_generated_ipv6_cidr_block|string|IPv6 CIDRブロック|
|instance_tenancy|enum|テナンシー（"default","dedicated"）|
|enable_dns_support|bool|DNS解決|
|enable_dns_hostnames|bool|DNSホスト名|
|tags|object|タグ|