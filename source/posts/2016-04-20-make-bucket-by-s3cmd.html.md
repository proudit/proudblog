---
title: AWS CLIでAWS Account IDを取得する。
date: 2016-04-20
tags: s3cmd, IDCF
author: kohei
---

# はじめに
---
コマンドを利用してIDCFクラウドのオブジェクトストレージへアクセスするにはs3cmdを利用するのが一般的のようです。
一応、IDCフロンティアのサイトにも載ってました。
[IDCF - [Linux]サードパーティのツールご利用ガイド s3cmd のご利用方法]
(http://www.idcf.jp/help/storage/guide/s3cmd_guide.html)
とはいえ、動作保証やサポートはされていないみたいですが。。。


<br>
# オブジェクトストレージとは
---
ファイルシステムのようにデータをファイルやブロック単位で扱うのではなく、オブジェクトという単位で扱うストレージです。
また、ファイルシステムではないので階層構造がなく、オブジェクト同士はフラットな関係になっています。
基本的にデータサイズや保存数に制限がないため、大容量のデータを扱うことに適しています。
今回は[IDCFクラウドのオブジェクトストレージ](http://www.idcf.jp/cloud/storage/)ですが、他にも[AWSのAmazon S3](https://aws.amazon.com/jp/s3/)や[MicrosoftのAzure Storage](https://azure.microsoft.com/ja-jp/services/storage/)などが有名です。


<br>
# s3cmdインストール
---
とりあえず今回はMacOSとUbuntuのインストールを行いました。
**・MacOSの場合**

```bash:brewインストール
$ sudo brew install s3cmd
==> Downloading https://homebrew.bintray.com/bottles/s3cmd-1.6.0.el_capitan.bottle.tar.gz
######################################################################## 100.0%
==> Pouring s3cmd-1.6.0.el_capitan.bottle.tar.gz
🍺  /usr/local/Cellar/s3cmd/1.6.0: 55 files, 738.3K
```
<br>
**・Ubuntuの場合**

```bash:apt-getインストール
$ apt-get install s3cmd
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  s3cmd
0 upgraded, 1 newly installed, 0 to remove and 202 not upgraded.
Need to get 67.6 kB of archives.
After this operation, 295 kB of additional disk space will be used.
Get:1 http://jp.archive.ubuntu.com/ubuntu/ trusty/universe s3cmd all 1.1.0~beta3-2 [67.6 kB]
Fetched 67.6 kB in 0s (1,018 kB/s)
Selecting previously unselected package s3cmd.
(Reading database ... 91433 files and directories currently installed.)
Preparing to unpack .../s3cmd_1.1.0~beta3-2_all.deb ...
Unpacking s3cmd (1.1.0~beta3-2) ...
Processing triggers for man-db (2.6.7.1-1) ...
Setting up s3cmd (1.1.0~beta3-2) ...
```


<br>
# .s3cfgの作成
---
インストールができたので、次はs3cmdの設定ファイルとなる.s3cfgを作成します。
作成は以下のコマンドで行います。

```bash:.s3cfg作成
$ s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3
Access Key: ********************
Secret Key: ****************************************

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP and can't be used if you're behind a proxy
Use HTTPS protocol [No]:

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't conect to S3 directly
HTTP Proxy server name:

New settings:
  Access Key: ********************
  Secret Key: ****************************************
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] n

Save settings? [y/N] y
Configuration saved to '/hogehoge/.s3cfg'
```


<br>
# 設定の修正
---
.s3cfgのhost_baseとhost_bucketの値をIDCFのエンドポイントに変更します。
エンドポイントは
「IDCF管理画面 > オブジェクトストレージ > APIユーザー」で対象となるAPIユーザー名をクリックすると確認できます。

```bash:設定ファイル修正
$ cd ~/
$ vi .s3cfg
```

```text:.s3cfg変更点
[変更前]
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com

[変更後]
host_base = ds.jp-east.idcfcloud.com
host_bucket = %(bucket)s.ds.jp-east.idcfcloud.com
```

また、プライベートコネクトを利用する場合はhost_bucketのエンドポイントの最後を「.local」にする必要があります。

```text:プライベートコネクトの場合
host_bucket = %(bucket)s.ds.jp-east.idcfcloud.local
```

*実際にプライベートコネクトを利用する場合は他にも申請やサーバー設定などが必要となります。


<br>
# バケット参照
---

```bash:参照
$ s3cmd ls
```

はじめはバケットがないため、コマンドを実行しても何も返ってきません。
ただ、もし.s3cfgを変更せずにバケット参照すると以下のようにERRORとなります。

```bash:参照
$ s3cmd ls
ERROR: S3 error: 403 (InvalidAccessKeyId): The AWS Access Key Id you provided does not exist in our records.
```


<br>
# バケットの作成
---
ということで、バケットを作成してみます。

```bash:作成
$ s3cmd mb s3://proudit-test
Bucket 's3://proudit-test/' created
```

再度バケットを参照すると作成できているのが確認できます。

```bash:参照
$ s3cmd ls
2016-04-13 05:01  s3://proudit-test
```

<br>
# バケットの削除
---
とりあえず今回は作成まで確認できたので削除します。

```bash:削除
$ s3cmd rb s3://proudit-test
Bucket 's3://proudit-test/' removed
```

参照すると何も返ってこないので削除されたのが確認できます。

```bash:参照
$ s3cmd ls
```

以上で完了です。


<br>
# おわりに
---
とりあえず、今回はs3cmdをインストールしてバケットの作成・削除だけ行いました。
s3cmdのコマンドについてIDCフロンティアのサイトに載っていますので、その他のコマンドについて知りたい方はそちらを参照していただければと思います。
[IDCF - s3cmdのコマンド一覧](https://www.faq.idcf.jp/app/answers/detail/a_id/360/~/s3cmdのコマンド一覧)

また、awsコマンドを利用してもオブジェクトストレージにアクセスできるみたいです。
[s3cmdじゃなくてawscli s3を使おう～IDCFクラウドオブジェクトストレージでも](http://inaba-serverdesign.jp/blog/20151212/s3cmd_awscli_s3_idcf.html)
しかも検証によるとそっちの方が早いという結果が出たとのこと。
そこについては今度自分でも検証しようと思います。

