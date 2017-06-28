---
title: "mysqldump: Got errno 28 on write"
date: 2017-06-28
tags: MySQL
author: kohei
ogp:
  og: 'mysqldumpをしていたところ`mysqldump: Got errno 28 on write`というエラーでdumpが>止まってしまいました。。。。'
---

# はじめに
mysqldumpをしていたところ`mysqldump: Got errno 28 on write`というエラーでdumpが止まってしまいました。。。。

少し調べてすぐ原因がわかりました。。。容量が。。。

```bash:
$ df -h
Filesystem          サイズ  使用  残り 使用% マウント位置
/dev/mapper/mysqlvg-sysmte
                       30G   30G     0 100% /
```

<br>
# 原因
dumpしているディスクがフルになった場合に発生。

<br>
# 対処
・不要なファイルがあれば削除して頑張って容量を空けましょう。
・容量に余裕のある他のサーバを使ってdumpしましょう。
・ボリュームの追加をしてあげましょう。

<br>
# おわりに
検証で利用していたサーバーであったため、あまり空き容量を意識してませんでした。
ですがディスクフルにするなんて絶対やってはいけないことです。自分への戒めも兼ねて。

