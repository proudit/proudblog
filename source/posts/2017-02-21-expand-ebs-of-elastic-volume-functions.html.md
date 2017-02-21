---
title: Amazon LinuxにアタッチされているEBSのボリュームサイズを拡張する。
date: 2017-02-21
tags: AWS, EC2
author: kohei
ogp:
  og: 'つい先日、Amazon EBSのアップデートで「エラスティックボリューム」の発表がありました'
---

# はじめに
つい先日、Amazon EBSのアップデートで [「エラスティックボリューム」の発表](https://aws.amazon.com/jp/blogs/news/amazon-ebs-update-new-elastic-volumes-change-everything/) がありました。
これはEC2にアタッチされたEBSに対し、**「ボリュームサイズの拡張」**、**「パフォーマンスの調整」**、**「ボリュームタイプの変更」**がオンラインで行うことができます。
ということで今回、**「ボリュームサイズの拡張」**を行ってみたいと思います。


<br>
# 事前確認
今回作業するOSは **Amazon Linux 2016.09** です。
まずは状況確認しておきます。

```bash:デバイスの確認
$ lsblk 
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk 
└─xvda1 202:1    0   8G  0 part /
xvdb    202:16   0  10G  0 disk /data
```
現在、 *xvdb* という名前でボリュームサイズが**10GB**のデバイスがEC2インスタンスにアタッチされています。

```bash:ボリュームの確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         236M   60K  236M    1% /dev
tmpfs            246M     0  246M    0% /dev/shm
/dev/xvda1       7.8G  984M  6.7G   13% /
/dev/xvdb        9.8G   23M  9.2G    1% /data
```

また、 ファイルシステムとしても**10GB**のボリュームが */data* 領域にマウントされているのを確認できます。

今回はこの *xvdb* のボリュームサイズを拡張します。


<br>
# EBSサイズの拡張
[EC2] > [ボリューム]　から対象となるボリュームをチェックし、[アクション]から[Modify Volume]をクリックします。
![expand-ebs01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/cdf9f531-db9f-f7c7-ce6f-b457494100d8.png)

今回は **20GB** へ拡張するので「Size」の**10**を**20**に変更し[Modify]をクリックします。
![expand-ebs02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9fa62d1f-2516-cdd1-12f3-9ad719cfb0fd.png)

「ボリュームの変更をしても本当にいいですか？」と聞かれるので、[Yes]をクリックします。
![expand-ebs03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/55621be7-fa2e-865e-2647-af650a97bdc2.png)

すると**「in-use optimizing」**というステータスになります。変更したサイズへ拡張中です。
![expand-ebs04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/34b0a05d-4688-4584-bb05-eeebe9da4aab.png)

しばらくして**「in-use completed」**になったらEBS拡張処理の完了です。
![expand-ebs05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/dfa02cce-fc86-b5df-6469-182f3b0f3a69.png)


<br>
# ファイルシステムサイズの拡張
それでは先ほど拡張したボリュームサイズがちゃんと**20GB**に増えているか確認してみます。

```bash:デバイスの確認
$ lsblk 
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk 
└─xvda1 202:1    0   8G  0 part /
xvdb    202:16   0  20G  0 disk /data
```

無事、**20GB**のボリュームとして認識されているのが確認できました。
ですが、今のままだとEBSデバイスのサイズが増えただけです。

```bash:ボリュームの確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         236M   60K  236M    1% /dev
tmpfs            246M     0  246M    0% /dev/shm
/dev/xvda1       7.8G  985M  6.7G   13% /
/dev/xvdb        9.8G   23M  9.2G    1% /data
```
なので、まだこのままではOSから利用することはできません。
ということでOSから利用できるように`resize2fs`でファイルシステムをリサイズします。

```bash:ファイルシステムの拡張
$ sudo resize2fs /dev/xvdb 
resize2fs 1.42.12 (29-Aug-2014)
Filesystem at /dev/xvdb is mounted on /data; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/xvdb is now 5242880 (4k) blocks long.
```
これでファイルシステムのリサイズ完了です。

```bash:ボリュームの確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         236M   60K  236M    1% /dev
tmpfs            246M     0  246M    0% /dev/shm
/dev/xvda1       7.8G  985M  6.7G   13% /
/dev/xvdb         20G   28M   19G    1% /data
```

ということで無事にOSから利用できるようになりました。


<br>
# おわりに
これで「とりあえず多めに確保」をする必要も無くなり、「今必要なサイズ」を割り当てれば良くなりました。
また、拡張作業もオンタイムで行えるので、費用面だけでなく運用面のコスト削減にもなります。
これで「いろんな人の負担」がかなり軽くなりますね。
