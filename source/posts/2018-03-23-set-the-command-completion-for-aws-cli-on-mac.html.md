---
title: "Mac で aws-cli を利用する際にコマンド補完ができるように設定する。"
date: 2018-03-23
tags: AWS, aws-cli
author: kohei
ogp:
  og: '普段 Mac で AWS CLI をよく利用するのですが、いちいち全部手入力は大変ですよね。。。 そんな時、コマンド補完機能を使えば、Tab キーを使って補完できるのでとても便利です'
---

# はじめに
普段 Mac で AWS CLI をよく利用するのですが、いちいち全部手入力は大変ですよね。。。 そんな時、コマンド補完機能を使えば、Tab キーを使って補完できるのでとても便利です。
この機能は AWS CLI インストールしただけでは自動的有効とはならないため、手動で設定する必要があります。

http://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-command-completion.html

<br>
# はじめに
## シェルの確認
まずは Mac で利用しているシェルを確認します。

```bash:シェル確認①
$ echo $SHELL
/bin/bash
```

```bash:シェル確認②
$ ps
  PID TTY           TIME CMD
22320 ttys000    0:00.23 -bash
```

```bash:シェル確認③
$ which aws_completer
/Users/kohei/.pyenv/shims/aws_completer
```

<br>
# 保管設定
今回は bash であったため、その場合の設定です。

```bash:保管設定
$ complete -C '/usr/local/bin/aws_completer' aws
```

<br>
# 確認
実際に補完ができているか確認します。

```bash:補完確認
$ aws s
s3                  sagemaker-runtime   servicecatalog      shield              sns                 stepfunctions       support 
s3api               sdb                 servicediscovery    sms                 sqs                 storagegateway      swf 
sagemaker           serverlessrepo      ses                 snowball            ssm                 sts
```

ちょっとレスポンスに時間かかりましたが、ちゃんと補完できました。


<br>
# おわりに
aws-cliはバージョンアップが頻繁に行われるので、気がつくと利用してるバージョンが古いことが多々あります。
バージョンアップしたときなど、補完機能を使うことでどんなawsコマンドがあるかを確認できるので便利です。

