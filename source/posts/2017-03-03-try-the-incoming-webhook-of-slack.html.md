---
title: slackのIncoming Webhookを試してみた。
date: 2017-03-03
tags: Slack
author: kohei
ogp:
  og: '仕事で **slack** を利用している人は多いと思います。チャットだけでなく、GitHubやZabbixなど、いろんな外部サービスと連携することも可能です。
そんなわけでまずは **Incoming Webhook**を試してみました。'
---

# はじめに
仕事で **slack** を利用している人は多いと思います。チャットだけでなく、GitHubやZabbixなど、いろんな外部サービスと連携することも可能です。
そんなわけでまずは **Incoming Webhook**を試してみました。


<br>
# 設定
まずは [**slack API**](https://api.slack.com/) のページへ行き、 **Start Building** をクリックします。
![slack-inncommint-webhooks01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6ea0095f-320d-56a7-e5b2-a8ee7fd23f05.png)

<br>
#### ***Create an App***
すると Web API 作成画面が現れるます。
**App Name** と **Development Slack Team** を選択したら **Create App** をクリックして作成します。
![slack-inncommint-webhooks02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f8062ff6-853b-ba8a-39cb-ffeb3676597a.png)

<br>
#### **Incoming Webhooks**
作成したら Features の **Incoming Webhooks** から、 **Activate Incoming Webhooks** を **On** にします。
![slack-inncommint-webhooks03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1a46d66c-6977-eddb-60ac-f9879e645dd6.png)

**On** にすると Webhook URLの作成ができるようになるので、 **Add New Webhook to Team** をクリックして作成画面へと進みます。
![slack-inncommint-webhooks03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9e82fc31-856a-5fec-4b84-eb9b654cbbcc.png)

ここでは投稿先をとなる **Channel** の指定を行います。
今回はとりあえず *#general* を指定し、 **Authorize** をクリックして作成します。
![slack-inncommint-webhooks05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5900dadd-424e-7ec8-b6d2-9ec25dfa06ca.png)

すると、 **Webhook URL** に先ほど作成した *#general* 宛のURLがリストされます。
![slack-inncommint-webhooks06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/de716f2b-fd1c-849f-3cfd-b88d7707d5ca.png)

以上で設定は完了です。


<br>
# 投稿
ということで投稿してみます。
同じように作成していた場合、 **Sample curl request to post to a channel** をコピペするだけで大丈夫です。
![slack-inncommint-webhooks07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6d98e073-f773-8fa4-528e-7e1672a74f6d.png)

もし、違った場合はURLの部分を該当のURLヘ書き換えて実行しましょう。

```bash:コマンド(Hello,World!)
$ curl -X POST -H 'Content-type: applicatiodata '{"text":"Hello, World!"}' https://hooks.slack.com/services/*********/*********/************************''
```

APPからslack に *Hello, World!* と投稿されたら成功です。
![slack-inncommint-webhooks08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3dc29e4c-f760-bf5a-c2ce-c13204ba6934.png)

また、 *text* の内容を変えれば違う言葉を投稿することも可能です。

```bash:コマンド(こんにちは)
curl -X POST -H 'Content-type: application/json' data '{"text":"こんにちは!"}' https://hooks.slack.com/services/*********/*********/************************''
```

![slack-inncommint-webhooks09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/862e2dbc-2afc-9c05-a2ca-06cf966acb00.png)


<br>
# おわりに
ちょっと設定するだけで Incoming Webhook はとても簡単に利用できます。
これを元にいろいろ試せたらなと思います。

