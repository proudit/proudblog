---
title: moCloudでHubotを動かそう！！
date: 2016-01-25
tags: moCloud, Hubot, Slack
author: kohei
---

先日、「Mobingi moCloud ハンズオン」に行ってきました。
https://mobingi.doorkeeper.jp/events/37092

内容としては「moCloudの説明から実際にアプリケーションを作成する」を前半で行い、後半では「作成したアプリケーションを利用してサービスをデプロイする」を行いました。moCloudというのをまったく知らずに参加したこのハンズオンでしたが、とてもわかりやすかったです。

そこでMobingiの吉田真吾さんが「moCloudを使ってHubotを動かす」という内容のハンズオンをしてくださったのでその内容(手順)をまとめてみました。


# 概要
moCloud上のアプリケーションにHubotを動かすスクリプトをデプロイし、Slackと連携させてHubotと会話をする。
※Hubotを動かすスクリプトはあらかじめ用意されています。

# 0.事前準備
・[GitHubアカウントの作成](http://qiita.com/kooohei/items/361da3c9dbb6e0c7946b)
・Slackのインストールとアカウント作成


# 1. リポジトリのfork(GitHub)
#### 1-1.ログイン
GitHubにログインします。
https://github.com

#### 1-2.リポジトリのfork
以下のリポジトリへアクセスし、forkします。
https://github.com/yoshidashingo/hubot-mocloud

![20160124_github01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/88696f9e-d46a-c9a0-2091-0f7965637488.png)

複数の組織に所属している場合は以下のように聞かれるので、forkするリポジトリを指定します。
![20160124_github02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/dac20449-57ca-cbd3-0cd7-543a50096ef0.png)

forkすると自分のリポジトリのリストに表示されます。
![20160124_github03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6fc1b47e-3d2a-2b86-527d-3d62c0fddc7e.png)

![20160124_github04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/65f412e5-cb6d-33e0-31e9-405ee923d8ef.png)


# 2.Hubotのインストール(Slack)
#### 2-1.ログイン
ブラウザからSlackにログインし、Hubotページにアクセスします。
https://slack.com/apps/A0F7XDU93-hubot

#### 2-2.Hubotのインストール
「Install」をクリックします。
![20160123_slack-hubot01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c99fc360-55f8-d21d-b1f3-0886ec171cb4.png)

#### 2-3.Usernameの設定
「Username」を入力して「Add Hubot Integration」をクリックします。
ここで入力した「Username」がHubotの名前となりSlack上で表示されます。
![20160123_slack-hubot02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1dace3c2-1129-9706-f2d6-0ff224293f49.png)

#### 2-4.環境変数の確認
環境変数が表示されていることを確認して完了です。
![20160123_slack-hubot03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a161860e-f033-844e-7270-0f3916df403a.png)
※この環境変数は後で利用します。


# 3.アプリケーションの作成(moCloud)
#### 3-1.ログイン
moCloudにログインします。
https://mocloud.io/

#### 3-2.アプリケーションの作成
左サイドにある「+ アプリケーションの作成」をクリックします。
![20160122_mobingi01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/989d2273-b9b0-5711-2722-4fe44668be07.png)

#### 3-3.アプリケーション情報の設定
任意のアプリケーション名とドメインを入力し、利用するリージョンとインスタンスを選択します。
![20160122_mobingi02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/72b79a30-d65b-a284-fcae-89f15eec38eb.png)

#### 3-4.イメージ設定①
作成するアプリケーションのイメージを選択します。
今回は「PHP Stack Ubuntu 14.04, php 5.6, Apache」を選択します。
![20160122_mobingi03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ae30c714-2084-7696-c45c-8482569aacc3.png)

#### 3-5.イメージ設定②
「4.イメージの設定①」で選択したイメージをクリックすると「Extra PHP Configuration」の設定画面がポップアップされます。
今回はデフォルト設定のままで「実行」をクリックします。
![20160122_mobingi04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7b7417d7-b002-d8c5-6450-0996ccaee629.png)

すると、選択したイメージがブルーの色になります。
![20160122_mobingi05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a85fb6b8-7012-2d79-42dc-f4f8f0a3484e.png)

####3-6.アプリケーションの作成
以上の設定を行ったら「アプリケーションの作成」をクリックします。
![20160122_mobingi06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/373a026e-93df-1fbc-4011-b7f64dc5cabe.png)

すると、「既存アプリケーション」に画面が切り替わり、アプリケーションの作成が始まります。
![20160122_mobingi07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/21903528-14c1-516d-77e8-6dcb95af02df.png)

ステータスが「初期化中」→「実行中」になったら作成完了です。
※ちなみに自分は実行中になるまで7分ほどかかりました。
![20160122_mobingi09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/491fa8c6-5a5f-2336-2027-13a6ac67754f.png)


# 4.コードのデプロイ
#### 4-1.アプリケーションの選択
作成したアプリケーション名をクリックします。
![20160122_mobingi10.png](https://qiita-image-store.s3.amazonaws.com/0/82090/07d72860-26f3-4ee4-15d2-4b812e59b285.png)

#### 4-2.リポジトリの選択
「コード」タブをクリックするとGitリポジトリ設定が表示されるので、そこで「GitHub」の「パブリックリポジトリ」を選択します。
![20160122_mobingi11.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e76dfb22-99ce-eeec-00ee-c666dfe117da.png)

#### 4-3.リポジトリとの接続
フォークした「自分のリポジトリ/hubot-mocloud」の「master」リポジトリを選択し、「接続」をクリックします。

「成功」と出れば接続が完了です。
![20160122_mobingi12.png](https://qiita-image-store.s3.amazonaws.com/0/82090/864c944e-125f-13a7-b70c-fdfe7aa0ce64.png)

####4-4.環境変数の設定①
「設定」タブをクリックします。
![20160122_mobingi13.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3ad10dcb-4d6f-667b-22d0-2bf33d9a923b.png)

#### 4-5.環境変数の設定②
「Browse Apps > Hubot > Configurations on Proudit Inc > Edit configuration」に記載されている環境変数を入力して「+」で追加します。
![20160123_slack-hubot03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8debffbc-a0d8-62c0-d374-190b7e349af6.png)

![20160122_mobingi14.png](https://qiita-image-store.s3.amazonaws.com/0/82090/debfd4f9-b845-0c4a-926f-cf0bfa24ad7a.png)

#### 4-6.環境変数の設定③
変数が追加されたのを確認したら「変更を保存」をクリックして保存します。
![20160122_mobingi15.png](https://qiita-image-store.s3.amazonaws.com/0/82090/41cb683a-aefe-c78d-40f3-02be06d84b86.png)

緑でSuccessが表示されれば設定完了です。
![20160122_mobingi16.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6fa27ffa-91c1-bbdc-08cc-5f957b530fd3.png)

しばらく待つとslackに表示されているhubotのランプが緑になります。
![20160122_mobingi17.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d3d7a7a0-4799-4020-3f3d-d9b7d1532f28.png)


# 5.Let's Hubot!!
以上で準備が整いました。それでは話しかけてみましょう。
「hello」と話しかけると「hello!」を返事をしてくれます。
![20160122_mobingi18.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6f7d0594-7f9d-5011-8851-55b9b281463f.png)

ここではあらかじめ準備してくださったリポジトリをforkしてデプロイしています。
もし他にもいろいろ試したいということであれば、今回forkしたソースを編集してみてください。「hello」以外にも会話ができるようになります。


# 最後に
今回はハンズオンの第一回だったみたいです。今回のハンズオンを通じてmoCloudというのを知り、とても興味深いサービスだと感じました。なので今後もハンズオンとかがあったら参加しようと思います。

/> Mobingi 吉田真吾さん
わかりやすいハンズオンありがとうございました。

また、より詳しく知りたい方は吉田さんが書いたブログ「[moCloudでHubotを動かしてSlack上で遊ぼう](http://yoshidashingo.hatenablog.com/entry/2015/12/15/105841)」の記事を参照してみてください。

