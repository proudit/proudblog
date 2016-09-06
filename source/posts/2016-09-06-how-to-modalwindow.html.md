---
title: モダールウィンドウの設定
date: 2016-09-06
tags: jQuery,JavaScript
author: ayako
ogp:
  og:
    description: ' remodalというjQueryのライブラリを使って、モーダルウィンドウを設置してみました。'
---

#はじめに
---
モーダルウィンドウとはなんでしょう？

```
モーダルウィンドウとは、操作が完了するまで親ウィンドウへの操作を受け付けなくさせるタイプのウィンドウのことである。
```
引用元：[IT用語辞典](http://www.sophia-it.com/content/%E3%83%A2%E3%83%BC%E3%83%80%E3%83%AB%E3%82%A6%E3%82%A3%E3%83%B3%E3%83%89%E3%82%A6)

![modalwindow](./2016/0906_modalwindow_setting/modalwindow_01.png)

ページ遷移すること無く、もとのページがグレーアウトした状態で、子ウィンドウをオーバレイする状態で表示させることができます。

画面遷移せずに同ページ内で別コンテンツを開くことができるという利点がある一方で、
モダールウィンドウであることがユーザーに認識されづらく、
ユーザビリティが欠落してしまうケースや、スマートフォンのような小さな画面ではウィンドウを閉じる場合、
操作性が悪い等、、デメリットも多くあるのです。

設置の際はそういった点も考慮する必要がありそうです。

前置きが長くなりましたが、早速実践してみましょう！

#モーダルウィンドウの設置
---
このモダールウィンドウ設置のために利用したのは**remodal**というプラグイン。
軽量かつシンプル。
ギャラリー機能は無く、テキスト表示のみ対応です。
今回はテキスト表示が目的なので、こちらを選びましたが、
モダールウィンドウのプラグインはこの他にも多くあるので、用途に合わせて
使い分けしてみてください。

まずはremodalのファイルをダウンロード。
ダウンロードした以下ファイルを任意のフォルダに設置し、読み込みます。

・remodal.js
・remodal-default-theme.css
・remodal.css

```
<script src="../js/remodal.js"></script>

<link rel="stylesheet" href="css/remodal.css">
<link rel="stylesheet" href="css/remodal-default-theme.css">
```
ソースコードの記述。

```
<!-- 呼び出し用ボタン -->
<a href="#modal" class="btn btn-default">Modalデモ</a>

<!-- Modal本体 -->
<!-- ボタンが押されると呼び出される -->
<div class="remodal" data-remodal-id="modal">
<!-- クローズボタン -->
<button data-remodal-action="close" class="remodal-close"></button>
<h1>Remodal</h1>
<!-- your content -->
<p> Remodalテスト </p>
<p> Write something. </p>
<br>
<!-- キャンセルボタン -->
<button data-remodal-action="cancel" class="remodal-cancel">Cancel</button>
<!-- サブミットボタン -->
<button data-remodal-action="confirm" class="remodal-confirm">OK</button>
</div>
```

以上です！
とっても簡単ですよね！

#おわりに
---
プラグインを利用したので、スムーズに設置することができました。
が、今回テキスト表示のみのプラグインを利用したので、カスタマイズはしづらいです。
テキスト表示といっても長文テキストを仕込んだので、その分コードが
長くなってしまいました・・・

ここをなんとかシンプルにまとめる方法はないかな、と今後改善したいと思っています。






