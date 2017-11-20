---
title: "Slack通知の表示情報をカスタマイズする。"
date: 2017-11-20
tags: Slack
author: kohei
ogp:
  og: 'この前、「CloudWatchアラームでSlackへ通知を行う。」を行いました。その際はとりあえず通知されることを目的としていたので、デフォルトの Display icon が表示されるようになってました。でも、これだとちょっと味気ない気もするので、表示されるiconをカスタマイズしたいと思います。'
---

# はじめに
この前、「[CloudWatchアラームでSlackへ通知を行う。](https://qiita.com/kooohei/items/848eeb4cbb19c83b0b6d)」を行いました。

その際はとりあえず通知されることを目的としていたので、デフォルトの Display icon が表示されるようになってました。
![](https://camo.qiitausercontent.com/97f1de1e103134f4fb4f00b59cb8d906570f07af/68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f38323039302f32653566373862392d663366652d633065382d396266302d6630373839323339653838632e706e67)

でも、これだとちょっと味気ない気もするので、表示されるiconをカスタマイズしたいと思います。


<br>
# 設定
[slack API](https://api.slack.com) サイトの **Your Apps** をクリックします。

次に、作成した **App Name** がリストされるのでそれを選択します。

すると、 **Basic Information** の設定画面になるので、下の方にある **Display Information** を好きな内容に変更します。

![スクリーンショット 2017-10-31 11.04.01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/698315df-7fa8-bc61-1baf-a1e73449cc7b.png)

今回は以下のように変更しました。

![スクリーンショット 2017-10-31 11.26.52.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2b124b32-9dae-ea92-3ab7-968830e5919e.png)

変更したら右下の 「**Save Changes**」 で保存して完了です。


<br>
# 確認
保存したら内容はすぐに反映されます。

![スクリーンショット 2017-10-31 11.26.02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f94c2ad5-d7dc-b7fb-3fe6-c9bce0a0b2fb.png)

![スクリーンショット 2017-10-31 11.26.14.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bbe3a6b9-7d36-25e0-d8d3-ab8cf5746261.png)


<br>
# おわりに
Slack通知の設定ができたら、とりあえずアイコンの変更はしといた方がわかりやすいのでおすすめです。

