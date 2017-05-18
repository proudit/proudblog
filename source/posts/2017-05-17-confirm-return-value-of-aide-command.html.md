---
title: AIDEの戻り値について。
date: 2017-05-17
tags: Linux, Security
author: kohei
ogp:
  og: 'AIDEの簡単な操作はAIDEを使ってファイルの改竄検知を行う。で行いました。今回はaideコマンド実行時の戻り値について「aide(1) - Linux man page」を参考に試してみたことをまとめてみました。'
---

# はじめに
AIDEの簡単な操作は[AIDEを使ってファイルの改竄検知を行う。](http://qiita.com/kooohei/items/bcf34fd82c2f98b0b559)で行いました。
今回はaideコマンド実行時の戻り値について[「aide(1) - Linux man page」](https://linux.die.net/man/1/aide)を参考に試してみたことをまとめてみました。

<br>
## ヘルプ : -h, --help
`-h`オプションを付与することでコマンドオプションについて確認ができます。

```bash:ヘルプ
$ sudo aide -h
Aide 0.14 

Usage: aide [options] command

Commands:
  -i, --init		Initialize the database
  -C, --check		Check the database
  -u, --update		Check and update the database non-interactively
      --compare		Compare two databases

Miscellaneous:
  -D, --config-check	Test the configuration file
  -v, --version		Show version of AIDE and compilation options
  -h, --help		Show this help message

Options:
  -c [cfgfile]	--config=[cfgfile]	Get config options from [cfgfile]
  -B "OPTION"	--before="OPTION"	Before configuration file is read define OPTION
  -A "OPTION"	--after="OPTION"	After configuration file is read define OPTION
  -r [reporter]	--report=[reporter]	Write report output to [reporter] url
  -V[level]	--verbose=[level]	Set debug message level to [level]
```

```bash:戻り値
$ echo $?
0
```

当然ですが戻り値は0です。


<br>
# 初期化 : -i, --init
```bash:初期化
$ sudo aide -i

AIDE, version 0.14

### AIDE database at /var/lib/aide/aide.db.new.gz initialized.
```

```bash:戻り値
$ echo $?
0
```
データベースの初期化は成功すると戻り値として0を返します。


<br>
# チェック : -C, --check
チェックオプションの場合はいくつかのパターンが考えられます。

<br>
## 変更なし
チェックした対象に異常(変更)がなかった場合。

```bash:チェック
$ sudo aide --check

AIDE, version 0.14

### All files match AIDE database. Looks okay!
```

```bash:戻り値
$ echo $?
0
```
この場合は正常ということになるので戻り値として**「0」**を返します。


<br>
## ファイル追加
知らないファイルが追加された場合を想定して`echo`コマンドでチェック対象下にファイルを作成します。

```bash:ファイル追加
$ echo test > /root/aide-test.txt
```
追加したらチェックしてみます。

```bash:チェック
$ sudo aide --check
AIDE found differences between database and filesystem!!
Start timestamp: 2017-05-09 12:40:40

Summary:
  Total number of files:  60777
  Added files:      1
  Removed files:    0
  Changed files:    1


---------------------------------------------------
Added files:
---------------------------------------------------

added: /root/aide-test.txt

---------------------------------------------------
Changed files:
---------------------------------------------------

changed: /root

--------------------------------------------------
Detailed information about changes:
---------------------------------------------------


Directory: /root
  Mtime    : 2017-05-09 12:39:22              , 2017-05-09 12:40:31
  Ctime    : 2017-05-09 12:39:22              , 2017-05-09 12:40:31
```

先ほど追加した`aide-test.txt`が__added__として検知されています。
また、追加したのが`/root`配下だったので`/root`が__changed__となってディレクトリもチェック対象となっているのがわかります。
これによってわかることは、誰かが侵入した痕跡を無くすためにファイルを削除しても、ディレクトリのタイムスタンプが変更されるため検知ができるということです。

```bash:戻り値
$ echo $?
5
```
この場合、戻り値は__「1(added)+4(chenged)=5」__となります。


<br>
## ファイル変更
ファイルの改竄を想定してファイルの内容を書き換えてチェックしてみました。

```bash:チェック
$ sudo aide --check
AIDE found differences between database and filesystem!!
Start timestamp: 2017-05-09 12:37:04

Summary:
  Total number of files:  60777
  Added files:      0
  Removed files:    0
  Changed files:    2


---------------------------------------------------
Changed files:
---------------------------------------------------

changed: /root
changed: /root/aide-test.txt

--------------------------------------------------
Detailed information about changes:
---------------------------------------------------


Directory: /root
  Mtime    : 2017-05-09 12:35:38              , 2017-05-09 12:36:58
  Ctime    : 2017-05-09 12:35:38              , 2017-05-09 12:36:58

File: /root/aide-test.txt
  Size     : 0                                , 10
  Mtime    : 2017-05-09 12:35:38              , 2017-05-09 12:36:58
  Ctime    : 2017-05-09 12:35:38              , 2017-05-09 12:36:58
  Inode    : 280877                           , 280993
  MD5      : 1B2M2Y8AsgTpgAmY7PhCfg==         , zWxWuS8Dv/wfLTIjnNCPTg==
  RMD160   : nBGFpcXp/FRhKAiXfuj1SLIljTE=     , 6MFLupcRlOJ+rJvp/EhoDXy0sok=
  SHA256   : 47DEQpj8HBSa+/TImW+5JCeuQeRkm5NM , ZS6XNHjHYKkKpR7In82NBLUv5A6kKDKc
```
ここで変更があったのは変更したファイル`aide-test.txt`とそのファイルが存在するディレクトリ`/root`になります。

```bash:戻り値
$ echo $?
4
```
戻り値は__「4(changed)」__となります。2箇所だから「あれ？4(changed)+4(changed)=8じゃないの？」と思ったりもするかもしれないですが、あくまでも戻り値は変更箇所があったということを示すだけですので１つでも2つでも、それ以上でも数は関係ありません。
でないと戻り値でのチェックができなくなってしまいますよね。


<br>
## 削除
今度は知らないうちにファイルが削除されていた場合についてです。

```bash:削除
$ rm /root/aide-test.txt 
rm: remove regular file ‘/root/aide-test.txt’? y
[root@ip-10-0-0-205 aide]# aide --check
AIDE found differences between database and filesystem!!
Start timestamp: 2017-05-09 12:29:56

Summary:
  Total number of files:  60777
  Added files:      0
  Removed files:    1
  Changed files:    1


---------------------------------------------------
Removed files:
---------------------------------------------------

removed: /root/aide-test.txt

---------------------------------------------------
Changed files:
---------------------------------------------------

changed: /root

--------------------------------------------------
Detailed information about changes:
---------------------------------------------------


Directory: /root
  Mtime    : 2017-05-09 12:26:38              , 2017-05-09 12:29:49
  Ctime    : 2017-05-09 12:26:38              , 2017-05-09 12:29:49
```
`aide-test.txt`がremovedでその削除したディレクトリである`/root`がchangedになります。

```bash:戻り値
$ echo $?
6
```
ファイルが削除されたので__「2(removed)+4(changed)=6」__となります。


<br>
# おわりに
とりあえずよく利用するオプションの戻り値を確認しました。
これを使ってスクリプトなんかを作成し、cronで実行したりなんかするといいのかなと思います。

