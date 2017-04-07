---
title: Amazon RDS (for MySQL)のログをfluentdを使って取得する。
date: 2017-04-06
tags: fluentd, RDS, AWS
author: kohei
ogp:
  og: 'Amazon RDS(for MySQL)のログはfluent-plugin-rds-logというプラグインを利用することで取得することができます。'
---

# はじめに
*Amazon RDS(for MySQL)* のログは [**fluent-plugin-rds-log**](https://github.com/shinsaka/fluent-plugin-rds-log) というプラグインを利用することで取得することができます。


<br>
# インストール

1.*fluent-plugin-rds-log* をインストールするには以下のパッケージを事前にインストールしておく必要があります。

```bash:パッケージ
$ sudo yum install gcc
$ sudo yum install mysql-devel
```

2.パッケージのインストールが完了したらプラグインをインストールします。

```bash:プラグイン
$ sudo td-agent-gem install fluent-plugin-rds-log
```


<br>
# RDS設定
1.ログを取得するにはRDSのパラメータグループを以下のように設定する必要があります。
>
log_output：TABLE
slow_query_log：1
general_log：1


<br>
# conf設定
1.先ずはログを取得するための *< source >*タグを設定します。

```text:取得設定
<source>
  type rds_log
  log_type slow
  host rds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com
  username awsuser
  password mypassword
  refresh_interval 30
  auto_reconnect true
  tag rds.db001.slow-log
  add_host false # add database hostname in record
</source>
```
今回はスローログを取得するための設定です。一般ログの場合は *general_log* にします。
*host* は対象となるRDSで *username* と *password* はRDSのアカウントです。


2.次に取得したログを出力する設定です。

```text:出力設定
<match rds.db001.slow-log>
  type file
  path /var/log/td-agent/rds-slow-log
</match>
```

3.再起動して反映させたら完了です。

```bash:再起動
$ sudo /etc/init.d/td-agent restart
```


<br>
# 確認
1.ログが出力されているか確認します。

```bash:出力確認
$ sudo ls /var/log/td-agent/
buffer			     rds-slow-log.20170404_1.log	      td-agent.log
db001			     rds-slow-log.20170405.b54c62b71eea28a57  td-agent.log-20170404.gz
rds-slow-log.20170404_0.log  rds-slow-log.20170405_0.log	      td-agent.log-20170405
```

出力されているのが確認できました。


<br>
# おわりに
[fluent-plugin-rds-log](https://github.com/shinsaka/fluent-plugin-rds-log) を使うとスローログと一般ログが簡単に取得できて便利です。
ただ、エラーログはこれでは取得できないので、それはやっぱりCLIとか使わないとです。


