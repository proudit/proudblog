---
title: AIDEを使ってファイルの改竄検知を行う。
date: 2017-05-08
tags: AWS, CentOS, Security
author: kohei
ogp:
  og: 'ファイル改竄検知にAIDE(Advanced Intrusion Detection Environment)というのがあります。'
---

# はじめに
ファイル改竄検知に [AIDE(Advanced Intrusion Detection Environment)](http://aide.sourceforge.net/) というのがあります。
オープンソースでAmazon Linuxにもリポジトリが存在するのでyumで簡単に導入することが可能です。


<br>
# インストール
リポジトリが存在するのでyumコマンドで簡単にインストールできます。

```bash:インストール
$ sudo yum install aide
```


<br>
# データベースの初期化
インストールできたらまずは初期化を行います。

```bash:初期化
$ sudo aide -i

AIDE, version 0.14

### AIDE database at /var/lib/aide/aide.db.new.gz initialized.
```

初期化が完了すると _aide.db.new.gz_ というファイルが作成されますが、デフォルトの参照ファイルは _aide.db.gz_ であるため、リネームします。

```bash:データベース配置
$ sudo cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```


<br>
# 改竄チェック
それではチェックしてみましょう。

```bash:改竄チェック
$ sudo aide --check

AIDE, version 0.14

### All files match AIDE database. Looks okay!
```

okayとあるため特に問題はないみたいですがそりゃそうですよね。何もしてないですからw
ということで、 _/root_ 配下に適当にファイルを作成してみます。

```bash:ファイル配置
$ sudo touch /root/aide-test.txt
```

それではもう一度チェックしてみましょう。

```bash:改竄チェック
$ sudo aide --check
AIDE found differences between database and filesystem!!
Start timestamp: 2017-04-28 17:36:55

Summary:
  Total number of files:	60760
  Added files:			1
  Removed files:		0
  Changed files:		1


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
  Mtime    : 2017-04-28 17:28:16              , 2017-04-28 17:36:47
  Ctime    : 2017-04-28 17:28:16              , 2017-04-28 17:36:47
```

先ほど作成したファイルが表示されました。追加/削除/変更が確認できるので便利ですね。


<br>
# 更新
このままだとチェックするたびに変更が増えていってしまいますね。
なのでデータベースを更新する必要があります。更新は初期化してあげればOKです。

```bash:データベース更新
$ sudo aide --init

AIDE, version 0.14

### AIDE database at /var/lib/aide/aide.db.new.gz initialized.
```

```bash:データベース更新
$ sudo cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```

これだと毎回「チェック → 更新」を繰り返さないといけないので面倒です。
そんな場合はupdateオプションを利用すれば解決です。


このオプションはチェックを行なった後、データベースの更新をしてくれます。


<br>
# オプション
主要なオプションについてまとめました。

|オプション           |説明                 |
|:-----------------|:--------------------|
|--init または -i   |データベースの初期化      |
|--check または -C  |データベースのチェック      |
|--update または -u |データベースのチェックと更新 |


<br>
# おわりに
これをcronとかで定期実行すればファイル改竄検知が手軽にできてとても便利ですね。

