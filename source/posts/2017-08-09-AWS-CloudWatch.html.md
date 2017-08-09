---
title: AWS Organizationsでアカウントの新規作成とログイン時の注意点
date: 2017-08-09
tags: AWS,
author: ayako
ogp:
  og:
    description: ''
---
#CloudWatchとは
---

AWSで実行されているアプリケーションをリアルタイムでモニタリングするサービス。
あくまでもモニタリングサービスなので監視サービスとして完全なる役割を果たすことができるかどうかは利用の仕方によるところかと思います。
カスタムメトリクスも駆使すればzabbixの代用もある程度は可能なのかもしれません。

#EC2の死活監視を設定してみる
---
試しに簡単な死活監視の設定をしてみました。

コンソールにログインして対象のEC2インスタンスを選択します。
タブで、ステータスチェックを選択、[ステータスチェックアラームの作成]を行います。
![CW_01.png](https://qiita-image-store.s3.amazonaws.com/0/174392/811388ff-29ce-2aa1-6425-96e9e585eb0a.png)

アラームの通知先はあらかじめSNSで作成。
SNSの作成についてはこちら。↓
[AWS SNS(Amazon Simple Notification Service)の通知設定をしてみる](https://blog.proudit.jp/2017/07/10/AWS-SNS.html)

![CW_02.png](https://qiita-image-store.s3.amazonaws.com/0/174392/3a0cce8f-e6bc-9eb1-28fc-6d739c62fc32.png)

アラームの作成ポチッとして、作成が完了です！

![CW_03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/7c317e41-2c4c-c31f-edc6-e68ce78ddabe.png)

CloudWatchの画面からも設定したアラームが正常に設定されたことが確認できました。

![CW_04.png](https://qiita-image-store.s3.amazonaws.com/0/174392/bdefb95e-b7a2-8acf-7215-16c90a936148.png)

以上でEC2の死活監視の設定完了です。

ちなみに、通知がちゃんと飛ぶのか確認するため、コンソールからインスタンスを停止してみたのですが、どうやらこれでは検知してもらえないようです。。。

