---
title: "Could not open output pipe '/dev/xconsole' [try http://www.rsyslog.com/e/2039 ]"
date: 2017-07-05
tags: rsyslog
author: kohei
ogp:
  og: 'rsyslogの設定をしていて以下のログを見つけました。'
---

# はじめに
rsyslogの設定をしていて以下のログを見つけました。

```text:log
Jun 10 13:02:34 hogehoge kernel: imklog 5.8.10, log source = /proc/kmsg started.
Jun 10 13:02:34 hogehoge rsyslogd: [origin software="rsyslogd" swVersion="5.8.10" x-pid="8842" x-info="http://www.rsyslog.com"] start
Jun 10 13:02:34 hogehoge rsyslogd-2039: Could not open output pipe '/dev/xconsole' [try http://www.rsyslog.com/e/2039 ]
```

*/dev/xconsole* が *Could not open...* 確かに確認して見たところそんなファイル存在しませんでした。


<br>
# 原因
これはFIFOファイルが存在しないということが原因です。

FIFOについてはこちらの 「[mkfifoコマンドって使ってますか？](http://qiita.com/richmikan@github/items/bb660a58690ac01ec295)」 にわかりやすく書かれています。


<br>
# 対応
ということで、FIFOファイルを作成してあげることで解決です。

```bash:コマンド
$ sudo mkfifo /dev/xconsole
```

<br>
# おわりに
今回、rsyslogに初めて触れてFIFOログというものがあるのを知りました。今回は作成するだけで、正直扱い方はまだまだ理解できていません。今後、少しずつでも深めていけたらなと思います。

