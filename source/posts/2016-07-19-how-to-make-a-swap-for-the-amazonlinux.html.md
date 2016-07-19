---
title: AmazonLinuxにswapを作成する。
date: 2016-07-19
tags: AWS
author: kohei
ogp:
  og:
    description: 'Amazon Linuxに2048MBのスワップを作成する作業を行います。'
---

# はじめに
_Amazon Linux_に2048MBのスワップを作成する作業を行います。

その前にまずスワップとは、
> スワップとは、ハードディスクなどの補助記憶装置を利用して使用可能なメモリ容量を増やすOSの機能の一つ。－ IT用語辞典(e-Words)より抜粋

つまり今回で言うとEBSボリュームの一部をメモリとして扱えるようにした領域のことです。

ということで作成してみます。


<br>
# 事前確認

```bash:swap確認①
$ free -m
             total       used       free     shared    buffers     cached
Mem:           491        353        138          0          8        294
-/+ buffers/cache:         49        442
Swap:            0          0          0
```

```bash:swap確認②
$ swapon -s
```


<br>
# スワップ領域の作成
まず、`dd`コマンドでスワップ用の領域を確保します。

```bash:swap領域作成
$ sudo dd if=/dev/zero of=/swapfile bs=1024 count=2048k
2097152+0 レコード入力
2097152+0 レコード出力
2147483648 バイト (2.1 GB) コピーされました、 32.0676 秒、 67.0 MB/秒
```

```bash:権限変更
$ sudo chmod 600 /swapfile 
```

作成したら`mkswap`でスワップを作成します。

```bash:swap作成
$ sudo mkswap /swapfile 
mkswap: /swapfile: warning: wiping old swap signature.
スワップ空間バージョン1を設定します、サイズ = 2097148 KiB
ラベルはありません, UUID=88c217dc-d8e0-42f9-b2bc-eb814505b5e3
```

以上で作成が完了しました。


<br>
# スワップ領域の有効化
`mkswap`で作成しただけでは利用できません。スワップの作成ができたら`swapon`でスワップ領域の有効化をします。

```bash:swap有効化
$ sudo swapon /swapfile 
```

```bash:swap確認①
$ free -m
             total       used       free     shared    buffers     cached
Mem:           491        485          6          0          4        421
-/+ buffers/cache:         59        432
Swap:         2047          0       2047
```

```bash:swap確認②
$ swapon -s
Filename				Type		Size	Used	Priority
/swapfile                              	file	2097148	0	-1
```


<br>
# スワップ領域の無効化
スワップ領域の有効化は`swapon`ですが、無効化は`swapoff`で行います。

```bash:swap無効化
$ sudo swapoff /swapfile 
```


<br>
# 自動マウント設定
毎回コマンドでスワップを有効化するのは大変ですので、起動時に自動マウントするように_/etc/fstab_に追記しておきます。

```bash:自動マウント
$ sudo vi /etc/fstab
/swapfile   none        swap    defaults        0   0
```
参考：[Arch Linux - fstab](https://wiki.archlinuxjp.org/index.php/Fstab)

以上で完了です。


<br>
# おわりに
かつての物理サーバでは、コストや仕様などの理由で利用出来るメモリに制限がありました。
ただ、今ではクラウドを利用することによって**swapを作成するならそれ以上にメモリを積む**であったり、**一台あたりのパワーを求めるよりスケールアウト**という発想の方が効率的になってきたこともありswapの利用する場面が少なくなっています。
とはいえ、**いざという時のswap**はあっても損じゃないかなと個人的には思います。

