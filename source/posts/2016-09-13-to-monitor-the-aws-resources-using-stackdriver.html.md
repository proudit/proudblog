---
title: Google Stackdriverを使ってAWSのリソースをモニタリングしてみた。
date: 2016-09-13
tags: GCP,AWS
author: kohei
ogp:
  og: 'Stackdriverはもともと「AWSのモニタリング」を>メインにしていたサービスです。'
---

# はじめに
[**Stackdriver**](http://www.stackdriver.com/)はもともと「AWSのモニタリング」をメインにしていたサービスです。
ですが、Googleが2014年に買収したため、「[**Google Stackdriver**](https://cloud.google.com/stackdriver/?hl=ja)」にサービス名を変更して[GCPNext16](https://cloudplatformonline.com/NEXT2016.html)で[発表](http://googlecloudplatform-japan.blogspot.jp/2016/03/google-stackdriver-gcp-aws.html)されました。
機能としては「**リッチダッシュボード**」、「**アップタイムモニタリング**」、「**アラート**」、「**ログ解析**」、「**トレーシング**」、「**エラーレポート**」、「**プロダクションデバッグ**」などがあります。
また、GCPとAWSの両方のクラウドプラットフォームを統合してモニタリングができます。

ということでAWSのリソースをモニタリングしてみます。


<br>
# Stackdriverの利用開始
[Stackdriver](http://www.stackdriver.com)のサイトへ行き「**Try the Free Beta**」をクリックします。
![01_stackdriver01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3c374f69-ff6e-c4a3-e25e-6af868449aac.png)

GCPの「[**GOOGLE STACKDRIVER**](https://cloud.google.com/stackdriver/)」のサイトへ移動するのでここにある「コンソールへ移動」をクリックします。(というか直接こっちのサイトへアクセスしても大丈夫です。)
![01_stackdriver02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/597ffebb-5dd4-3c32-dc24-5ba5aa252d2c.png)

Stackdriverを利用するにはGCPが利用できる状態にしておく必要があります。
まだの場合は「**コンソールへ移動**」をクリックするとGCP利用登録画面へ移動します。


<br>
# GCPプロジェクトの作成
GCPのStackdriverのサービスへ移動するので、とりあえず今回は「**プロジェクトの作成」**をクリックします。
![01_stackdriver03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c5f58deb-a4bc-c01d-d625-becba06c61f0.png)

プロジェクト名を入力して「**作成**」をクリックします。
![01_stackdriver04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6d8f7539-3bdb-762c-d2b1-b30b6ae155fc.png)

「**Create a new Stack account**」にチェックして「**Continue**」をクリックします。
![01_stackdriver05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6af96bbb-e678-fba3-55a7-58d8ed2be584.png)

「**Create Account**」をクリックします。
![01_stackdriver06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/35913e32-f846-7e44-a010-3bf1c9f1b76b.png)

このまま「**Continue**」をクリックします。
![01_stackdriver07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b883a243-5720-8a36-25dc-91b5d42bd679.png)
![01_stackdriver08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/30e600ea-7ae9-6537-c393-c2ff15c3523e.png)

「**Log in to your Amazon IAM console and click Roles**」をクリックしてAWSコンソールを開きます。
その際に「**ACCOUNT ID**」と「**EXTERNAL ID**」をチェックしておきます。
![01_stackdriver09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/837a09c9-144b-a358-0366-71a21a07da8d.png)

ここで一旦、Stackdriverの設定は中断してAWS側の設定を行います。


<br>
# AWSロールの作成
ここではStackdriverがAWSリソース状況を取得できるようにするためのロールを作成します。

「**新しいロールの作成**」をクリックします。
![02_aws01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/288d7ba1-0611-f59b-1b69-6219ffc28096.png)

ロール名を「**Stackdriver**」を入力して「**次のステップ**」をクリックします。
![02_aws02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2df9eabe-14cd-a0c4-c8d0-c9b9df26da48.png)

「**クロスアカウントアクセスのロール**」をチェックして「**サードパーティのAWSアカウントユーザーに、アカウントへのアクセスを許可します。**」を選択します。
![02_aws03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/266fb0c3-a65d-67e1-390c-531eb12e6810.png)

先ほどStackdriverのコンソール画面に表示されていた「**アカウントID**」と「**外部ID**」を入力して「**次のステップ**」をクリックします。
![02_aws04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/882b0dc6-f3d4-90bb-7239-8a5eec8d3f24.png)

ポリシーのアタッチで「**ReadOnlyAccess**」を選択して「**次のステッップ**」をクリックします。
![02_aws05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/99326e70-66b5-6686-223a-733b8d4ef099.png)

内容を確認して問題無ければ「**ロールの作成**」をクリックします。
![02_aws06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/12937eb3-b9b8-f8fa-78b4-6363e9a6893f.png)

ここで「**ロール ARN**」をメモしておいてください。後ほど使います。
以上でAWS側の設定は完了です。Stackdriverの設定に戻ります。


<br>
# モニタリングの設定
先ほどメモした**ロール ARN**を「**Role ARN**」を入力し、「**Description of account**」にアカウントについての説明を入力したら「**Add AWS account**」をクリックします。
![03_stackdriver01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/49da7a5e-97ab-0c2c-84c8-6a144c130ebb.png)


追加が確認されたら「**Done**」をクリックします。
![03_stackdriver03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d32cc17d-9b5f-8fa4-dc99-c4be84f36ac4.png)


「**Launch monitoring**」をクリックするとモニタリングが開始されます。
![03_stackdriver04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/21f7c854-0b8f-e7e1-d790-df9c471edc89.png)

最後に、レポートについて「日次」、「週次」、「受け取らない」のいずれかを選択して「**Continue**」をクリックしたら完了です。
![03_stackdriver05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bbd85940-0f32-ac16-28c3-4259ccfe3cab.png)

AWSの情報を取得するまで結構かかります。気長に待ちましょう。


<br>
# 確認
情報の取得が完了すると「**Resources**」のところにAWSで見たことある文字がずらっと表示されます。
![04_stackdriver01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/18d4487d-cc4a-a036-f602-13b85f56d5a2.png)

以上で無事取得が完了しました。

参考として**Instance**と**Block Storage Volume**の様子を載せておきます。

**■ Instances**
![04_stackdriver02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c3216d1e-bc97-1329-d746-06e9b8d5332e.png)

![04_stackdriver05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/46c0b78a-99c4-52c4-f101-51ac0874c058.png)

**■ Block Storage Volumes**
![04_stackdriver03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/60cbd731-cc21-b51c-6a02-210da40afa65.png)

![04_stackdriver04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d4e9a87c-00ed-120f-aab3-8407f1f1caa7.png)

あと、レポートはこんな感じに届きます。
![05_report01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/33363fd7-a6a7-de84-d107-104ac5dc6629.png)
簡単なサマリーが表示され、「Group」のリンクをクリックするとモニター画面が開くようになっています。


<br>
# おわりに
AWSの初期情報を取得するのに時間はかかりますが、思った以上に導入は簡単でした。何よりもAWS側のロールは「ReadOnlyAccess」だけで良いので安心です。

ただ、IAMロール作成時にちゃんと「ロールの作成」をクリックしてから作成が完了していない状態でStackdriverの設定に戻ってしまうとAWSリソース情報が取得できないのでクリックのし忘れに注意してください。「当たり前でしょ！」と言うと思いますが、何気に忘れてしまいそうなポイントかなと感じました。。。はい。忘れました。。。

それと、他にもエージェントを入れるとプロセスのモニタリングもできるみたいなので、そこについても試してみようと思います。

