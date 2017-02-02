---
title: 今さらだけどS3のライフサイクルを試してみた。
date: 2017-02-03
tags: AWS, S3
author: kohei
ogp:
  og: '前回、「今さらだけどS3のバージョニングを試してみた。」でS3のバージョニング機能を試してみました。'
---

# はじめに
前回、「[今さらだけどS3のバージョニングを試してみた。](https://blog.proudit.jp/2017/01/25/how-to-use-s3-versioning.html)」でS3のバージョニング機能を試してみました。
ですがこのままだとずーっと古いバージョンのオブジェクトが残り続けてしまいます。。。
ということで次はS3のライフサイクル管理を設定してみることにします。

<br>
# 設定
バケットの [プロパティ] で表示される**「ライフサイクル」**を開き**「+ルールを追加する」**をクリックします。
![s3-lifecycle-delete01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/79a5c81b-53de-73d6-b9a0-947d8a1ebdf1.png)

<br>
##### **ステップ１：ルールターゲットの選択**
**ライフサイクルルール**の設定にステップになるので**「次のルールを適用」**の**「バケット全体」**にチェックし**「ルールの設定>」**をクリックします。
![s3-lifecycle-delete02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/40d2edae-ccae-7ece-dbe9-2d97671ba9b0.png)

<br>
##### **ステップ２：ルールの設定**
今回は**「以前のバージョンの操作」**の完全にチェックし、日数を**「1日」**にして**「確認」**をクリックします。
![s3-lifecycle-delete03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e78c2e86-1765-878d-d5dc-ead8c4b9612c.png)

<br>
##### **ステップ３：確認と名前**
**「ルール名」**を入力し**「ルールの作成と有効化」**をクリックして完了です。
![s3-lifecycle-delete04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6646671e-eeef-3cb3-1d8a-c63bff34dabc.png)

するとライフサイクルに作成したルールがリストされているのが確認できます。
![s3-lifecycle-delete05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/afcfb233-87bc-702e-f965-edb3dabd9f12.png)


<br>
# 実行結果
とりあえず分かりやすいように何度か同じファイルをアップロードして複数バージョン用意しました。
今回の設定の場合、1日後には削除されているはずです。
![lifecycle20170130001029.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e7ff9d6e-ad38-1888-0f1a-3002b5f78c19.png)

翌日。。。
![lifecycle20170131133141.png](https://qiita-image-store.s3.amazonaws.com/0/82090/12d9c1be-113f-051a-5997-37aef1db1371.png)

最新のもの以外はすっかり削除されているのが確認できました。


<br>
# おわりに
バージョニング機能だけだと古いオブジェクトが残り続けるという課題がありましたが、ライフサイクル機能も一緒に設定してあげることで古いバージョンをいちいち手動で削除する必要がなくなりました。
これで**「誤削除防止」**と**「古いバージョンの消し忘れ」**への対応が完了です。

