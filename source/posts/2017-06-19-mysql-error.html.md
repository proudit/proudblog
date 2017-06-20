---
title: tomcatで「Cannot load JDBC driver class com.mysql.jdbc.Driver」のエラーについての対応方法。
date: 2017-06-19
tags: Tomcat
author: kohei
ogp:
  og: 'tomcatのcatalina.outで以下のログが出力されました。'
---

# はじめに
tomcatのcatalina.outで以下のログが出力されました。

```text:エラー
[Thread-3] FATAL stacktrace_log - Cannot load JDBC driver class 'com.mysql.jdbc.Driver'
org.apache.tomcat.dbcp.dbcp.SQLNestedException: Cannot load JDBC driver class 'com.mysql.jdbc.Driver'
```

<br>
# 原因
```Cannot load JDBC driver class 'com.mysql.jdbc.Driver'```となっているので、どうやらJDBC (Java Database Connectivity)のドライバが無いのが原因のようです。


<br>
# 対処

1. まずは MySQL の[ダウンロードページ](https://dev.mysql.com/downloads/)にアクセスします。

2. MySQL Connectorsの[Download](https://dev.mysql.com/downloads/connector/)をクリックします。
![スクリーンショット 2017-06-06 22.36.40.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ac289294-1523-cd8f-37d3-03ff44ec8310.png)

3. [Connector/J](https://dev.mysql.com/downloads/connector/j/)をクリックします。
![スクリーンショット 2017-06-06 22.39.42.png](https://qiita-image-store.s3.amazonaws.com/0/82090/da7b8b47-a5ee-e4f5-d753-4544f449ff34.png)

4. "Download Connector/J"ページへ移動するので、"Generally Available (GA)"の"Platform Independent"を選択し、tar.gzまたはzipファイルをDownloadします。
![スクリーンショット 2017-06-06 22.47.50.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3f1c2504-1732-f838-b7de-5131daa76c77.png)

5. ダウンロードしたドライバを解凍してtomcatのlib配下に配置します。

6. tomcatを再起動し、再ロードして完了です。


<br>
# おわりに
SQLデータベースなどのデータファイルにアクセスするにはアクセス先ごとに専用のドライバが提供されているので事前にインストールしてあげる必要があるんだと今回学びました。たしかに言われてみればapacheとかでもモジュールを必要に応じてインストールしてあげる必要があるのと同じですね。

