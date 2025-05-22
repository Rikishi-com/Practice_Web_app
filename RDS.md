`aws_db_parameter_group`

|項目|型|説明|
|---|---|---|
|name|string|パラメータグループ名|
|family|string|パラメータグループのファミリー|
|parameter|block|具体的なパラメータ[name,value]|
|tags|object|タグ|

※`block`には **=**不要

<br>

`aws_db_option_group`

|項目|型|説明|
|---|---|---|
|name|string|オプショングループ名|
|engine_name *|string|関連付けるエンジン名．mysqlなど|
|major_engine_version|string|関連付けるエンジンバージョン|
|option|block|具体的なオプション設定[option_name *,option_setting]|
|tags|object|タグ|

`aws_db_subnet_group`

|項目|型|説明|
|---|---|---|
|name|string|サブネットグループ名|
|subnet_ids *|string[]|サブネットID|
|tags|object|タグ|

`random_string`

|項目|型|説明|
|---|---|---|
|length *|number|ランダム文字列の長さ|
|upper|bool|大文字英字を使うかどうか（デフォルトtrue）|
|lower|bool|小文字英字を使うかどうか（デフォルトtrue）|
|number|bool|数字を使うかどうか（デフォルトtrue）|
|special|bool|特殊文字を使うかどうか（デフォルトtrue）|
|override_special|string|利用したい特殊文字（デフォルト[!@#$%&()<>:?]）|

`aws_db_instance`

##　基本設定
|項目|型|説明|
|---|---|---|
|engine *|string|データベースエンジン|
|engine_version|string|データベースエンジンのバージョン|
|identifer *|string|RDSインスタンスリソース名|
|instance_class *|string|インスタンスタイプ|
|username *|string|マスターDBのユーザ名|
|password *|string|マスターDBユーザのパスワード|
|tags|object|タグ|

##　ストレージ
|項目|型|説明|
|---|---|---|
|allocated_storage|string|割り当てるストレージサイズ（GB）|
|max_allocated_storage|string|オートスケールさせる最大ストレージサイズ|
|storage_type|enum|standard(磁気),gp2(SSD),io1(IOPS SSD)|
|storage_encrypted|string|DBを暗号化するKMS鍵IDまたはfalse|

## ネットワーク
|項目|型|説明|
|---|---|---|
|multi_az|bool|マルチAZ配置するか|
|availability_zone|string|シングルインスタンス時に配置するAZ|
|db_subnet_group_name|string|サブネットグループ名|
|vpc_security_group_ids|string[]|セキュリティグループID|
|publicly_accessible|bool|パブリック・アクセス許可するかどうか|
|port|number|ポート番号|

## DB設定
|項目|型|説明|
|---|---|---|
|name|string|データベース名|
|parameter_group_name|string|パラメータグループ名|
|option_group_name|string|オプショングループ名|

## バックアップ
|項目|型|説明|
|---|---|---|
|backup_window|string|バックアップを行う時間帯|
|backup_retention_period|bool|バックアップを残す数|
|maintenance_window|string|メンテナンスを行う時間帯|
|auto_minor_version_upgrade|bool|自動でマイナーバージョンをアップグレードするか|

##　削除防止
|項目|型|説明|
|---|---|---|
|deletion_protection|bool|削除防止するか|
|skip_final_snapshot|bool|削除時のスナップショットをスキップするか|
|apply_immediately|bool|即時反映するか|

