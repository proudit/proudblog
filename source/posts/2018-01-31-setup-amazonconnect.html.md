---
title: "Amazon Connect でコールセンターを作成する。"
date: 2018-01-31
tags: AWS, Amazon Connect
author: kohei
ogp:
  og: '気がついたら Amazon Connect で日本の番号が取得できるようになってたので、試しに使ってみることにしました。'
---

# はじめに
気がついたら[Amazon Connect](https://aws.amazon.com/jp/connect/)で日本の番号が取得できるようになってたので、試しに使ってみることにしました。

<br>
# Amazon Connectとは?
クラウドベースのコンタクトセンター。日本で言うコールセンターです。AWSの管理コンソール上から数ステップで自信の顧客に合わせたコンタクトセンターをセットアップすることができます。

<br>
# 料金は？無料利用枠は？
サービス利用と直接ダイヤルイン(DID)、アウトバンドコールに対して料金が発生します。
無料利用枠として1ヶ月あたり90分のサービス利用と1ヶ月あたり30分のインバウンドDIDとアウトバンドコール利用できます。
ただ、AWSサービスの利用料金などは日々変更されるため、利用前に確認することをおすすめます。
[Amazon Connect 料金について](https://aws.amazon.com/jp/connect/pricing/)

<br>
# Amazon Connect のセットアップ
まずはコールセンターを作るための土台作りです。

Amazon Connect のサービス画面へ行き、「今すぐ始める」から初期セットアップを行います。
![スクリーンショット 2018-01-20 10.01.45.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ff84e669-2de8-1d26-9431-b53aad55eb4a.png)

<br>
# Amazon Connect のリソース設定
## ステップ１：ID 管理
まずはユーザー管理についての設定です。Amazon Connect で利用するアクセスURLを設定します。
![スクリーンショット 2018-01-20 10.02.46.png](https://qiita-image-store.s3.amazonaws.com/0/82090/644ae9a2-4e51-0d0c-4aa6-116ac72b253f.png)


<br>
## ステップ２：管理者
管理者の情報を入力します。
![スクリーンショット 2018-01-20 10.03.32.png](https://qiita-image-store.s3.amazonaws.com/0/82090/91857611-5717-5e71-0da6-1e53be8546dd.png)


<br>
## ステップ３：テレフォニーオプション
通話の着信、発信についての設定を行います。今回はデフォルトです。
![スクリーンショット 2018-01-20 10.03.44.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0a6a9ccd-c520-4937-0411-05cad5d33674.png)


<br>
## ステップ４：データストレージ
通話記録などのレポート保存先の設定を行います。
![スクリーンショット 2018-01-20 10.03.56.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ef0a5f8b-a53c-c9e7-814a-f79bcaee284d.png)


<br>
## ステップ５：レビューと作成
設定内容の確認をし、問題なければ「インスタンスの作成」をクリックします。
![スクリーンショット 2018-01-20 10.04.08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bfb1c406-1f0c-3a1b-bed0-9b70fe9f060e.png)

![スクリーンショット 2018-01-20 10.04.16.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b26e6892-25f2-4251-8c11-b92de62481ff.png)

<br>
## 完了
以上で Amazon Connect のセットアップが完了しました。
「今すぐ始める」ボタンをクリックすると Amazon Connect の画面に移ります。
![スクリーンショット 2018-01-20 10.05.31.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1f851134-41b9-7292-14b5-abe35905ecdf.png)

注意点として、Amazon Connect を利用するにはブラウザはChromeかFirefoxにしないとダメみたいです。
![スクリーンショット 2018-01-20 10.05.48.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1fde8edb-bb6d-3b80-5f18-22c0482041fc.png)
Safariでアクセスしようとしたら警告が出て起動できませんでした。。。


<br>
# 1. 電話番号を取得する
通話の受信と発信のためには、電話番号を取得する必要があります。

概要画面から「管理者としてログイン」をクリックします。

![スクリーンショット 2018-01-20 11.27.21.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ccfae9d8-4ace-00b7-1e6b-f82eb3511798.png)

ダッシュボードから「1.電話番号を取得する」にある「開始」ボタンをクリックします。
![スクリーンショット 2018-01-20 11.28.17.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2ce3d1d2-4ee6-2c7e-147d-bd91ddf23251.png)

「国/地域」で日本を選択して「電話番号」で番号を選択肢たら「次へ」をクリックします。
ちなみに電話番号の指定はできませんがいくつか候補が出てくるのでその中から好きなのを選択できました。
![スクリーンショット 2018-01-21 12.10.25.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b04747b6-4485-6061-f6d4-05fa19f86e88.png)

「Continue」をクリックして電話番号の取得は完了です。
![スクリーンショット 2018-01-21 12.10.44.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b4482417-c489-7202-2590-280c890f17de.png)


<br>
# 2. オペレーション時間の設定
オペレーション時間の設定では、キューの利用可能時間帯を定義します。
いわゆる受付時間の設定です。
「新しい時間の追加」で新規にオペレーション時間を設定します。
![スクリーンショット 2018-01-21 12.15.06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c679bc0f-5d5a-78f6-8ace-3b32451de810.png)

今回は日本でのサポート設定を行うので名前はjapan-supportとしています。
タイムゾーンを「Asia/Tokyo」にし、時間を「09:00 AM - 05:00 PM」に設定して「新規追加」をクリックします。
![screencapture-kooooohei-awsapps-connect-operating-hours-manage-1517224465908.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0bc90e6e-5a86-3b08-2cc3-62c8ad1daaca.png)


<br>
# 3. キューの作成
キューの作成では、問い合わせを最適なエージェントにルーティングします。基本的には2で設定したオペレーション時間と1で取得した電話番号の紐付けです。

名前と説明を入力し、2で設定したオペレーション時間と1で取得した電話番号を選択して「新しいキューの追加」をクリックします。
![screencapture-kooooohei-awsapps-connect-queues-create-1517227855838.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fff3f543-af6e-1268-84a6-6233a0f1b48a.png)

<br>
# 4. プロンプトの作成
プロンプトの作成では、問い合わせフローでオーディオを再生する場合に使用できるメディアを登録できます。

登録するには「+プロンプトの新規作成」をクリックします。
![スクリーンショット 2018-01-30 0.50.38.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5f240230-c354-ebce-9198-5802f8b6966a.png)

すると登録画面に移るため、あらかじめ録音しておいた .wav ファイルをアップロードします。それか、レコードのタブをクリックするとマイクを使ってその場で録音することができます。

![screencapture-kooooohei-awsapps-connect-prompts-create-1517241066926.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8f3d166e-9a94-6ab0-1227-bc68c65d6d85.png)


<br>
# 5. 問い合わせフローの作成
問い合わせフローの作成が行えます。既存フローがいくつか用意されてありますが、顧客に合わせたサポートフローを作成することも可能です。また、CRMやデータベースなどの他システムと結合をしたり、Amazon Lexと結合することも可能です。

![スクリーンショット 2018-01-30 1.09.47.png](https://qiita-image-store.s3.amazonaws.com/0/82090/00c3e5a2-645f-2fce-fef9-f0612535b47f.png)

カスタマイズフローは以下のようにアクションとなるオブジェクトをつなぎ合わせることで作成できます。
ここでは取得した電話番号に電話がかかって来たら自分の携帯電話へ転送する仕組みとなっています。

![スクリーンショット 2018-01-30 1.10.36.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7375994f-7c82-8af8-31e8-71637fb69cd7.png)


<br>
# 6. ルーティングプロファイルの作成
ルーティングプロファイルは、エージェントの問い合わせへの対応元となるキューのコレクションです。 ルーティングプロファイルにより、エージェントは適切な優先度で複数のキューに対応できます。
つまり、グルーピングされたキューの中で優先順位をつけて処理する設定です。

新たに作成する場合は「新しいプロファイルを追加」をクリックします。
![スクリーンショット 2018-01-30 9.56.03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0e86b190-1db2-fc48-f96f-596f49ca3c4f.png)

名前、説明を入力したら、キューを追加して「新しいプロファイルを追加」をクリックします。
![screencapture-kooooohei-awsapps-connect-routing-profiles-create-1517273807485.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fba1e2c2-5ab8-24a8-0f8f-1971be2e4e5d.png)


<br>
# 7. ユーザーの設定
ユーザー管理により、ユーザーの追加、管理、および削除が可能になります。 ルーティングプロファイルやアクセス権限などユーザー固有の設定は、ユーザーの作成後に割り当てることができます。

初めは初期設定時に作成されたAdminのみが存在します。新たに追加する場合は「新しいユーザーの追加」をクリックします。
![スクリーンショット 2018-01-30 9.57.40.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d8f98941-6ac0-7331-11c7-e34be9d17572.png)

「作成：新しいユーザーをセットアップする。」を洗濯して「次へ」をクリックします。
「アップロード：ユーザーをテンプレートから(CSV)」でCSVにテンプレとして保存しておけばそこから作成もできるみたいです。
![スクリーンショット 2018-01-30 9.58.05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/54cd40d1-6bcb-3850-c5f2-2100cbd40389.png)

ユーザー情報を入力して「保存」します。
![screencapture-kooooohei-awsapps-connect-users-1517274167160.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c6233bc9-6129-37ba-7ad3-74c20f13c9b9.png)

内容に問題なければ「ユーザーの作成」をクリックして完了です。
![スクリーンショット 2018-01-30 10.02.57.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c439ef7e-e5ad-2391-c158-d942f96bddd5.png)

さらにユーザーを追加したい場合は「他のユーザーの作成」を、完了する場合は「戻る」をクリックすればOKです。
![スクリーンショット 2018-01-30 10.03.15.png](https://qiita-image-store.s3.amazonaws.com/0/82090/93acee42-a62f-0fb3-b7f6-4b32182315a4.png)


<br>
# おわりに
今回、AmazonConnectを触ってみて「こんなに簡単にコールセンター作れるの！？」と驚きました。本当に数ステップで設定できます。
ここでは詳細な設定方法の記載はしてませんが問い合わせフローでの画像は電話転送設定です。
リージョンが海外だからか、試した感想としては転送までに数秒のタイムラグがありました。それでもとても数秒なのでフロントで受ける電話番号が固定できるという意味ではとても便利だと思います。


