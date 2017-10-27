---
title: "CloudWatchアラームでSlackへ通知を行う。"
date: 2017-10-27
tags: AWS, lambda, CloudWatch, python, Slack
author: kohei
ogp:
  og: 'CloudWatchアラームでモニタリングして、アラームが発生したらslackへ通知させる設定をしたいと思います。'
---

# はじめに
CloudWatchアラームでモニタリングして、アラームが発生したらslackへ通知させる設定をしたいと思います。
最初はCloudWatchからLambdaを直接実行できるのかなと思ったのですが、直接実行できるのはイベントだけみたいです。アラームから直接Lambdaを実行することはできませんでした。なので、SNS経由で実行する必要があります。
イメージとしては以下のような構成になります。

![slack-notification.png](https://qiita-image-store.s3.amazonaws.com/0/82090/91f4a9ab-f360-982b-f606-133a326991c6.png)


<br>
# slack への通知設定
図の右側(エンド側)から順番に設定していく必要があります。なのでまずはslackの設定を行います。

<br>
## ・channel の用意
今回は _#lambda2slack_ という名前でchannelを用意します。
とりあえず、 slack への通知は **Incoming Webhook** という機能が [slack API](https://api.slack.com/) から提供されているのでそれを使って行います。

Incoming Webhook の設定に関しては前にQiitaに書いたのでそちらを参考にしてください。
参考：[slackのIncoming Webhookを試してみた。](https://qiita.com/kooohei/items/2d91b99a4a8125556df9)


<br>
# プログラムの作成
Incoming webhook を使うのに、 python のライブラリで [slackweb](https://github.com/satoshi03/slack-python-webhook) というのがあるみたいです。今回はこれを使って行うことにしました。

とりあえずインストール。

```bash:インストール
$ pip install slackweb
```

インストールできたらコマンドで試してみます。

```py3:通知テスト
$ python
Python 3.6.2 (default, Sep 28 2017, 02:02:02) 
[GCC 4.2.1 Compatible Apple LLVM 9.0.0 (clang-900.0.37)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import slackweb
>>> slack = slackweb.Slack(url="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX")
>>> slack.notify(text="hello, kohei!!")
'ok'
```

**slack.notify** で引数に渡した値(ここでは"*hello, kohei!!*")が先ほど作成したslackのchannelへ通知されたらOKです。

![スクリーンショット 2017-10-19 21.01.37.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2e5f78b9-f3fe-c0e8-9bf0-f0789239e88c.png)

とりあえず、今回はCloudWatch からslackへ通知を行うことを目的としているので、これ以上のプログラミングは行わずに次へ進みます。


<br>
# プログラムの関数化
Lambdaで実行できるようにするには、プログラムを関数として扱えるようにする必要があります。
先ほどコマンドで実行した内容を以下のように関数化して保存します。

```bash:関数の作成
$ vim lambda2slack.py
---
import slackweb

def lambda_handler(ecent, context):
	slack = slackweb.Slack(url="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX")
	slack.notify(text="hello, kohei!!")
```

関数として利用できるか確認をしてみます。

```py3:通知テスト
$ python
>>> from lambda2slack import lambda_handler
>>> lambda_handler(None, None)
```

先ほどと同じようにslackへ通知が届いたらOKです。


<br>
# Lambdaの設定
slackへ通知ができるところまで確認ができたので、Lambdaの設定を行います。

<br>
## ・zip圧縮
今回の場合、slackwebはデフォルトで利用できるライブラリではありません。そのためコードだけアップしてもエラーとなってしまいます。そういう場合はライブラリも一緒にzipファイルとして圧縮してアップロードしてあげることで解決です。
まずは、アップロード用のディレクトリを作成し、そこへ必要なライブラリとプログラムを入れます。

```bash:upload用ディレクトリ作成
$ mkdir upload
$ cd upload
```

今回必要となるslackwebのライブラリをアップロード用ディレクトリへダウンロードします。

```bash:slackwebの格納
$ pip install slackweb -t .
Collecting slackweb
  Using cached slackweb-1.0.5.tar.gz
Installing collected packages: slackweb
  Running setup.py install for slackweb ... done
Successfully installed slackweb-1.0.5
```

先ほど作成した関数化したプログラムファイルも入れます。

```bash:プログラムの格納
$ cp ../lambda2slack.py ./
```

配置が完了したら以下みたいになってるはずです。

```bash:確認
$ ls
lambda2slack.py			slackweb			slackweb-1.0.5-py3.6.egg-info
```

揃ったらzip圧縮します。

```bash:zip圧縮
$ zip -r upload.zip *
  adding: lambda2slack.py (deflated 42%)
  adding: slackweb/ (stored 0%)
  adding: slackweb/__init__.py (deflated 4%)
  adding: slackweb/__pycache__/ (stored 0%)
  adding: slackweb/__pycache__/__init__.cpython-36.pyc (deflated 15%)
  adding: slackweb/__pycache__/slackweb.cpython-36.pyc (deflated 41%)
  adding: slackweb/slackweb.py (deflated 60%)
  adding: slackweb-1.0.5-py3.6.egg-info/ (stored 0%)
  adding: slackweb-1.0.5-py3.6.egg-info/dependency_links.txt (stored 0%)
  adding: slackweb-1.0.5-py3.6.egg-info/installed-files.txt (deflated 43%)
  adding: slackweb-1.0.5-py3.6.egg-info/PKG-INFO (deflated 48%)
  adding: slackweb-1.0.5-py3.6.egg-info/SOURCES.txt (deflated 46%)
  adding: slackweb-1.0.5-py3.6.egg-info/top_level.txt (stored 0%)
```

upload.zipというのが出来上がっているので、あとはこれをLambdaへアップロードすればOKです。

```bash:zip確認
$ ls
lambda2slack.py			slackweb-1.0.5-py3.6.egg-info
slackweb			upload.zip
```

<br>
## ・Lambdaへアップロード
AWS管理画面から、Lmabdaのサービス画面へ行き、**「関数の作成」**をクリックします。
![スクリーンショット 2017-10-21 14.19.47.png](https://qiita-image-store.s3.amazonaws.com/0/82090/30753f51-6f98-9126-0e8e-2f887401294e.png)

今回はテンプレなどは使わないので**「一から作成」**をクリックします。
![スクリーンショット 2017-10-26 12.51.21.png](https://qiita-image-store.s3.amazonaws.com/0/82090/66eae14f-fb7b-c958-9846-c2c58471e0ea.png)

**名前**を入力し、**ロール**で**「カスタムロールの作成」**を選択します。
<img width="500" alt="スクリーンショット 2017-10-26 12.53.46.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/43ff0487-8738-2b12-471f-8c6a566eaf34.png">

するとIAMポリシー作成画面へ移動するのでそこでポリシーを作成します。
今回の場合はデフォルト(ログ出力権限)で十分です。
<img width="500" alt="スクリーンショット 2017-10-26 12.53.21.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/1fc95dfd-7e3e-4877-e53c-3c85e9e70d70.png">

**「既存のロール」**のところが先ほど作成したロールになっているのを確認して**「関数の作成」**を行います。
<img width="500" alt="スクリーンショット 2017-10-26 12.53.57.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/acc47c31-b402-64f9-c5d3-fb2942ab3535.png">

**「関数コード」**の**ランタイム**を**「python 3.6」**、**コードエントリ タイプ**を**「.zipファイルをアップロード」**、**ハンドラ**を**「lambda2slack.lambda_handler」**にして先ほどzipにしたファイルをアップロードします。
アップロードができたら**「保存してテスト」**をクリックします。
<img width="500" alt="スクリーンショット 2017-10-26 12.56.26.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/91fd2f2b-49e2-32d4-ac2c-1deeee036512.png">

**「実行結果：成功」**となればOKです。
<img width="500" alt="スクリーンショット 2017-10-26 12.57.04.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/b1e93730-ba7d-c3cf-0dff-3fcb36574fa1.png">

ちなみにこの時点でslackへも通知が届いているはずです。


<br>
# SNSで通知設定
次はCloudWatchからlambdaを実行できるようにするために、SNSトピックを作成し、そこへ作成したLambdaを登録します。
AWS管理画面から、SNSのサービス画面へ行きます。

**「Create Topic」**をクリックします。
![スクリーンショット 2017-10-26 14.04.08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b32bbe6c-8789-3d48-3168-47ac67acdc8a.png)

**Topic name**を入力したら**「Create topic」**でトピックを作成します。
![スクリーンショット 2017-10-26 14.06.41.png](https://qiita-image-store.s3.amazonaws.com/0/82090/47ca88b7-820d-9dfd-8cac-71e53c003776.png)

トピックが作成できたら**「Create subscription」**をクリックします。
![スクリーンショット 2017-10-26 14.14.30.png](https://qiita-image-store.s3.amazonaws.com/0/82090/cce77cf7-e262-3733-5f6d-3bc4d59aa2cd.png)

**Protocol**を**「AWS Lambda」**、**Endpoint**を先ほど作成したLambda関数(_lambda2slack_)を指定して**「Create subscription」**で作成します。
![スクリーンショット 2017-10-26 14.14.58.png](https://qiita-image-store.s3.amazonaws.com/0/82090/23dd86d7-56ea-a5d1-c580-da9c2f61c171.png)

以上でSNSの設定は完了です。


<br>
# CloudWatchからの呼び出し
AWS管理画面から、CloudWatchのサービス画面へ行き、**アラーム**から**「アラームの作成」**を行います。
**メトリクスの選択**でアラームでチェックしたいメトリクスを指定します。
![スクリーンショット 2017-10-26 15.43.19.png](https://qiita-image-store.s3.amazonaws.com/0/82090/75ebf0cb-1309-e88c-c5e9-7971750052fb.png)

![スクリーンショット 2017-10-26 15.44.19.png](https://qiita-image-store.s3.amazonaws.com/0/82090/55af9a24-9b34-b885-36d5-da110a950eeb.png)

今回は通知を確認したかったのでLambdaの呼び出し(Invocations)を指定し閾値を_≧1_にしました。

**アラームの定義**で閾値を設定したら**アクション**で**通知の送信先**を先ほど作成したSNSトピックの**_lambda2slack_**を指定してから**「アラームの作成」**をクリックして作成します。
![スクリーンショット 2017-10-26 15.41.02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/730ef7e1-7bdd-d5ce-5b50-edf3ca9183b7.png)

これでCloudWatchの設定も完了し、一連の設定が完了しました。
おそらく先ほどLambdaを登録した際にテストで実行しているので、設定がうまくできているとslackへ通知が届くとお思います。


<br>
# おわりに
以上が「CloudWatchアラームで検知」→「slackへ通知」を行うための設定です。
本来ならURLなどは変数にして「KMSで暗号化」とかするのが良いみたいですが、まずは最低限のサービスでシンプルに構築してみたほうが仕組みがわかって良いかなと思いました。
ここから徐々に他のサービスを利用したり、プログラムを書いたりして行けたらいいかなと思います。

