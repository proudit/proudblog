---
title: システムテスト自動化ツールSeleniumIDE
date: 2016-08-10
tags: SeleniumIDE,テスト自動化
author: ayako
ogp:
  og:
    description: 'テスト自動化ツールSeleniumIDE。今回はfirefoxのアドオンを使ってIDEをインストール、デモテストを行いました。システム開発の工数削減に役立つツールになるかを検証です！'
---

#はじめに
---
システム開発の作業工程の一つである、システムテスト。
そのテストを自動でできるツールがあるということで、どのようなものか実際に使ってみました。

_Seleniumとは：
webブラウザを使ってwebアプリケーションをテストするツール。
Seleiumは以下3つのプロダクトで構成されています。
- Selenium Grid
- Selenium IDE
- Selenium RC（Remote Control）_

※2011年にgoogleで開発していた**Webdriver**と統合し、**Selenium Webdriver**としてリリースされました。

#Seleniumをダウンロード
---
今回はSeleniumIDEというfirefoxのアドオンを使います。

まずはSeleniumの[ダウンロードサイトへ](http://www.seleniumhq.org/download/)

※ブラウザはfirefoxを使います。

ダウンロードページからアドオンのインストールができます。
![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_1.png)

![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_2.png)

アドオンへのインストールが完了すると、ブラウザの右上にIDEのアイコンが表示されます。

![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_3.png)

※googlechromeやIEでもこのIDE利用することができますが、
firefoxとは異なり、各ブラウザのドライバーやselenium-server-standalone-x.xx.x.jarのインストールも必要です。
詳細については割愛します。

##・早速テストをためしてみます

インストール後に表示されたIDEのアイコンをクリックすると操作画面のウィンドウが開きます。

![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_4.png)
[機能説明はこちらを参照してください](http://oss.infoscience.co.jp/seleniumhq/docs/03_selenium_ide.html#id3)

今回はfacebookログインで、ログイン失敗時に出るエラーメッセージの有無で、
ログイン動作確認(失敗した時の場合)をしてみます。
テストはgoogleでfacebookを検索→facebookを開く→ログイン
という流れで行いました。

まず、SeleniumIDEで動作の記録を開始(右上の赤丸ボタンをクリック)
facebookのログインページを開き、ログイン失敗になるように、不正な値を
入力します。
![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_5.png)

Seleniumの画面を見ると、ブラウザでの操作情報が記録されています。
ここに、追加のコマンドを挿入。

![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_6.png)

```
コマンド：verifyTextPresent
対象：入力されたメールアドレスまたは携帯電話番号はアカウントと一致しません。アカウントの登録
値：入力なし
```
_verifyTextPresent:対象である要素のテキストが値(パターン)と一致するか検証する_

テストを実行します。
結果は左下に表示されます。
テスト結果は成功です。

![SeleniumIDE](./2016/0810_SeleniumIDE/0810_SeleniumIDE_7.png)


#おわりに
---
初めて使ってみましたが、ブラウザ上で操作が可能なので抵抗なく使うことができました。
以前社内システムの開発グループに所属していたことがありますが、
プログラマーではなかったので、テスト作業をよくやっていました。
何度も同じテストを繰り返す作業って時間もかかるし、意外に根気の
いる作業だったりしますよね。
同じことを何度も繰り返すサイトや、長期継続的にリリースを行うようなサイト
人でが足りないなんて時には、作業工数を減らすという意味でも使えるツールかもしれません。





