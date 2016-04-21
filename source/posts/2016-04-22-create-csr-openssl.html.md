---
title: opensslコマンドでCSRを作成する
date: 2016-04-22
tags: 非エンジニアから見たインフラの世界
author: ayako
---

#はじめに

<font size=2>
以前からCSRの作成はやったことがありますが、opensslコマンドでの作成は初めて。
(今までは用意されていたシェルを利用していました。)
備忘録として一連の作業内容を記録したいと思います。

unix系のOSでは標準で利用できるようですが、windows上で利用する場合はアプリケーションのインストールが必要となるようです。
https://jp.globalsign.com/support/faq/177.html
</font>


##事前準備
　・サーバキーペア用パスフレーズ
　・DN情報

※今回bit数は2048bitを指定、アルゴリズムはsha-2で作成します。


#さっそく作成
まずopensslがちゃんと利用できるのかコマンドを入れてみました。
試しにダウンロードされているバージョンを確認。

```bash:
$ openssl version
OpenSSL 0.9.8zg 14 July 2015
```

<font size=2>　
今回、普段使っているMAC上で作成を行ったので、デスクトップにwww.proudit.jpというディレクトリを作り、そこで作業をしました。
</font>

まずキーペアの作成を行います。

※2048bitを指定

```bash:
$ openssl genrsa -des3 2048 > www.proudit.jp.key

Generating RSA private key, 2048 bit long modulus
...............................................+++
......................+++
e is 65537 (0x10001)
Enter pass phrase:
Verifying - Enter pass phrase:
```

続いてCSRの作成です。
コマンド入力後、DN情報を入力します。

※アルゴリズムはsha-2としますので、-sha256と記述します

```bash:

$ openssl req -new -key www.proudit.jp.key -sha256 -out www.proudit.jp.csr
Enter pass phrase for www.proudit.jp.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:JP
State or Province Name (full name) [Some-State]:Tokyo
Locality Name (eg, city) []:Shinjuku-ku
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Proudit Inc.
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:www.proudit.jp
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```


CSRの内容を確認。


```bash:

$ openssl req -text -noout -in /Users/ayako/Desktop/www.proudit.jp/www.proudit.jp.csr

Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=JP, ST=Tokyo, L=Shinjuku-ku, O=Proudit Inc., CN=www.proudit.jp
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (2048 bit)
                Modulus (2048 bit):
                   
　　　　　　　　　　　　　※略※     
      Signature Algorithm: sha256WithRSAEncryption 
　　　　　　　　　　　　　※略※       
```


DN情報、bit数、アルゴリズム、指定通りで作成されていることが確認できました！

