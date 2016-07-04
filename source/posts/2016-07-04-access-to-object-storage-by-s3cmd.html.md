---
title: 【IDCFクラウド】s3cmdでオブジェクトストレージへアクセスする
date: 2016-07-04
tags: IDCFクラウド
author: kohei
ogp:
  og:
    description: 'IDCFクラウドのオブジェクトストレージにコマンドでバケットを作成したりファイルをア
ップロードしたりするには`s3cmd`コマンドで行えます。
今回、その`s3cmd`のインストールと簡単な操作(バケットの作成・削除)を行いたいと思>います。'
---

# はじめに
---
IDCFクラウドのオブジェクトストレージにコマンドでバケットを作成したりファイルをアップロードしたりするには`s3cmd`コマンドで行えます。
今回、その`s3cmd`のインストールと簡単な操作(バケットの作成・削除)を行いたいと思います。

<br>
# s3cmdインストール
---
まずはじめに`s3cmd`のインストールを行いたいと思います。

<br>
## MacOSの場合

```bash:インストール(MacOS)
$ sudo brew install s3cmd
==> Downloading https://homebrew.bintray.com/bottles/s3cmd-1.6.0.el_capitan.bottle.tar.gz
######################################################################## 100.0%
==> Pouring s3cmd-1.6.0.el_capitan.bottle.tar.gz
🍺  /usr/local/Cellar/s3cmd/1.6.0: 55 files, 738.3K
```

<br>
## Ubuntuの場合

```bash:インストール(Ubuntu)
$ sudo  apt-get install s3cmd
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
## 確認

```bash:確認
$ s3cmd --version
s3cmd version 1.6.0
```

インストールが確認できました。


<br>
# .s3cfgの作成
---
`s3cmd`コマンドのインストールができたので、次は設定ファイルの`.s3cfg`を作成します。
作成は以下のコマンドで行います。

```bash:コンフィグ設定
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
Configuration saved to '/root/.s3cfg'
```


<br>
# 設定の修正
---
`.s3cfg`の_host_base_と_host_bucket_の値をIDCFのエンドポイントに変更します。
エンドポイントは
「IDCF管理画面 > オブジェクトストレージ > APIユーザー」で対象となるAPIユーザー名をクリックすると確認できます。

```bash:.s3cfg修正
$ cd ~/
$ vi .s3cfg
```

```text:変更点
[変更前]
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com

[変更後]
host_base = ds.jp-east.idcfcloud.com
host_bucket = %(bucket)s.ds.jp-east.idcfcloud.com
```


<br>
# バケット参照
---

```bash:参照
$ s3cmd ls
```

はじめはバケットがないため、コマンドを実行しても何も返ってきません。
ただ、もし`.s3cfg`を変更せずにバケット参照すると以下のように_ERROR_となります。

```bash:エラー時の出力
$ s3cmd ls
ERROR: S3 error: 403 (InvalidAccessKeyId): The AWS Access Key Id you provided does not exist in our records.
```


<br>
# バケットの作成
---
ということで、バケットを作成してみましょう。

```bash:作成
$ s3cmd mb s3://proudit-test
Bucket 's3://proudit-test/' created
```

再度バケットを参照してみるとちゃんと作成できているのが確認できます。

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

<br>
# おわりに
---
今回、オブジェクトストレージへアクセスしオブジェクトの作成や削除といった一般的な操作を行いました。
ですが、もしプライベートコネクトを利用してオブジェクトストレージへアクセスを行いたい場合、プライベートコネクトの申請やルーティングの追加、`.s3cfg`の修正などが必要になるので注意してください。
そこらへんの設定についてはまた時間があるときに紹介しようと思います。



以上で完了です。

