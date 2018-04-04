---
title: "EC2インスタンスに追加でEBSボリュームをアタッチする。"
date: 2018-04-04
tags: AWS, EC2
author: kohei
ogp:
  og: '普段 Mac で AWS CLI をよく利用するのですが、いちいち全部手入力は大変ですよね。。。 そんな時、コマンド補完機能を使えば、Tab キーを使って補完できるのでとても便利です'
---

# はじめに
稼働中のEC2インスタンスにEBSボリュームを追加したい場合の方法をまとめました。


<br>
# 事前確認
まずは作業前の状態を確認しておきます。

```bash:lsblk
$ lsblk 
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk 
└─xvda1 202:1    0   8G  0 part /
```

```bash:df
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         236M   60K  236M    1% /dev
tmpfs            245M     0  245M    0% /dev/shm
/dev/xvda1       7.8G  1.2G  6.6G   15% /
```

```bash:file
$ sudo file -s /dev/xvdf 
/dev/xvdf: data
```


<br>
# EBSボリュームの作成
管理コンソールの**「ELASTIC BLOCK STORE > ボリューム」**から**「ボリュームの作成」**をクリックします。

作成したいボリュームタイプやサイズを指定します。
ここでポイントがアベイラビリティゾーンです。今回アタッチしたいインスタンと同じアベイラビリティゾーンを指定します。

![スクリーンショット 2018-03-08 11.17.18.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0478e862-b407-8edc-2823-967ace89d04d.png)

**「ボリュームの作成」**をクリックします。

![スクリーンショット 2018-03-08 11.17.29.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ac1934fe-4169-4c29-da9b-beb739853c55.png)

作成したボリュームが_available_になれば作成完了です。

![スクリーンショット 2018-03-08 11.18.01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b42e254d-a052-9b01-234e-4b94acfa0876.png)


<br>
# EBSボリュームのアタッチ
先ほど作成したボリュームを指定し、**「アクション > ボリュームのアタッチ」**をクリックします。

![スクリーンショット 2018-03-08 11.20.10.png](https://qiita-image-store.s3.amazonaws.com/0/82090/43d88659-3f15-f3e6-f9f8-ee3201a2a42a.png)

ボリュームのアタッチで対象インスタンスを指定し**「アタッチ」**します。

![スクリーンショット 2018-03-08 11.21.13.png](https://qiita-image-store.s3.amazonaws.com/0/82090/40d23c11-a9a2-23bf-712b-8dff8f65ace1.png)

ステータスがin-useになったらアタッチ完了です。

![スクリーンショット 2018-03-08 11.21.43.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5149ab12-8fb1-cee2-60bf-473246aebd69.png)

コマンドで確認すると先ほどアタッチしたxvdfという名前のデバイスが追加されているのが確認できます。

```bash:lsblk
$ lsblk 
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0    8G  0 disk 
└─xvda1 202:1    0    8G  0 part /
xvdf    202:80   0  100G  0 disk 
```


<br>
# ファイルシステムの作成

アタッチされているのが確認できたらファイルシステムを作成します。

```bash:ファイルシステム作成
$ sudo mkfs -t ext4 /dev/xvdf
mke2fs 1.42.12 (29-Aug-2014)
Creating filesystem with 26214400 4k blocks and 6553600 inodes
Filesystem UUID: 1f00fbb1-7f0f-40d4-a189-10e8291ad8dd
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   
```

成功するとfileコマンドで確認ができます。

```
$ sudo file -s /dev/xvdf 
/dev/xvdf: Linux rev 1.0 ext4 filesystem data, UUID=1f00fbb1-7f0f-40d4-a189-10e8291ad8dd (extents) (large files) (huge files)
```

<br>
# EBSボリュームのマウント
マウントポイントを作成しマウントします。

```bash:マウントポイント作成
$ sudo mkdir /data
```

```bash:マウント
$ sudo mount /dev/xvdf /data
```

```bash:マウント確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         236M   60K  236M    1% /dev
tmpfs            245M     0  245M    0% /dev/shm
/dev/xvda1       7.8G  1.2G  6.6G   15% /
/dev/xvdf         99G   60M   94G    1% /data
```

以上で追加したEBSボリュームが利用できるようになりました。


<br>
# 自動マウント設定
最後の仕上げとして起動時に自動でマウントするように設定します。

```bash:アンマウント
$ sudo umount /data
```

_/etc/fstab_ に以下の内容を追記します。

```text:/etc/fstabに追加
/dev/xvdf   /data       ext4    defaults,nofail   0   2
```

追記したら確認です。

```bash:マウント
$ sudo mount -a
```

```bash:マウント確認
$ df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
devtmpfs         236M   60K  236M    1% /dev
tmpfs            245M     0  245M    0% /dev/shm
/dev/xvda1       7.8G  1.2G  6.6G   15% /
/dev/xvdf         99G   60M   94G    1% /data
```

以上で自動マウント設定も完了です。


<br>
# おわりに
EBSボリュームの追加を行う場合は対象となるインスタンスが稼働しているアベイラビリティゾーンを確認しておきましょう。違うアベイラビリティゾーンで作成してしまうとアタッチする際に対象となるインスタンスが表示されないからです。

