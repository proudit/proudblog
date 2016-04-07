---
title: auditについてインストールと簡単な利用方法のメモ。
date: 2016-04-07
tags: Linux
author: kohei
---

# はじめに
## autditとは？
auditとはLinuxサーバで用いる監査ツールです。

<br>
## どんなことができるの？
SELinuxのAVC拒否、システムログイン、アカウント変更、sudoなどを使った認証結果などを監査することができます。
・システムイベントの記録
・監査イベントの記録
・バックアップのチェック
・ログファイルの切り替え
・設定ファイルの変更チェック
etc...


<br>
<br>
# 導入
auditのインストールと設定について簡単に説明します。

## 1. パッケージインストール
RedHat系はyum、Debian系はapt-getでパッケージインストールができます。

```bash:Debian系
$ sudo apt-get install auditd
```
```bash:RedHat系
$ sudo yum install audit
```

※パッケージの指定がapt-getの場合はauditd、yumの場合はauditとなるので注意してください。

<br>
## 2. 構成
基本的にauditdは設定ファイル(auditd.conf)とルール定義ファイル(audit.rules)、ログ(audit.log)の３つから構成されます。
またこれらのファイルは、デフォルトで以下のパスに配置されます。
・設定ファイル：_/etc/audit/auditd.conf_
・ルール定義ファイル：_/etc/audit/audit.rules_
・ログ：_/var/log/audit.log_

ということでインストールができたので、とにかく利用してみましょう。

<br>
## 3. ルールの確認
まずは、ルールの確認です。

```bash:-lオプション
$ sudo auditctl -l
No rules
```

初期は何もルールが設定されていないので"_No rules_"となります。
それでは何か追加してみましょう。

<br>
## 4. ルールの追加

```bash:確認
$ sudo auditctl -a exit,always -F arch=b64 -S open -F path=/etc/resolv.conf
```

_**-a filter,action**_：指定したルールを追加します。_filter_でフィルタを指定し、_action_で監査イベントを生成するかどうかを指定します。
ちなみに、_-a_でルールを末尾に追加、_-A_でルールを先頭に追加です。
_**-F**_：監査イベントで抜き出すための条件式を定義します。
_**-S**_：システムコール名やシステムコール番号を指定します。allはワイルドカードです。
_**-k**_：監査イベントにラベルを付けてログを後から検索できるようにする場合に指定します。

詳しい内容はまた記載しませんが、これは"_/etc/resolv.conf_"をopenするのをチェックしています。

ルールの追加が完了したらもう一度確認コマンドを実行してみましょう。

```bash:-lオプション
$ sudo auditctl -l
LIST_RULES: exit,always arch=3221225534 (0xc000003e) watch=/etc/resolv.conf syscall=open
```

ルールが追加されたのが確認できます。

<br>
## 5. ルールの削除
それでは追加したルールを今度は削除してみます。

```bash:削除
$ sudo auditctl -d exit,always -F arch=b64 -S open -F path=/etc/resolv.conf
```

_**-d**_：指定したルールを削除します。

それでは削除できているか確認します。

```bash:確認
$ sudo auditctl -l
No rules
```

一つしかルールがなかったので削除すると"No rules"になりました。


<br>
<br>
# 今回のまとめ
・auditはLinuxサーバで利用する監査ツール
・RedHat系はyum、Debian系はapt-getでパッケージインストールができる。
・パッケージインストールの指定はyumだとaudit、apt-getだとauditdになる。
・_auditctl -l_でルールの確認
・_auditctl -a_でルールの追加
・_auditctl -d_でルールの削除

以上です。

