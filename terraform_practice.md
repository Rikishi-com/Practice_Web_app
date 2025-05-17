# TerraformでWebアプリ作成

##　今回作成したコード
```bash
# VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = "192.168.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = "true"
  enable_dns_hostnames             = "true"
  assign_generated_ipv6_cidr_block = "false"
  tags = {
    "Name"  = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment

  }
}
# サブネット
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name    = "${var.project}-${var.environment}-public-subnet-1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name    = "${var.project}-${var.environment}-public-subnet-1c"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "192.168.3.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name    = "${var.project}-${var.environment}-private-subnet-1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name    = "${var.project}-${var.environment}-private-subnet-1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

#ルートテーブル

#パブリック
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-public-rt"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }

}

resource "aws_route_table_association" "public_rt_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_rt.id
}

#プライベート
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-private-rt"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }

}

resource "aws_route_table_association" "private_rt_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_1c" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private_rt.id
}

#インターネットゲートウェイ
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-igw"
    Project = var.project
    Env     = var.environment
  }

}

resource "aws_route" "public_rt_igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
```

---

## VPC設定

```bash
resource "aws_vpc" "RESOURSE_NAME" {
  ...
}
```
VPC（Virtual Private Cloud）とは，仮想ネットワークを構成するためのリソースである．AWS内に独立したネットワーク空間を作成でき，EC2などのリソースをこの中に配置する．

|項目|型|説明|
|---|---|---|
|cidr_block|string|VPCで使用するIPアドレス範囲をCIDR形式で指定する．|
|assign_generated_ipv6_cidr_block|string|IPv6のCIDRブロックを自動で割り当てるかどうかを指定する．trueで有効となる．|
|instance_tenancy|string|インスタンスのテナンシー（'default'または'dedicated'）を指定する．|
|enable_dns_support|string|DNS解決を有効にするかどうかを指定する．trueの場合，インスタンスで内部DNSが使用できる．|
|enable_dns_hostnames|string|DNSホスト名を有効にするかどうかを指定する．trueで，インスタンスにパブリックDNS名が割り当てられる．|
|tags|string|任意のタグをkey-value形式で付与できる．リソースの識別や分類に役立つ．|

---

## Subnet設定

```bash
resource "aws_subnet" "RESOURSE_NAME" {
  ...
}
```
VPC内で定義するサブネットである．アベイラビリティゾーン内に，指定したIP範囲でネットワークを分割する．

|項目|型|説明|
|---|---|---|
|vpc_id|string|紐付けるVPCのID．|
|availability_zone|string|作成するサブネットのアベイラビリティゾーン名．|
|cidr_block|string|このサブネットで利用するCIDR形式のIP範囲．|
|map_public_ip_on_launch|string|trueに設定すると，起動したインスタンスに自動でパブリックIPを割り当てる．|
|tags|string|リソースに付与するタグの定義．|

---

## Route Table設定

```bash
resource "aws_route_table" "RESOURSE_NAME" {
  ...
}
```
VPC内の通信経路（ルート）を定義するリソースである．ルートテーブルには，どの宛先に対してどのゲートウェイやインターフェースを使うかを指定する．

|項目|型|説明|
|---|---|---|
|vpc_id|string|このルートテーブルが関連付けられるVPCのID．|
|tags|string|リソースに付与するタグの定義．|

---

## Route Table Association設定

```bash
resource "aws_route_table_association" "RESOURSE_NAME" {
  ...
}
```
サブネットとルートテーブルを関連付けるためのリソースである．これにより，どのサブネットがどのルートテーブルのルールに従うかを定義できる．

|項目|型|説明|
|---|---|---|
|route_table_id|string|紐付けるルートテーブルのID．|
|subnet_id|string|関連付ける対象のサブネットID．|

---

## Internet Gateway設定

```bash
resource "aws_internet_gateway" "RESOURSE_NAME" {
  ...
}
```
VPCをインターネットに接続するためのゲートウェイリソースである．インターネット通信が必要なサブネットと組み合わせて使用される．

|項目|型|説明|
|---|---|---|
|vpc_id|string|このインターネットゲートウェイを関連付けるVPCのID．|
|tags|string|リソースに付与するタグの定義．|

---

## Route設定

```bash
resource "aws_route" "RESOURSE_NAME" {
  ...
}
```
ルートテーブルに対して，通信先CIDRと使用するゲートウェイの情報を定義するリソースである．

|項目|型|説明|
|---|---|---|
|route_table_id|string|ルートを追加する対象のルートテーブルID．|
|destination_cidr_block|string|このルートで対象とする通信先のCIDR範囲．|
|gateway_id|string|インターネットゲートウェイなど，通信先に到達するためのゲートウェイID．|

---