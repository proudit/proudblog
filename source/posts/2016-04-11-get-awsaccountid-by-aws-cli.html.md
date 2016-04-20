---
title: AWS CLIでAWS Account IDを取得する。
date: 2016-04-11
tags: AWS, aws-cli, STS
author: kohei
---

# はじめに
今回のAWS CLIアップデートでSTSに_get-caller-identity_というコマンドが追加されました。

**リリースノート**
<a href="https://aws.amazon.com/releasenotes/1133794697823335" target="_blank">https://aws.amazon.com/releasenotes/1133794697823335</a>

STS(_Security Token Service_)は<a href="https://sts.amazonaws.com" target="_blank">https://sts.amazonaws.com</a>に単一エンドポイントを持つグローバルサービスです。
AWSの_Account_、_UserID_、_Arn_が取得できます。

**コマンド**

```
$ aws sts get-caller-identity
```
それでは実際にコマンドを試してみます。


<br>
# 1.バージョン確認
とりあえず、現在インストールされているCLIのバージョンを確認します。

```bash:バージョン確認
$ aws --version
aws-cli/1.10.16 Python/2.7.10 Darwin/15.4.0 botocore/1.4.7
```
_get-caller-identity_は今回(1.10.18)から追加されたコマンドのため今のバージョンでは利用できません。
試しに、このままのバージョン(1.10.16)でコマンドを実行してみます。

```bash:GetCallerIdentity
$ aws sts get-caller-identity
usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help
aws: error: argument operation: Invalid choice, valid choices are:

assume-role                              | assume-role-with-saml
assume-role-with-web-identity            | decode-authorization-message
get-federation-token                     | get-session-token
help
```

案の定そのようなコマンドは無いと言われてしまいました。


<br>
# 2.アップグレード
それでは今回のバージョンへアップグレードします。

```bash:pipインストール
$  sudo pip install --upgrade awscli --ignore-installed six
```
バージョンを確認します。

```bash:バージョン確認
$ aws --version
aws-cli/1.10.18 Python/2.7.10 Darwin/15.4.0 botocore/1.4.9
```

アップデートが完了しました。


<br>
# 3.コマンド実行
では、コマンドを実行します。

```bash:GetCallerIdentity
$ aws sts get-caller-identity
{
    "Account": "123456789012",
    "UserId": "AIDA*****************",
    "Arn": "arn:aws:iam::123456789012:user/kohei"
}
```
無事、_AWS Account ID_が取得できているのが確認できます。

ちなみに今回取得できる値について簡単に説明しておきます。

- _Account_：AWSアカウントIDは、Amazonリソースネーム(ARN)を構築するのに使用する12桁の数字。
- _UserID_：現在のユーザーの一意のID。
- _Arn_：Amazonリソースネームの略で、AWSリソースを一意に識別する値。


<br>
<br>
# おわりに
このコマンドはグローバルエンドポイントを見に行って情報を取得してくれるためリージョンの指定などをすることなく実行できます。
これによって現在作業中のプロファイル情報がわかるので複数アカウント切り替えたりする環境ではとても役に立ちそうです。
