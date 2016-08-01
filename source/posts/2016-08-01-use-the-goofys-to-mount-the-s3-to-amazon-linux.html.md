---
title: goofysを使ってAmazon LinuxにS3をマウントする。
date: 2016-08-01
tags: AWS,S3,goofys
author: kohei
ogp:
  og:
    description: 'AWSを利用していて、S3をサーバーマウントする技術として`s3fs`が有名だと思います。
ですが、**s3fsは遅い**と感じる人は少なくないかと思います。
そこで他に何かないかなと思って調べたところ、**[goofys](https://github.com/kahing/goofys)**というのがあるみたいです'
---

# はじめに
AWSを利用していて、S3をサーバーマウントする技術として`s3fs`が有名だと思います。
ですが、**s3fsは遅い**と感じる人は少なくないかと思います。
そこで他に何かないかなと思って調べたところ、**[goofys](https://github.com/kahing/goofys)**というのがあるみたいです。

goofysのREADMEに、以下のBenchmarkが載っていました。

![goofys-benchmark](https://github.com/kahing/goofys/blob/master/bench/bench.png?raw=true)

ということで、とりあえず`goofys`を使ってS3をマウントしたいと思います。


<br>
# goとfuseのインストール
まず、goofysを利用するにあたり、goとfuseが必要となるためパッケージをインストールします。

```bash:インストール
$ sudo yum install golang fuse
```

_golang_をインストールする際に依存関係がたくさんあるため_yum_で一気にインストールしてしまいましょう。


<br>
# AWS CLIの設定
_aws cli_環境を設定します。

```bash:設定
$ aws configure
AWS Access Key ID [None]: ********************
AWS Secret Access Key [None]: ****************************************
Default region name [None]: ap-northeast-1
Default output format [None]:
```


<br>
# バケットの作成

_aws cli_環境の設定ができたらマウントするためのバケットを作成します。

```bash:バケット作成
$ aws s3 mb s3://kohei-goofys
make_bucket: s3://kohei-goofys/
```

```bash:バケット確認
$ aws s3 ls s3://kohei-goofys
```

作成したばかりだとバケットには何も無いので`aws s3 ls`しても戻り値はありません。


<br>
# goofysインストール

まず、GOPATHを設定します。

```bash:パス設定
$ export GOPATH=$HOME/go
$ echo $GOPATH
/home/ec2-user/go
```
今回は_ec2-user_のホームディレクトリにインストールするようにしています。
設定ができたらインストールです。

```bash:インストール
$ go get github.com/kahing/goofys
$ go install github.com/kahing/goofys
```
*getもinstallもプロンプトが戻ってくるまでに若干時間がかかる可能性があります。


<br>
# S3マウント
インストールができたらいよいよマウントです。

```bash:マウントポイントの作成
$ mkdir ~/mount-goofys
```

```bash:マウント
$ ./go/bin/goofys kohei-goofys ~/mount-goofys
```

プロンプトが帰ってきたら完了です。
マウントに成功してもしなくても、何も戻ってこないので実際に確認してみます。


<br>
# 確認
確認ポイントは幾つかあります。

```bash:プロセス確認
$ ps auxf |grep goofys
ec2-user  3030  0.0  0.4 110472  2144 pts/0    S+   03:08   0:00              \_ grep --color=auto goofys
ec2-user  3022  0.3  2.7 197876 13668 ?        Ssl  03:08   0:00 /home/ec2-user/go/bin/goofys kohei-goofys /home/ec2-user/mount-goofys
```

```bash:ログ確認
$ sudo grep goofys /var/log/messages
Jul  1 03:08:50 ip-172-31-3-125 /home/ec2-user/go/bin/goofys[3022]: s3.ERROR code=incorrect region, the bucket is not in 'us-west-2' region msg=301 request=#012
Jul  1 03:08:51 ip-172-31-3-125 /home/ec2-user/go/bin/goofys[3022]: s3.INFO Switching from region 'us-west-2' to 'ap-northeast-1'
Jul  1 03:08:51 ip-172-31-3-125 /home/ec2-user/go/bin/goofys[3022]: main.INFO File system has been successfully mounted.
```

```bash:ボリューム確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
/dev/xvda1       7.8G  1.6G  6.1G   21% /
devtmpfs         238M   56K  238M    1% /dev
tmpfs            246M     0  246M    0% /dev/shm
kohei-goofys     1.0P     0  1.0P    0% /home/ec2-user/mount-goofys
```

無事マウントができたようです。
では、ファイルの作成を行います。

```bash:ファイルの作成
$ touch ~/mount-goofys/test
$ ls ~/mount-goofys/
test
```

作成できたら`aws s3`コマンドでバケット内を直接確認してみます。



```bash:バケット内の確認
$ aws s3 ls s3://kohei-goofys
2016-07-01 03:14:44          0 test
```

先ほど作成されたコマンドがこちらからでも確認できました。



<br>
# 自動マウント設定

マウントはできるようになりましたが、毎回手動でマウントするのは大変です。
なので_/etc/fstab_にサーバー起動時にマウントされるように設定します。

ただ、ここでポイントは**サーバー起動時は_root_**で処理が実行されます。
ということは_aws cli_の設定もrootで行う必要があります。

```bash:設定
$ sudo aws configure
AWS Access Key ID [None]: ********************
AWS Secret Access Key [None]: ****************************************
Default region name [None]: ap-northeast-1
Default output format [None]:
```

設定ができたら_fstab_を修正します。

```bash:fstab修正
$ sudo vi /etc/fstab
$ cat /etc/fstab
#
LABEL=/     /           ext4    defaults,noatime  1   1
tmpfs       /dev/shm    tmpfs   defaults        0   0
devpts      /dev/pts    devpts  gid=5,mode=620  0   0
sysfs       /sys        sysfs   defaults        0   0
proc        /proc       proc    defaults        0   0
/home/ec2-user/go/bin/goofys#kohei-goofys /home/ec2-user/mount-goofys fuse _netdev,allow_other,--file-mode=0666,--uid=500,--gid=500 0 0
```

ここでとても重要なのがオプションで_allow_other_が指定されていることです。
このオプションがないとroot以外のユーザーからは見えなくなってしまいます。
また、_--file-mode_と_--uid_、_--gid_はファイルやディレクトリが作成された際のデフォルト権限/所有者の設定になります。

今回の場合は_ec2-user_がUID、GIDともに500でした。

```bash:id確認
$ id
uid=500(ec2-user) gid=500(ec2-user) groups=500(ec2-user),10(wheel)
```


修正が完了したら自動マウントを確認します。

```bash:自動マウント
$ sudo mount -a
```

```bash:確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
/dev/xvda1       7.8G  1.6G  6.1G   21% /
devtmpfs         238M   56K  238M    1% /dev
tmpfs            246M     0  246M    0% /dev/shm
kohei-goofys     1.0P     0  1.0P    0% /home/ec2-user/mount-goofys
```

ちゃんとマウントができたのが確認できます。
もし、ここでマウントが見えなかったら`sudo df -h`を試してみてください。
それで見える場合は権限周りがうまくできてない可能性があります。

| オプション     | 説明                             |
| :---------- | :------------------------------ |
| _netdev     | ネットワークが有効になるまでマウントを待つためのオプション。<br>ネットワーク経由のデバイスを起動時にマウントさせたい場合などに指定する。 |
| allow_other | 他のユーザーでも利用できるようにする。    |
| --file-mode | マウントする際のファイル権限を設定する。   |
| --uid       | マウントするユーザーIDを指定する。       |
| --gid       | マウントするグループIDを指定する。       |

また、上記は今回使ったオプションの説明となるので参考にしてもらえればと思います。

<br>
# おわりに

とりあえず**_goofys_**がどんな感じかを試したくて行いましたが、導入はとても簡単でした。
ただ、自動マウント設定の際のアクセス権限周りの挙動を確認するのに少々時間かかったかなという感じです。
GitHubの[Benchmark](https://github.com/kahing/goofys#benchmark)ではs3fsよりかなり優秀な感じですが、実際比較はまだしてないのでそっちの方も検証できたらなと思っています。
