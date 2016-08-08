---
title: LINE BOTとAWS LambdaとAPI Gatewayを使って「オウム返しBOT」を作る。
date: 2016-08-08
tags: LINE,AWS
author: kohei
ogp:
  og: 'LineのBOT APIとAWSのAPI Gateway、Lambdaを利用してLINE botを作りたいと思います。'
---

# はじめに
LineのBOT APIとAWSのAPI Gateway、Lambdaを利用してLINE botを作りたいと思います。
まず、以下がLINEのBOT APIドキュメントの図です。
![How BOT API works](https://developers.line.me/wp-content/uploads/2016/04/bot_img001.png)
出典：[LINE developers](https://developers.line.me/bot-api/overview#how_bot_works)

ここでの「YOUR SYSTEM」というところを「Lambda」と「API Gateway」を使って構築します。

また、今回必要となる[LINE BOT API Trial Account](https://business.line.me/services/products/4/introduction)の取得方法については割愛します。


<br>
<br>
# Lambda関数の作成
それではまず、AWSの管理コンソールから「Lambda」のサービスへ移動します。

<br>
## ● Create a Lambda function
次に「Create a Lambda function」をクリックします。
![amore00_create-lambda01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6e230911-b7b4-7b75-9918-f897c02b6304.png)

<br>
## ● Select blue print
ここではとりあえず何も選択せず「Next」をクリックします。
![amore00_select-blueprint01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4579cd07-c77f-1464-3698-bd14b121c5ce.png)

<br>
## ● Configure triggers
今のままだとLambdaだけの状態なのでフロントに「API Gateway」を配置します。
![amore01_configure-triggers01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a272ada3-31a3-528b-c685-ede6f538c285.png)

「API Gateway」を配置したらその設定をここで行いますが、**API name**と**Resource name**は任意の名前を設定して大丈夫です。今回は「_MyAmore_」と「_/myamore_」にしています。
そして**Method**は「_POST_」を選択し、**Deploymment stage**は「_prod_(デフォルト)」のままで、**Security**は「_Open_」にしておきます。
入力が完了したら「Next」ボタンをクリックします。
![01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6fce3683-d44f-ec25-f94a-c69a1ed08546.png)

<br>
## ● Configure function
それでは関数の設定に移ります。

<br>
###   - Configure function
**Name**と**Description**に任意の内容を入力します。また**Runtime**はここでは「_Node.js 4.3_」を選択します。
![03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ed39297b-ea8a-ccf5-735d-b95d319a180b.png)

<br>
###   - Lambda function code
ここはとりあえずこのままにしておきます。

![amore01_configure-triggers03_2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/70e17b7a-9ab9-081f-778d-fc8c02cdd15f.png)

<br>
###   - Lambda function handler and role
**Handler**に「_index.handler_」、**Role**は「_Choose an existing role_」を選び**Existing role**に「_lambda_basic_execution_」を指定します。
![amore01_configure-triggers03_3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a0f1069a-b1e1-ca68-b694-10169859d648.png)

<br>
###   - Advanced settings
今回はあまり使う予定はないので**Memory(MB)**は「_128_」にしておきます。
**Timeout**はデフォルトの「_3秒_」です。
また、**VPC**は「_No VPC_」にしておきます。
![amore01_configure-triggers03_4.png](https://qiita-image-store.s3.amazonaws.com/0/82090/271e53a9-b533-f8b5-8cd5-c56454a36c49.png)

<br>
## ● Review
「Configure function」で設定した内容の確認です。
問題なさそうなら[Create function]で作成完了です。
![02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6e6a3b03-5ca2-c358-9c2d-b2b509c8a6cd.png)
![03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ed39297b-ea8a-ccf5-735d-b95d319a180b.png)


作成が完了すると「API Gateway」のURLが表示されます。
![04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fdd1265d-0627-1699-c34a-143e77141ac9.png)

ここで表示されたURLを**LINE**の「_Callback URL_」に設定します。
その際に注意が必要なのが、ポート番号も指定してあげなければならないという点です。
以下の画像のように、ドメイン末尾に「:443」をつけてあげる必要があります。
![05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/781d37da-0d5c-d326-daa5-119de87c6a6c.png)

以上で「YOUR SYSTEM」に該当するフレームが完了しました。


<br>
# Lambda関数の設定
それでは作成したフレームの中身を設定していきます。
中身というのは先ほど「とりあえずこのまま」にしていたLambda関数の箇所です。
「Code」タブをクリックして編集画面を表示します。
![07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/35cc41e6-9633-79c0-a551-050fe8b69324.png)

そこに以下のソースコードをコピペします。

```js:myAmore
var https = require('https');

exports.handler = function(event, context) {
    console.log('EVENT:', JSON.stringify(event, null, 0));
    var msg = event.result[0];
    var data = JSON.stringify({
      to: [msg.content.from.toString()],
      toChannel: 1383378250,
      eventType: "138311608800106203",
      content: msg.content
    });
    var url ='https://trialbot-api.line.me/v1/events';
    var opts = {
        host: 'trialbot-api.line.me',
        path: '/v1/events',
        headers: {
            "Content-type": "application/json; charset=UTF-8",
            "X-Line-ChannelID": "【Channel ID】",
            "X-Line-ChannelSecret": "【Channel Secret】",
            "X-Line-Trusted-User-With-ACL": "【MID】"
        },
        method: 'POST'
    };
    var req = https.request(opts, function(res){
        res.on('data', function (chunk) {
            console.log(res.statusCode + chunk.toString());
        });
        req.on('error', function(err) {
          console.log('ERROR: ' + err.message);
        });
    });
    req.write(data);
    req.end();
};
```

ただその際に、【Channel ID】と【Channel Secret】と【MID】は独自の値を設定する必要があるので「[Line developers](https://developers.line.me/channels/)」で取得した自分の値と置き換えてください。
![06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/87c308e1-2ed4-31fd-d45f-d50d9c83ad10.png)

コピペが完了したら「Save」ボタンで保存して完了です。

え？それじゃ何をしてるのかわからないって？いいんです！まずは完成させることが大事なんです！
ひとまず何も考えずにコピペしましょう！


<br>
# トーク
それではいよいよアモーレとの会話です！LINEから何か好きな言葉をささやいてみましょう！
![08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/48bb2b15-2bb9-f322-e475-62c875efc3bb.png)

同じ言葉を返してくれます。いわゆる「オウム返し」というやつです。


<br>
# おわりに
今回は「とにかく動かす」ことを目的に作りました。
具体的な処理について説明すると長くなってしまうので、今回はここまでにしたいと思います。

