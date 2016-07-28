---
title: エンジニアじゃなくても簡単にAWSでWordPressが使えます！
date: 2016-07-28
tags: AWS,WordPress,
author: ayako
ogp:
  og:
    description: 'AWSを使ったことがなくても、知識がなくてもAWSで簡単にWordPressが使えてしまいます。'
---

#はじめに
---
AWS上でWordPressを使ってみたいなとふと思い立ちました。勉強もかねて。
とは言え、やっぱり自分でサーバにインストールするのは...
簡単に素人でもできる方法はないかなと、調べてみると。
既にWordPressがインストールされたAMIがあるようです！

インストールする必要がないので、一気にハードルは下がりますね！
AWSのページにきちんと設定手順もあります！

#手順は？
---
既にアカウントがある場合は、そのままサインアップ。
まだアカウントを持っていない方はアカウント作成をします。
12ヶ月間無料利用枠を利用できるお試し枠を利用することができます。
もちろん無料利用枠内で、WprdPressインストール済みのAMIが使えます。

サインアップすると、画面上にサービスアイコンがずらり。
その一番左上AmazonEC2のインスタンスを起動し、インスタンスの作成へ。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_01.png)

AWSMarketplaceへ移動し、WordPressで検索をかけると、
ずらりと出てきます。
この中からWordPress powered by BitNami (HVM) を選択します。
![AWS_WordPress](./2016/0728_WordPress/aws_wp_02.png)
![AWS_WordPress](./2016/0728_WordPress/aws_wp_03.png)

次はインスタンスタイプの選択です。
無料利用枠を利用している方は、t2.maicroを選択。
今回利用しているアカウントは無料利用枠対象期間は過ぎてしまっているので、一番小さいnanoで。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_04.png)

インスタンスの詳細設定。
特に手を加えることなくそのままそのまま進みます。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_05.png)

次は、ストレージの設定。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_06.png)

インスタンスのタグ付け。
インスタンスの名前の設定をします。
値の部分は任意のものを入力。今回はwordpressと入力。確認と作成をポチッと。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_07.png)

インスタンス作成の確認を行い、作成。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_08.png)

キーペア設定画面が出てきます。
SSHログインをする際に必要になる設定です。ここではキーペアなしで続行をして、インスタンスの作成へ。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_09.png)

インスタンスの作成をしています。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_10.png)

無事、インスタンスの作成が完了しました。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_11.png)

インスタンスが作成できたら、実際にサーバにインストールされている
サイトの確認をしてみます。
作成したインスタンスの情報から、パブリックIPを参照し、サイトにアクセスしてみます。

サイトのカスタマイズをするため、まずは管理画面へアクセスします。

管理画面にアクセスするためのパスワードを確認します。
アクション＞インスタンスの設定＞システムログの取得
![AWS_WordPress](./2016/0728_WordPress/aws_wp_12.png)

システムログのウィンドウが出てくるので、下の方までスクロール。
ハッシュマークで囲まれているので見つけやすいです。

![AWS_WordPress](./2016/0728_WordPress/aws_wp_13.png)

管理画面(URL:パブリックIP/admin ex.54.192.32.144/admin)にアクセスし、username:user/PW:システムログで取得したもの

を入力するとログインできます！

![AWS_WordPress](./2016/0728_WordPress/aws_wp_14.png)

デフォルトの設定は英語になっているので、管理画面にログイン後
Settings＞Site Languageを日本語に変更＞Save ChangesすればOKです。

#おわりに
---
参考にした手順通り、そのままでした。簡単でした。
AWSを使ったことがないって人でも大丈夫！

[参考サイト：WordPress Webサイトの起動](https://aws.amazon.com/jp/getting-started/launch-a-wordpress-website/)

