---
title: CloudWatchでセットしたアラームの通知テストをする。
date: 2017-02-16
tags: AWS, CloudWatch, aws-cli
author: kohei
ogp:
  og: 'CloudWatchでアラームを設定した際、ちゃんとアクションが実行されるのかテストしたくなりますよね？'
---

# はじめに
CloudWatchでアラームを設定した際、ちゃんとアクションが実行されるのかテストしたくなりますよね？
それが定時通知ならまだしも、エラー通知とかだと設定したあとで結局エラー発生しないと(またはさせないと)確認できないのはちょっと。。。
そんな時にaws-cliを利用すれば簡単に通知テストを行うことができますー。


<br>
# あらかじめ
今回は事前にアラームの設定はできている状態です。
![cloudwatch-alarm_test01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e38e7646-ddbd-a860-a541-484730a5f14a.png)
「*Error-CheckSnapshotLog*」という名前のアラームです。
直接は関係ありませんが、内容としては毎日Lambdaで取得しているスナップショットが失敗した時に通知されます。
普段は**不足(INSUFFICIENT_DATA)**となっていますが、なんらかの理由で*Lambda*の実行が失敗すると**Error**を吐くのでそれを検知したら指定したメールアドレスへ通知される仕組みです。


<br>
# 実践
ということで、このアラームが通知されるかどうかテストします。

```bash:コマンド
$ aws cloudwatch set-alarm-state --alarm-name "Error-CheckSnapshotLog" --state-value ALARM --state-reason "alarm-test"
```
このたった１行で完了ですw

| オプション        | 説明     |
|:---------------|:--------|
| --alarm-name   | アラーム名 |
| --state-value  | ステータス |
| --state-reason | 説明     |

これだと簡単に終わっちゃうので一応説明。
今回は"*Error-CheckSnapshotLog*"のステータスをaws-cliで強制的に**INSUFFICIENT_DATA**から**ALARM**というステータスに変更しています。
今回はテスト実行なので*--state-reason*を"*alarm-test*"としています。


<br>
# 結果
それではちゃんとCloudWatchのアラーム通知はされているのでしょうか？
![cloudwatch-alarm_test02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/18e1f6fa-07eb-8197-8972-c81f7521617d.png)

どうやらちゃんと通知ができたみたいです。
これで通知されないことが幸せなアラームに対しての通知テストができました。


<br>
# おわりに
CloudWatchアラームを設定したけど「これってちゃんと通知されるのかな？」と不安になってしまった時に便利なコマンドですね！
ただ、、、このコマンドってあくまで**ステータス変更**を行うだけなので、実際の条件が正しいかまでは。。。というオチがあったりもw


