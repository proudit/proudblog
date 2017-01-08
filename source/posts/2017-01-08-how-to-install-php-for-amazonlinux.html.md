---
title: Amazon Linuxにphp4.4をmakeインストールする。
date: 2017-01-08
tags: AWS, PHP
author: kohei
ogp:
  og: 'Amazon Linuxにphp 4.4をmakeインストールしてみました。'
---

# はじめに
Amazon Linuxにphp 4.4をmakeインストールしてみました。

|OS/ミドルウェア  |Version |
|:--          |:--     |
|Amazon Linux |2016.09 |
|php          |4.4.9   |


<br>
# apacheインストール
まずはapacheをインストールしておきます。

```bash:インストール①
$ sudo yum install httpd httpd-devel
```

また、makeするにはgccやflexなど必要になってくるのでそれらもインストールしておきます。

```bash:インストール②
$ yum install gcc flex zlib-devel curl-devel libjpeg-devel libpng-devel
```

<br>
# phpインストール
それでは、phpのインストールです。

<br>
## ソースの取得
[php museum](http://museum.php.net/)に過去のバージョンのphpが置いてあるのでそこから取得します。

```bash:ソース取得
$ wget http://museum.php.net/php4/php-4.4.9.tar.gz
```

<br>
## 解凍
取得したら解凍です。

```bash:解凍
$ tar zxvf php-4.4.9.tar.gz
```

<br>
## make & make install
では、makeです。

```bash:移動
$ cd php-4.4.9
```

```bash:configure
$ ./configure \
　　--enable-mbstring \
　　--enable-mbregex \
　　--enable-gd-native-ttf \
　　--enable-exif \
　　--with-apxs2=/usr/sbin/apxs \
　　--with-freetype-dir=/usr/lib64 \
　　--with-jpeg-dir=/usr/lib64 \
　　--with-png-dir=/usr/lib64 \
　　--with-zlib-dir=/usr/lib64 \
　　--with-curl

〜 省略 〜

+--------------------------------------------------------------------+
|                        *** WARNING ***                             |
|                                                                    |
| You chose to compile PHP with the built-in MySQL support.  If you  |
| are compiling a server module, and intend to use other server      |
| modules that also use MySQL (e.g, mod_auth_mysql, PHP 3.0,         |
| mod_perl) you must NOT rely on PHP's built-in MySQL support, and   |
| instead build it with your local MySQL support files, by adding    |
| --with-mysql=/path/to/mysql to your configure line.                |
+--------------------------------------------------------------------+
| License:                                                           |
| This software is subject to the PHP License, available in this     |
| distribution in the file LICENSE.  By continuing this installation |
| process, you are bound by the terms of this license agreement.     |
| If you do not agree with the terms of this license, you must abort |
| the installation process at this point.                            |
+--------------------------------------------------------------------+
|                          *** NOTE ***                              |
|            The default for register_globals is now OFF!            |
|                                                                    |
| If your application relies on register_globals being ON, you       |
| should explicitly set it to on in your php.ini file.               |
| Note that you are strongly encouraged to read                      |
| http://www.php.net/manual/en/security.globals.php                  |
| about the implications of having register_globals set to on, and   |
| avoid using it if possible.                                        |
+--------------------------------------------------------------------+

Thank you for using PHP.
```

今回、configureオプションは適当に与えてますが、あくまで例ですので必要に応じてそこは変更してください。

configureが無事完了したらmakeです。

```bash:make
$ make

〜 省略 〜

Build complete.
(It is safe to ignore warnings about tempnam and tmpnam).
```

makeも完了したら`make install`しましょう。

```bash:install
$ sudo make install

〜 省略 〜

Build complete.
(It is safe to ignore warnings about tempnam and tmpnam).
```

<br>
# 確認
`php -v`でバージョンを確認します。

```bash:確認
$ php -v
PHP 4.4.9 (cli) (built: Jan  8 2017 11:53:19)
Copyright (c) 1997-2008 The PHP Group
Zend Engine v1.3.0, Copyright (c) 1998-2004 Zend Technologies
```

無事インストールが完了しました。

<br>
# おわりに
とりあえずインストールしてみたので今回書いてみました。
ポイントとしては`make`するのに必要なパッケージを事前にインストールしておくくらいでしょうか。
あとは`make`は`sudo`しなくても良いけど、`make install`はroot権限で実行してあげないとエラーが出てしまうのでそこもポイントですかね。

