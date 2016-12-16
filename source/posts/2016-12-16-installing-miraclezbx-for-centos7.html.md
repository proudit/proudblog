---
title: CentOS7にMIRACLE ZBXをインストールする。
date: 2016-12-16
tags: zabbix
author: kohei
ogp:
  og: 'CetnOS7にMIRACLE ZBXをインストールをしてみました。'
---

# はじめに
CetnOS7にMIRACLE ZBXをインストールをしてみました。

<br>
## MIRACLE ZBXとは
オープンソース「Zabbix」をベースにしたシステム監視ソリューションです。
基本的にはZabbixと同様、オープンソースとして提供されているので無償で利用することが可能です。
詳細については[ミラクル・リナックス](https://www.miraclelinux.com/product-service/zabbix/overview/top)を見ていただければと思います。

<br>
## 今回の仕様
今回インストールした際のOSと各ミドルウェアのバージョンです。

|           |version        |
|:----------|:--------------|
|OS　　　        |CentOS7.2      |
|MIRACLE ZBX|3.0.4-1        |
|Web　　       |Apache/2.4.6   |
|DB         |5.5.50-MariaDB |


<br>
# インストール
それではインストールを行いたいと思います。

<br>
## 事前準備
まずはSELinuxを無効にしておきます。

```bash:無効化
$ sudo setenforce 0
```

```bash:確認
$ sudo getenforce 
Permissive
```

<br>
## MIRRACLE ZBXインストール：その１
それではzabbixのインストールを行います。まずは_rpmキー_とリポジトリファイルをインストールします。

```bash:rpmキーのインポート
$ sudo rpm --import http://ftp.miraclelinux.com/zbx/RPM-GPG-KEY-MIRACLE
```

```bash:リポジトリファイルのインストール
$ sudo rpm -ihv http://ftp.miraclelinux.com/zbx/3.0/miracle-zbx-release-3.0-1.noarch.rpm
http://ftp.miraclelinux.com/zbx/3.0/miracle-zbx-release-3.0-1.noarch.rpm を取得中
準備しています...              ################################# [100%]
更新中 / インストール中...
   1:miracle-zbx-release-3.0-1        ################################# [100%]
```

インストールができたらあとは_yum_でパッケージを指定してインストールするだけです。

```bash:yumインストール
$ sudo yum install miracle-zbx-server-mysql miracle-zbx-web miracle-zbx-web-mysql miracle-zbx-web-japanese miracle-zbx-java-gateway miracle-zbx-agent miracle-zbx-get miracle-zbx-sender
~~~ 省略 ~~~                                                                                                                            
完了しました!
```

<br>
## MariaDBのインストール
今回はデータベースに**MariaDB**を利用します。インストールは_yum_で行えます。

```bash:yumインストール
$ sudo yum install mariadb mariadb-server
~~~ 省略 ~~~
完了しました!
```

```bash:起動
$ sudo systemctl start mariadb
```

<br>
## データベースの作成
MariaDBをインストールしたら、空のデータベースを作成します。

```mysql:データベースの作成
MariaDB [(none)]> create database zabbix;
Query OK, 1 row affected (0.00 sec)
```

作成が完了したらzabbixからアクセスするためのユーザーを作成します。

```mysql:ユーザー作成
MariaDB [(none)]> grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by 'hogehoge';
Query OK, 0 rows affected (0.00 sec)
```

作成が完了したら_/usr/share/doc/miracle-zbx-server-mysql-3.0.4/_配下にあるスキーマ(**create.sql.gz**)を先ほど作成した空のデータベースへインポートします。

```bash:リストア
$ zcat /usr/share/doc/miracle-zbx-server-mysql-3.0.4/create.sql.gz | mysql -uroot zabbix
```

<br>
## Apacheの設定
_MIRACLE ZBX_をインストールすると_Apache_も一緒にインストールされます。
また、_/etc/httpd/conf.d/_配下に**zabbix.conf**が配置されるため、このファイルをブラウザからアクセスできるように修正します。

``` bash:zabbix.confの修正
$ vi /etc/httpd/conf.d/zabbix.conf 
```

修正内容は5〜55行目のコメントアウトを外すだけで大丈夫です。

```text:修正内容
Alias /zabbix /usr/share/zabbix

<Directory "/usr/share/zabbix">
    Options FollowSymLinks
    AllowOverride None

    <IfModule mod_authz_core.c>
      # Apache 2.4
      Require all granted
    </IfModule>

    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order allow,deny
      Allow from all
    </IfModule>

    php_value max_execution_time 600
    php_value date.timezone Asia/Tokyo
    php_value memory_limit 256M
    php_value post_max_size 32M
    php_value upload_max_filesize 16M
    php_value max_input_time 600
    php_value always_populate_raw_post_data -1
</Directory>

<Directory ~ "^/usr/share/zabbix/(conf|api|include|local)/">
    <IfModule mod_authz_core.c>
      # Apache 2.4
      Require all denied
    </IfModule>

    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order deny,allow
      Deny from all
    </IfModule>

    <files *.php>
      <IfModule mod_authz_core.c>
        # Apache 2.4
        Require all denied
      </IfModule>

      <IfModule !mod_authz_core.c>
        Order deny,allow
        Deny from all
      </IfModule>

    </files>
</Directory>
```

修正したらapacheを起動します。

```bash:起動
$ sudo systemctl start httpd
```

<br>
## zabbix-serverの設定
zabbix-serverの設定を行います。
ここでは接続先となるDBHostとzabbixアカウントのDBPasswordを設定します。

```bash:zabbix_server.conf修正
$ vi /etc/zabbix/zabbix_server.conf
```

```text:修正内容
DBHost=localhost
DBPassword=hogehoge
```
先ほどmysqlコマンドで作成したアカウントとパスワードとなるため、作成したユーザーが違う場合はDBUser=zabbixも変更してください。

修正が完了したら起動します。

```bash:起動
$ sudo systemctl start zabbix-server
```

<br>
## 自動起動設定
サーバーが再起動した際などでもプロセスが自動起動するよう設定しておきます。

```bash:apacheの自動起動有効化
$ sudo systemctl enable httpd
Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
```

```bash:MariaDB自動起動有効化
$ sudo systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
```

```bash:zabbix-server自動起動設定
$ sudo systemctl enable zabbix-server
Created symlink from /etc/systemd/system/multi-user.target.wants/zabbix-server.service to /usr/lib/systemd/system/zabbix-server.service.
```

<br>
## MIRRACLE ZBXインストール：その２
サーバーでの設定が一通り完了したら最後はブラウザから設定を行います。
まずは_**http://< IPまたはドメイン >/zabbix**_にアクセスします。

初期のユーザー名とパスワードを入力して**「サインイン」**します。

[初期]
ユーザー名：Admin
パスワード：zabbix

![miracle-zabbix-install_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1b82362d-8fd9-7f27-bf7f-a6e25c400252.png)


**「Next step」**をクリックします。
![miracle-zabbix-install_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ed194bca-92c2-5859-5315-d4ecd053a932.png)

インストール要件の事前チェックが行われるので全て[_OK_]になっていれば**「Next step」**をクリックします。
![miracle-zabbix-install_03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d3c7086d-cd07-b12b-a47a-b6120f2d4054.png)

_Database host_と_Database name_を指定し、アクセスするための_User_と_Password_を入力して**「Next stop」**をクリックします。
![miracle-zabbix-install_04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/467d2b37-167c-e5bf-589b-e228055c41e3.png)

デフォルトで**「Next step」**をクリックします。
![miracle-zabbix-install_05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/efb89984-aa77-c77b-6818-579194f4b1b5.png)

内容を確認して問題なければ**「Next step」**をクリックします。
![miracle-zabbix-install_06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/279ef873-ca48-ca13-6ae4-6e15528925a7.png)

最後に**「Finish」**をクリックしたらインスールが完了です。
![miracle-zabbix-install_07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f172df91-aace-8413-d29c-d49eb98f0f75.png)

ログインしてZabbixサーバーの起動が[はい]になっているのでちゃんと動いているのが確認できます。
![miracle-zabbix-install_08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/321408fd-41f2-794e-d8d9-38babc57c01c.png)


<br>
# 気をつけるポイント
インストールする際にいくつか気をつけたほうがいいかなと思ったポイントがあったのでまとめておきたいと思います。

・MySQLはMariaDBへ変更。
CentOS7からMySQLがMariaDBにかわっています。`yum install mysql`ではなく`yum install mariadb`になります。

・SELinuxを無効にする。
SELinuxが有効になっているとZabbixサーバーの起動が「いいえ」となってしまい上手く認識されないので忘れず無効にしておきましょう。
![miracle-zabbix-install_18.png](https://qiita-image-store.s3.amazonaws.com/0/82090/05449430-a78c-8a81-d97d-c5802dace408.png)

・データベーススキーマのインポートを忘れず行う。
データベースを作成したら忘れずにスキーマ(create.sq.gz)をインポートしましょう。
また、ZABBIX の場合、 create.sql.gz がある場所は_/usr/share/doc/zabbix-proxy-mysql-3.0.0/_などになりますが MIRACLE ZBX の場合は_/usr/share/doc/miracle-zbx-server-mysql-3.0.4/_になります。
出ないとブラウザ設定で先へ進めません。
![miracle-zabbix-install_14.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f370578f-42ff-bd5d-a61a-022bc7ad842c.png)


<br>
# おわりに
初めてZabbixの構築を行いましたが、思ったより注意するポイントあるなと感じました。
特に初期データベースは自分で_create_してからデータをインポートしないといけないのでうっかり忘れないよう注意ですね。
また、今回はMIRRACLE ZBXでしたが基本的な流れはZABBIXでも同じだと思います。(スキーマのあるパスとかが変わるくらい。)
あとは、CentOS7を初めてレベルで触ったのでそこらへんの扱いにちょっと手こずりました。まだまだですね。。。

