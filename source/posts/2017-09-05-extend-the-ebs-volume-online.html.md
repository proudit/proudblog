---
title: "AWS Linux にアタッチされている EBS rootボリュームサイズをオンラインで拡張する。"
date: 2017-09-05
tags: AWS, EC2
author: kohei
ogp:
  og: '以前、[Amazon LinuxにアタッチされているEBSのボリュームサイズを拡張する。](http://qiita.com/kooohei/items/fdd37482e5878da3f4fd)を行いました'
---

# はじめに
以前、[Amazon LinuxにアタッチされているEBSのボリュームサイズを拡張する。](https://blog.proudit.jp/2017/02/21/expand-ebs-of-elastic-volume-functions.html)を行いました。
ですが、実はこれだとrootボリュームの場合はうまくいきません。(Amazon Linux の場合だと再起動する必要があると思います。)
なので、今回はrootボリュームをオンライン(再起動しない)で拡張したいと思います。

<br>
# 事前確認
まずは現在のボリュームを確認しておきます。

```
$ lsblk 
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  20G  0 disk 
└─xvda1 202:1    0  20G  0 part /
```

```
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         991M   56K  991M    1% /dev
tmpfs           1002M     0 1002M    0% /dev/shm
/dev/xvda1        20G  4.1G   16G   21% /
```

<br>
# ボリューム拡張

[AWSマネジメントコンソール](https://console.aws.amazon.com/)へログインします。

[EC2] > [インスタンス] から対象のインスタンスを選択し、[説明]タブに記載されているルートデバイスへ移動します。(初めからルートデバイスのボリュームがどれかわかっていたらそのままボリュームを選択してもOKです。)
![スクリーンショット 2017-08-25 23.06.19.png](https://qiita-image-store.s3.amazonaws.com/0/82090/63ea74e5-581b-f646-b1c1-ec0525751c67.png)

「アクション」 > 「ボリュームの変更」をクリックします。
![スクリーンショット 2017-08-25 23.15.33.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ce4dcdc2-021a-df78-45f9-b2aee79b2041.png)

「ボリュームの変更」でサイズを変更します。(今回は40へ変更)
![スクリーンショット 2017-08-25 23.15.56.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ba0d5a51-9d49-964e-0c27-bcc0f8eaf845.png)

確認で「はい」をクリック
![スクリーンショット 2017-08-25 23.16.12.png](https://qiita-image-store.s3.amazonaws.com/0/82090/afe9d1b2-d001-a526-183c-d970cdc4e0fb.png)

「ボリュームの変更リクエストが完了しました」と出るので「閉じる」をクリックします。
![スクリーンショット 2017-08-25 23.16.19.png](https://qiita-image-store.s3.amazonaws.com/0/82090/880b50f7-ef61-c369-b3e9-12b27275792e.png)

しばらくするとサイズが20GiBから40GiBへ変わります。

サーバへ入って確認するとボリュームサイズが拡張されているのがわかります。

```bash:確認
$ lsblk 
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  40G  0 disk 
└─xvda1 202:1    0  20G  0 part /
```

ですがまだファイルシステムからは見えているのは 20G のままです。

```bash:確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         991M   56K  991M    1% /dev
tmpfs           1002M     0 1002M    0% /dev/shm
/dev/xvda1        20G  4.1G   16G   21% /
```

growpart と resize2fs で拡張します。

```bash:growpart
$ sudo growpart /dev/xvda 1
CHANGED: disk=/dev/xvda partition=1: start=4096 old: size=41938910,end=41943006 new: size=83881950,end=83886046
```

```bash:resize2fs
$ sudo resize2fs /dev/xvda1
resize2fs 1.42.12 (29-Aug-2014)
Filesystem at /dev/xvda1 is mounted on /; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 3
The filesystem on /dev/xvda1 is now 10485243 (4k) blocks long.
```

```bash:確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         991M   56K  991M    1% /dev
tmpfs           1002M     0 1002M    0% /dev/shm
/dev/xvda1        40G  4.1G   36G   11% /
```

無事に拡張されました。

<br>
# おわりに
これで急なボリューム拡張が必要になってもサーバを停止する必要がないのでとても便利ですね。

