---
title: "Amazon RDS for MySQL のログを Amazon CloudWatch Logs へ直接保存する。"
date: 2018-02-27
tags: AWS, RDS, CloudWatch
author: kohei
ogp:
  og: 'Amazon Web Services ブログでAWS Step Functions – ビジュアルワークフローを使ったアプリケーションのビルドと配布というのがあったので、AWS Step Functionsを使ってビジュアルワークフローを作成してみました。'
---

# はじめに
Amazon RDS のログが Amazon CloudWatch へ直接保存できるようになったということで、試してみました。

<br>
# 対応ログタイプ

RDSでエクスポートできるログタイプは以下になります。

- Error log – 起動および停止にデータベースエンジンによって生成された診断メッセージが含まれています
- General query log – クライアントから受け取ったすべてのSQLステートメントのレコードと、クライ アントの接続および切断時間を含みます。
- Slow query log – 設定された時間よりも実行に時間かかったクエリや、定義された行数を超える行を走査したSQL文のレコードが含まれています。 両方の閾値は設定可能です。
- Audit log – MariaDB Audit Pluginを使用して提供されるこのログは、監査目的でデータベースアクティビティを記録します。

ログイベントは CloudWatch のロググループにログストリームの形式で保存されます。
また、ログはDBインスタンスの同じリージョン内で保存されます。


<br>
# パラメータグループの設定
ログをCloudWatchへ送るために、まずはログ出力を有効にする必要があります。

今回は「set-log」というパラメータグループを新規に用意して設定しています。
![スクリーンショット 2018-02-06 11.14.18.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9e9df04c-c4b9-78d2-e257-c1d9fd5cf268.png)

作成したらパラメータグループをクリックします。
![スクリーンショット 2018-02-06 11.15.05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0fec9baa-b10f-8f50-251d-e52677cee827.png)

それでは、各ログを有効にするために以下の設定を行います。

<br>
### Slow query log
slow_query_log のパラメータを修正します。
デフォルトは値なし(0)なので１へ変更します。
![スクリーンショット 2018-02-06 11.16.40.png](https://qiita-image-store.s3.amazonaws.com/0/82090/68fbac7a-bd1d-0c32-7f92-d2f04e76c250.png)

また、スロークエリーログに出力される値は long_query_time で設定できます。

![スクリーンショット 2018-02-07 22.36.16.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ddd3f33b-250a-b819-720c-8ee86af46a15.png)

デフォルトは値なしですがその場合はデフォルト値(10秒)となります。


<br>
### General query log
general_log のパラメータを修正します。
こちらも、デフォルトは値なし(0)なので１へ変更します。
![スクリーンショット 2018-02-06 11.17.08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ce8b0584-ae6c-38f9-56c2-56f08ab68008.png)

<br>
### Error log
Error log は標準で有効なのでパラメータの変更は不要です。

<br>
### ログ出力
log_outpu のパラメータを修正します。
デフォルトのログ出力はTABLEなのでFILEへ変更します。
![スクリーンショット 2018-02-06 11.17.41.png](https://qiita-image-store.s3.amazonaws.com/0/82090/461e23b6-db01-529d-0868-80d867d1c188.png)

注意: 本番DBインスタンスのAudit logとGeneral query logを有効にする場合は注意が必要です。これらのログは実行されたすべてのステートメントをキャプチャして記録するため、DBインスタンスのパフォーマンスが低下する可能性があります。


<br>
# データベースの設定変更
新規の場合は作成時にパラメータグループを指定します。既存のDBインスタンの場合はパラメータグループの変更を行うか、先ほど設定したログ内容を

「ログのエクスポート」でエクスポートするログを選択します。
![スクリーンショット 2018-02-06 11.33.33.png](https://qiita-image-store.s3.amazonaws.com/0/82090/67e44e24-bd4c-50ee-1c22-ffadc9a53850.png)


以上で完了です。


<br>
# 確認
Amazon CloudWatch Logs を確認します。
ログは以下のような命名パターンで作成されます。

```text:log
/aws/rds/instance/<db-instance-id>/<log-type>
```

実際に先ほど設定したログが保存されると以下のようになります。

![スクリーンショット 2018-02-06 11.52.09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/06a9c5e2-5684-fcd2-730c-b5f276631db9.png)
![スクリーンショット 2018-02-06 12.06.08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/27ac1267-6d59-fd60-3eaf-8ff7c09ad966.png)

ログのエクスポートで全般ログにチェックを入れませんでしたが、入れるとgeneralという名前のログが保存されます。


<br>
# Amazon RDS → Amazon CloudWatch Logs
Amazon RDSはDBインスタンスと同じアカウント内のロググループにservice-linked roleを使用してログを送信します。これにより、Amazon RDSはアカウント内の関連するロググループにアクセスできます。
ログの送信を有効にすると、AWSServiceRoleForRDSという追加のIAMロールが通常は作成されます。
設定後にはIAMの管理画面で実際に確認ができます。

![スクリーンショット 2018-02-06 21.23.32.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2de974e3-6c92-9084-5606-6ff9d4f3e632.png)


<br>
# おわりに
今まで、RDSのログを保存するのにCLIなどで定期的にダウンロードを行っていましたが、今後はそういったことが不要になるのはとても助かります。
また、これによって Amazon CloudWatch でログ監視ができるようになるため、運用負荷がとても軽くなるなと感じました。

