---
title: AWS SDK for JavaScript (Node.js) で期限付きURLの発行
date: 2016-09-27
tags: AWS, JavaScript, Node.js, aws-sdk
author: kohei
ogp:
  og: 'AWS SDK for Ruby バージョン 2 で期限付きURLの発行の内容のJavaScriptバージョンです。'
---

# はじめに
[**AWS SDK for Ruby バージョン 2 で期限付きURLの発行**](http://blog.proudit.jp/2016/08/31/issu-of-time-limited-url-in-the-aws-sdk-for-ruby-version-2.html)の内容のJavaScriptバージョンです。
なので対象の準備とかは省略します。

<br>
# スクリプト
**bucketname**、**objectname**、**uploadfile**と**アクセスキーID**と**シークレットアクセスキー**は適宜変更してください。
バケットのリージョンをTokyoにしなかった場合も適切なリージョンに変更する必要があります。

```js:presigned_url.js
var AWS = require('aws-sdk');

var bucketname = "kohei-no-bucket";    // バケット名
var objectname = "ceresso.png";        // オブジェクト名

AWS.config.update({
    "accessKeyId": "********************",                          // アクセスキーID
    "secretAccessKey":"****************************************",   // シークレットアクセスキー
    "region": "ap-northeast-1"                                      // Tokyoリージョン
});

var s3 = new AWS.S3();
var params = {Bucket: bucketname, Key: objectname, Expires: 60};  // Expires:有効期限(秒)
s3.getSignedUrl('getObject', params, function (err, url) {
    console.log(url);
});
```

aws-sdkをインストールしておくのも忘れずに。

```bash:aws-sdkインストール
$ npm install aws-sdk
```


<br>
# 実践！

```bash:URL発行
$ node presigned_url.js
https://kohei-no-bucket.s3-ap-northeast-1.amazonaws.com/ceresso.png?AWSAccessKeyId=********************&Expires=1472183082&Signature=gcmfSyy1xxWqAQnZANxNm1sWRXk%3D
```


<br>
# おわりに
ポイントは[getSignedUrl](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#getSignedUrl-property)です。Rubyでの[presigned_url](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Object.html#presigned_url-instance_method)にあたります。
ただ、Rubyの場合は「**604800秒(１週間)**」の制限がありましたがJavaScriptの場合だとドキュメントに記載がないのでそれがないみたいで、期限付きURLも問題なく発行できました。
となると今回の場合は「**AWS SDK for JavaScript**」を利用した方が良さそうですね。

