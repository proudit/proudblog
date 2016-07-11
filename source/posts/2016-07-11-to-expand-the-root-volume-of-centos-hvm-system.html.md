---
title: CentOS HVM方式のルートボリュームを拡張する。
date: 2016-07-11
tags: AWS, CentOS
author: kohei
ogp:
  og:
    description: 'AWS Marketplaceにある**「CentOS 6 (x86_64) - with Updates HVM」**を利用してイン>スタンスを作成する際、インスタンス作成時の「ストレージの追加」でルートボリューム
を増やしたとしてもOSから見えるボリュームは変わりません。'
---

# はじめに
AWS Marketplaceにある**「CentOS 6 (x86_64) - with Updates HVM」**を利用してインスタンスを作成する際、インスタンス作成時の「ストレージの追加」でルートボリュームを増やしたとしてもOSから見えるボリュームは変わりません。

今回、ルートボリュームサイズを30GiBに拡張したいと思います。
![2016-06-20.png](https://qiita-image-store.s3.amazonaws.com/0/82090/644e1a43-3062-087f-7e9f-41cbab1b9833.png)

```bash:ボリュームサイズ
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      7.8G  666M  6.7G   9% /
tmpfs           498M     0  498M   0% /dev/shm
```

ただ、アタッチされているボリュームサイズについて確認してみると、

```bash:
$ lsblk 
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  30G  0 disk 
└─xvda1 202:1    0   8G  0 part /
```
割り当てられてはいるけどパーティションの拡張ができていない状態のようです。
AMIがHVM方式のを選択すると、このように自動的に拡張されない場合があるようです。


>----------------------------------------------------------------------
## HVMとは
HVMとは「Hardware-assited VM」の略で、日本語では完全仮想化と言われています。
EC2ユーザーガイドの説明には以下のように記載されています。
>>**HVM AMI**
HVM AMI は、完全に仮想化された一連のハードウェアを備えており、イメージのルートブロックデバイスのマスターブートレコードを実行することによって起動します。この仮想化タイプでは、ベアメタルハードウェア上でオペレーティングシステムが動作するのと同様に、修正を行わなくても仮想マシン上でオペレーティングシステムを直接実行することができます。Amazon EC2 ホストシステムでは、ゲストに提供されている基盤となるハードウェアの一部またはすべてがエミュレートされます。

>----------------------------------------------------------------------


ということでパーティションの拡張をしたいと思います。


<br>
# 準備
まずはじめに、_dracut-modules-growroot_と_cloud-utils-growpart_この２つのパッケージをインストールします。

ただ、これらのパッケージはデフォルトのリポジトリからは取得できないのでリポジトリを追加します。

```bash:リポジトリ追加
$ sudo yum install wget

$ wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

$ sudo rpm -i epel-release-6-8.noarch.rpm 
```
ここでは`wget`コマンドがインストールされていなかったので、初めにインストールしています。

それでは今回の作業に必要なパッケージをインストールします。

```bash:インストール
$ sudo yum install dracut-modules-growroot

・・・省略・・・
Installed:
  dracut-modules-growroot.noarch 0:0.20-2.el6                                                                       

Dependency Installed:
  cloud-utils-growpart.x86_64 0:0.27-10.el6                                                                         

Complete!

```
以上で準備完了です。


<br>
# 拡張
それでは拡張作業を行います。

```bash:拡張
$ sudo dracut --force --add growroot /boot/initramfs-$(uname -r).img
```
ここで行っているのは_--add_オプションを使って_initramfs-2.6.32-573.18.1.el6.x86_64.img_のイメージファイルにgrowrootモジュールを追加しています。
2.6.32-573.18.1.el6.x86_64は`uname -r`コマンドで取得される値です。

少し間がありプロンプトが返ってきたら完了です。それではサーバーを再起動します。

```bash:再起動
$ sudo reboot
```


<br>
>----------------------------------------------------------------------
## dracutとは
dracutなんて普段見慣れない方が多いかと思います。ということで[Dracut Wiki（by The Linux Kernel Organization）](https://dracut.wiki.kernel.org/index.php/Main_Page)によると、、、

>>dracut
---
dracut is an event driven initramfs infrastructure. dracut (the tool) is used to create an initramfs image by copying tools and files from an installed system and combining it with the dracut framework, usually found in /usr/lib/dracut/modules.d. .....

>つまりは「initramfsを作成するコマンド」みたいです。（かなりざっくりですみません。。。）
>今回の場合_--add_オプションでdraucutモジュールのgrowrootをイメージに追加しています。
_--force_オプションはすでに存在しているinitramfsに対して上書きする場合に指定します。

>その他にdracutについて知りたい場合は以下を参考にしてください。
>・[dracut(8) - Linux man page](http://linux.die.net/man/8/dracut)：コマンドオプションについて色々説明しています。
>・[dracut - www.kernel.org](https://www.kernel.org/pub/linux/utils/boot/dracut/dracut.html)：利用例などについて説明しています。

>----------------------------------------------------------------------

<br>
# 確認
それではボリュームを確認してみます。

```bash:確認
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      985G  735M  934G   1% /
tmpfs           498M     0  498M   0% /dev/shm
```

OSから無事認識されているのが確認できます。

```bash:確認
$ lsblk 
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0 1000G  0 disk 
└─xvda1 202:1    0 1000G  0 part /
```

`lsblk`コマンドでもパーティションが割り当てたボリュームまで拡張されているのが確認できました。


<br>
# おわりに
今回の拡張作業で`dracut`コマンドを利用していますが、実際は`dracut`コマンドが拡張するコマンドではありません。
ボリュームの拡張は`growpart`によって行われています。それを`yum`でインストールし`dracut`で追加した`growroot`をイメージに追加することで、起動時に`growpart`が実行され、パーティションが割り当てたボリュームまで拡張されます。
また、`growpart`コマンドも今回はインストールされていなかったのですが、`yum`を使うと_dracut-modules-growroot_の依存関係で_cloud-utils-growpart_もインストールしてくれるため利用できるようになります。

