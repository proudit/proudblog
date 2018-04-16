---
title: "Launch Templates を利用してインスタンスの起動を行う。"
date: 2018-04-16
tags: AWS, EC2
author: kohei
ogp:
  og: 're:Invent2017でLaunch Templatesというのが発表されました'
---

# はじめに
[**re:Invent2017**](https://aws.amazon.com/jp/about-aws/events/reinvent2017-1129/) で [_Launch Templates_](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-launch-templates.html) というのが発表されました。
[**Launch Templates for Amazon EC2 instances の紹介**](https://aws.amazon.com/jp/about-aws/whats-new/2017/11/introducing-launch-templates-for-amazon-ec2-instances/?sc_channel=sm&sc_campaign=AWS_reInvent&sc_publisher=TWITTER&sc_country=Global&sc_geo=GLOBAL&sc_outcome=awareness&trk=_TWITTER&sc_content=EC2_2d38f9b2_Launch_Templates&sc_category=Launch_Templates&linkId=45321944)
これでEC2インスタンスの起動が簡単になりそうなので試してみました。


<br>
# テンプレートの新規作成
まずはAWSコンソールからEC2サービスへ移動し、**「インスタンス > Launch Templates」** から
 **[Create launch template]** をクリックします。

![LaunchTemplates01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/46cbd519-1f5e-6e0d-ae5c-07d520b96726.png)

するとテンプレート作成画面へ移動します。
今回は新規作成なので、**「What would you like to do?」** で **「Create a new template」** を選択し、**「Launch template name」** にテンプレート名を入力したら以下は必要に応じて設定して行きます。
今回は画像の赤ラインが入ってるところを指定しています。

![LaunchTemplates02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8de6ec1c-b41d-e25b-a7cb-bfe3ce1d81f4.png)

設定したら **「Create launch template」** をクリックして作成完了です。


<br>
# テンプレートからインスタンス作成
**「インスタンス > Launch Templates」** から先ほど作成したテンプレートにチェックを入れ、**[アクション]** をクリックして表示される **「Launch instance from template」** をクリックします。
すると **「Source launch template」** には先ほど指定したテンプレートIDが設定され、テンプレートを作成した際に指定したパラメータが入力されています。

![LaunchTemplates03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f8890fbf-8214-4631-40ea-8c1e7720f907.png)

ただ、ここで注意なのが **「Subnet」** です。テンプレートでは **「Network type」** は **VPC** か **Classic** のどちらかを指定します。基本的にはVPCを指定する人がほとんどだと思いますが、その際にどのVPCかの指定ができません。なので、テンプレートから作成するときに作成したいVPC環境を指定するのですが、VPCIDを指定するのではなく、直接どのサブネットで起動させたいかをサブネットIDで指定します。
また、指定したサブネットがPublic向けである場合、サブネットのポリシーで **自動割り当てパブリック IP** が **「はい」** になっていないとパブリックIPが付与されないので注意です。(テンプレートのNetwork Interfacesで意図的に設定していない場合)

![LaunchTemplates04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3a0b6244-74f8-0533-904c-a6264fb37c01.png)

問題なければ **「Launch instance from template」** をクリックして完了です。


<br>
# テンプレートのバージョニング
Launch Template はバージョン管理ができます。そのため、もしテンプレートを更新した後でもバージョンを指定することで以前に設定していたパラメータを利用してインスタンスを起動させることができます。

<br>
## テンプレートの更新
新規作成したのと同様に、**「インスタンス > Launch Templates」** から
 **[Create launch template]**をクリックします。

今回は、**「What would you like to do?」** で **「Create a new template version」** を選択します。

次に **「Launch template name」** で先ほど作成したテンプレート名を指定します。
また、**「Source template」** ではベースとするテンプレートIDを指定し、またベースとするバージョンを指定します。

![LaunchTemplates05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4b75ebb4-47ad-77ad-2b25-d9ee4d220cb6.png)

あとは **「Create launch template」** をクリックして作成完了です。
**Versions**タブを見ると**Version** に **「2」** ができているのが確認できます。

![LaunchTemplates07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fe993d3e-1d6f-bfe9-5ca3-e76bd0c3debf.png)


<br>
## デフォルトバージョンの変更
デフォルトバージョンを変更することで、バージョンが指定されなかった場合のベースとなるテンプレートを設定することができます。

![LaunchTemplates08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ba05f0f6-28e8-54c8-dc42-2313adc9603b.png)

**「インスタンス > Launch Templates」**から先ほど作成したテンプレートにチェックを入れ、**[アクション]**をクリックして表示される**「Set default version」**をクリックします。

![LaunchTemplates09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/afe7ef72-6139-1c33-88e4-15b84ab0f672.png)

**Default version** が **Version2** に変更されました。

![LaunchTemplates10.png](https://qiita-image-store.s3.amazonaws.com/0/82090/335c4cea-cbab-eca8-87d2-5f891083db35.png)

<br>
## デフォルトバージョンとは？
さきほどデフォルトバージョンの変更を行いました。ですがこれってどこで使うものなのでしょうか？
インスタンスを起動する際に **「テンプレートからインスタンスを起動する」** を行った際にデフォルトで設定したバージョンが設定されているのかと思ったのですが、そうではないみたいです。

> - テンプレートからインスタンスを起動する
![スクリーンショット 2018-03-21 22.38.26.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9f6371c4-f71f-8911-b5ae-f52ffae24cad.png)

それではどんな時に活用されるのでしょう？
どうやら、**Create Spot fleet**、 **Auto Scaling group** を利用する場合、起動後にデフォルトバージョンがプリセットされているようです。

![スクリーンショット 2018-03-23 23.16.54.png](https://qiita-image-store.s3.amazonaws.com/0/82090/27439c33-3433-a51d-e44d-0b775267892e.png)

> - Create Spot fleet
![スクリーンショット 2018-03-23 23.15.57.png](https://qiita-image-store.s3.amazonaws.com/0/82090/56095738-342e-b5e1-4cbf-cde56d0b22b1.png)

> - Auto Scaling group
![スクリーンショット 2018-03-23 23.16.31.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f79db7e0-639d-996e-74ec-d2feb0b3209b.png)


<br>
# 高度な詳細 (Advanced Details)
テンプレートを作成する際に、シャットダウン動作やプレイスメントグループといった細かな設定を行うことができます。
今回は詳細については省略します。


<br>
# おわりに
_Launch Template_ でサーバー用途ごとにテンプレートを用意しておくとインスタンス起動がすぐ行えるのでとても便利だなと感じました。ただ、_Subnet_を毎回指定しないといけないのがちょっと。。。デフォルトバージョンも通常の起動では利用できなかったりするので、今後の改善に期待ですね。

