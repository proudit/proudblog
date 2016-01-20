---
title: Redmine 3.2をAmazon Linux(release 2015.09)にインストールしてみた。
date: 2016-01-18
tags: Redmine, AmazonLinux, EC2, AWS
author: kohei
---

今回はAmazon Linux(release 2015.09)にRedmine 3.2をインストールする手順をまとめてみました。

方針としてはシンプルにしたいので、できるだけyumやインストール済みのパッケージを利用していきます。


# 必要なパッケージ等の準備

#### 1.開発ツールのインストール

```cmd:コマンド
# yum groupinstall "Development Tools"
```

#### 2.rubyのセットアップ
Amazon Linuxではデフォルトでrubyがインストールされています。今回はインストール済みのを利用し、追加で必要なライブラリのみをインストールします。

```cmd:コマンド
# ruby -v
# gem -v
# yum install ruby-devel
# gem install io-console
```

#### 3.bundlerのインストール

```cmd:コマンド
# gem install bundler --no-rdoc --no-ri
```


# データベースの準備

#### 1.MySQLのインストール
今回のデータベースはRDSを利用するため、クライアントをインストールします。

```cmd:コマンド
# yum install mysql mysql-devel
```

#### 2.データベースとユーザーの作成

```cmd:コマンド
# mysql -h <ホスト名> -u <ユーザー> -p <パスワード>
mysql> create database db_redmine default character set utf8;
mysql> grant all on db_redmine.* to user_redmine@localhost identified by '********';
mysql> flush privileges;
mysql> exit;
```


# apacheのインストール

#### 1.apacheのインストール

```cmd:コマンド
# yum install httpd httpd-devel
```

#### 2.confファイルの修正 - その１
"/etc/httpd/conf/httpd.conf"の以下のコメントアウトを外します。

```cmd:コマンド
# vim /etc/httpd/conf/httpd.conf
修正前：# NameVirtualHost *:80 → 修正後：NameVirtualHost *:80

# diff /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf_org
991c991
< NameVirtualHost *:80
---
> #NameVirtualHost *:80
```

#### 3.confファイルの修正 - その２
"/etc/httpd/conf.d/redmine.conf"を作成する。

```cmd:コマンド
# vim /etc/httpd/conf.d/redmine.conf
```

confの内容は適宜修正してください。以下は例となります。

```例:redmine.conf
<VirtualHost *:80>
    ServerName www.example.com

    DocumentRoot /var/www/redmine/public

    ErrorLog  "|/usr/sbin/rotatelogs /var/log/httpd/redmine/error_log.%Y%m%d 86400 540"
    CustomLog "|/usr/sbin/rotatelogs /var/log/httpd/redmine/access_log.%Y%m%d 86400 540" combined

</VirtualHost>
```


# Redmineの設定

#### 1.必要なパッケージのインストール

```cmd:コマンド
# yum -y install openssl-devel readline-devel zlib-devel curl-devel libyaml-devel libffi-devel
```

#### 2.ImageMagickと日本語フォントのインストール

```cmd:コマンド
# yum install ImageMagick ImageMagick-devel ipa-pgothic-fonts
```

#### 3.Redmineのダウンロード
下記のURLからRedmine 3.2のtarball(.tar.gz)をダウンロードします。
[http://www.redmine.org/projects/redmine/wiki/Download](http://www.redmine.org/projects/redmine/wiki/Download)

```cmd:コマンド
# wget http://www.redmine.org/releases/redmine-3.2.0.tar.gz
```

ダウンロードしたら展開・配置します。

```cmd:コマンド
# tar zxvf redmine-3.2.0.tar.gz
# mv redmine-3.2.0 /var/www/redmine
```

また、apacheからアクセスできるようにオーナーの変更をします。

```cmd:コマンド
# chown -R apache.apache /var/www/redmine/
```

配置したredmineディレクトリ配下のconfigディレクトリに"database.yml"と"configuration.yml"を作成します。

```database.yml
production:
  adapter: mysql2
  database: db_redmine
  host: <RDSのエンドポイント名>
  username: ユーザー
  password: "パスワード"
  encoding: utf8
```

```configuration.yml
production:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: "127.0.0.1"
      port: 25
      domain: 'ドメイン'

  rmagick_font_path: /usr/share/fonts/ipa-gothic/ipag.ttf
```

#### 4.Redmine用Gemパッケージの一括インストール
bandlerを使ってRedmineが使用するGemを一括でインストールします。

```
# bundle install --without development test --path vendor/bundle
```


#### 5.Redmineの初期設定とデータベースのテーブル作成

```cmd:コマンド
# bundle exec rake generate_secret_token
# RAILS_ENV=production bundle exec rake db:migrate
```


# passengerインストール
#### 1.passengerのインストール
Railsアプリケーションを実行するためのApacheモジュールであるpassengerをインストールします。

```cmd:コマンド
# gem install passenger --no-rdoc --no-ri
```

#### 2.Apache用モジュールのインストール

```cmd:コマンド
# passenger-install-apache2-module
```

以下のコマンドを実行することで、apacheに組み込む設定が確認できます。

```cmd:コマンド
# passenger-install-apache2-module --snippet
LoadModule passenger_module /usr/local/share/ruby/gems/2.0/gems/passenger-5.0.22/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /usr/local/share/ruby/gems/2.0/gems/passenger-5.0.22
  PassengerDefaultRuby /usr/bin/ruby2.0
</IfModule>
```

"/etc/httpd/conf.d/"にpassengerの設定ファイルを作成します。

```cmd:コマンド
# vim /etc/httpd/conf.d/passenger.conf
```

```conf:passenger.conf
# Passengerの基本設定。
# passenger-install-apache2-module --snippet を実行して表示される設定を使用。
# 環境によって設定値が異なりますので以下の5行はそのまま転記しないでください。
#
LoadModule passenger_module /usr/local/share/ruby/gems/2.0/gems/passenger-5.0.22/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /usr/local/share/ruby/gems/2.0/gems/passenger-5.0.22
  PassengerDefaultRuby /usr/bin/ruby2.0
</IfModule>

# Passengerが追加するHTTPヘッダを削除するための設定（任意）。
#
Header always unset "X-Powered-By"
Header always unset "X-Rack-Cache"
Header always unset "X-Content-Digest"
Header always unset "X-Runtime"

# 必要に応じてPassengerのチューニングのための設定を追加（任意）。
# 詳しくはPhusion Passenger users guide(http://www.modrails.com/documentation/Users%20guide%20Apache.html)をご覧ください。
PassengerMaxPoolSize 20
PassengerMaxInstancesPerApp 4
PassengerPoolIdleTime 3600
PassengerHighPerformance on
PassengerStatThrottleRate 10
PassengerSpawnMethod smart
RailsAppSpawnerIdleTime 86400
PassengerMaxPreloaderIdleTime 0
```

#### 3.apache起動
最後にapacheを起動します。

```cmd:コマンド
# service httpd start
# chkconfig httpd on
```

以上でRedmineのインストールが完了しました。

