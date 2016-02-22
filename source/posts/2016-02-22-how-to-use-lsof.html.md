---
title: lsofを使ってプロセスが利用しているポートを確認する。
date: 2016-02-22
tags: Linux
author: kohei
---

``lsof``を使ってプロセスが利用しているポートを確認します。

利用シーンとして、自分はzabbixなどでポートやプロセスの監視設定をするときの確認で使ったりします。

# 利用されているポートを表示する
まずは、現在利用されているポートの一覧を表示します。

```コマンド:オプション-i
# lsof -i
COMMAND    PID     USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
dhclient  1254     root    5u  IPv4    6837      0t0  UDP *:bootpc
sshd      1440     root    3u  IPv4    7378      0t0  TCP *:ssh (LISTEN)
sshd      1440     root    4u  IPv6    7380      0t0  TCP *:ssh (LISTEN)
mysqld    2055    mysql   17u  IPv4    8001      0t0  TCP *:mysql (LISTEN)
```

このコマンドにパイプ( | )でgrep LISTENなどを付け加えてあげると
LISTENしているプロセスのみが表示させることができます。


# あるポートを利用しているプロセスを調べる
オプション``-i:ポート番号``でそのポートを利用しているプロセスを調べることができます。

```コマンド:オプション-i
# lsof -i:80
COMMAND   PID  USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
nginx   27576  root   10u  IPv4 3025923      0t0  TCP *:http (LISTEN)
nginx   27578 nginx   10u  IPv4 3025923      0t0  TCP *:http (LISTEN)
```
ここでは_80_番ポートはnginxが利用しているというのがわかります。

カンマ区切りで番号をしていると、複数ポートを同時に調べることもできます。

```コマンド:オプション-i
# lsof -i:22,80
COMMAND   PID     USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
sshd     1440     root    3u  IPv4    7378      0t0  TCP *:ssh (LISTEN)
sshd     1440     root    4u  IPv6    7380      0t0  TCP *:ssh (LISTEN)
sshd    27402     root    3u  IPv4 3024720      0t0  TCP 10.0.0.229:ssh->s225.HtokyoFL3.vectant.ne.jp:50596 (ESTABLISHED)
sshd    27404 ec2-user    3u  IPv4 3024720      0t0  TCP 10.0.0.229:ssh->s225.HtokyoFL3.vectant.ne.jp:50596 (ESTABLISHED)
nginx   27576     root   10u  IPv4 3025923      0t0  TCP *:http (LISTEN)
nginx   27578    nginx   10u  IPv4 3025923      0t0  TCP *:http (LISTEN)
nginx   27578    nginx   15u  IPv4 3058872      0t0  TCP 10.0.0.229:http->s225.HtokyoFL3.vectant.ne.jp:54589 (ESTABLISHED)
```
さらに``-iTCP``や``-iUDP``でTCPやUDPの指定をすることも可能です。

```コマンド:オプション-iTCP
# lsof -iTCP:22
COMMAND   PID     USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
sshd     1440     root    3u  IPv4    7378      0t0  TCP *:ssh (LISTEN)
sshd     1440     root    4u  IPv6    7380      0t0  TCP *:ssh (LISTEN)
sshd    27402     root    3u  IPv4 3024720      0t0  TCP 10.0.0.229:ssh->s225.HtokyoFL3.vectant.ne.jp:50596 (ESTABLISHED)
sshd    27404 ec2-user    3u  IPv4 3024720      0t0  TCP 10.0.0.229:ssh->s225.HtokyoFL3.vectant.ne.jp:50596 (ESTABLISHED)
```

【項目について】
COMMAND : 実行プログラム
PID : プロセスID
USER : 実行ユーザ
NODE : プロトコル
NAME : ポート
(LISTEN) : 待ち受け状態

今回はポートを利用しているプロセスの表示ですが、せっかくなので他の用途も載せておきます。

# 特定のPIDを持つプロセスが開いているファイルを表示
``-p``オプションはプロセスIDを元に、そのプロセスが利用しているファイルなどを表示します。

```コマンド:オプション-p
# lsof -p 1440
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1440 root  cwd    DIR  202,1     4096    2 /
sshd    1440 root  rtd    DIR  202,1     4096    2 /
sshd    1440 root  txt    REG  202,1   617128 7432 /usr/sbin/sshd
sshd    1440 root  mem    REG  202,1    62864 3764 /lib64/libnss_files-2.17.so
sshd    1440 root  mem    REG  202,1    44224 3776 /lib64/librt-2.17.so
```

# 特定のプロセスが開いているファイルを表示
``-c``オプションは特定のプロセスが利用しているファイルなどを表示します。

```コマンド:オプション-c
# lsof -c nginx
COMMAND   PID  USER   FD   TYPE             DEVICE SIZE/OFF    NODE NAME
nginx   27576  root  cwd    DIR              202,1     4096  272412 /etc/nginx/conf.d
nginx   27576  root  rtd    DIR              202,1     4096       2 /
nginx   27576  root  txt    REG              202,1   964976   18099 /usr/sbin/nginx
nginx   27576  root  DEL    REG                0,4          3025922 /dev/zero
nginx   27576  root  mem    REG              202,1    22096  272808　/usr/lib64/perl5/vendor_perl/auto/nginx/nginx.so
nginx   27576  root  mem    REG              202,1    62864    3764 /lib64/libnss_files-2.17.so
nginx   27576  root  mem    REG              202,1    10856    6562 /usr/lib64/libXau.so.6.0.0
nginx   27576  root  mem    REG              202,1   126288    3886 /usr/lib64/libselinux.so.1
nginx   27576  root  mem    REG              202,1   165264    4092 /lib64/libexpat.so.1.5.2
nginx   27576  root  mem    REG              202,1   122312    6606 /usr/lib64/libxcb.so.1.1.0
```

以上。

