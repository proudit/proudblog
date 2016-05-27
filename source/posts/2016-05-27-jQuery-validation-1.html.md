---
title: jQuery Validationを使ってフォームチェックをしてみる
date: 2016-05-27
tags: jQuery,Validation,
author: ayako
---

#はじめに
---

フォーム入力をする際、必須項目を未入力のまますっ飛ばすとフォームが赤くなって「必須記入項目です」なんて言われてしまったことありませんか？
今回、その動作をプラウディットHPに実装することになりました。

プロの方なら簡単なことなんだと思いますが、なんせ無知なので...
とっても時間がかかりました。

ちなみに、本番実装はまだです。
<br>

#jQueryって？Validationって？
---

まずここからです。
jQueryは聞いたことあるなー。Validationに関しては全く初めましてです！

詳しい説明は省きますが、jQueryとはJavaScriptのライブラリのこと。
そしてValidationとは、
入力フォームのバリデーション（チェック）を簡単に実装することが出来るjQueryプラグイン。
<br>

#まずサンプルを実装してみる
---

いろんなサイトにValidationの実装の仕方が載っているので、調べて手頃なものを引っ張ってきました。

今回参考にしたのは
http://www.webdesign-fan.com/jquery-validation-engine

一旦ローカルで実装するため、必要なファイルをダウンロードして、
サイト内にあったhtmlファイルを設置。

してみましたが、なぜか動きません。

jquery.validationEngine-ja.jsのファイルのパスが間違っていました。
js配下のlaguageフォルダの下にjquery.validationEngine-ja.jsが入ってしまっていて、
ファイルの読み込みができていませんでした。
その他のファイルと同じ階層に移動。

![スクリーンショット](./2016/0527_validation/validation_test_1.png)

これで解決。
無事に動作確認できました。
<br>

#既存のHTMLにValidationを追加
---

サンプルと同じように、ファイルを設置、コードを追加してみました！

あら？validation動いてない...

既存のhtmlには既に他のjavascriptも使われているので、何かが影響して動かないのか、
パスが違うのか...

今回追加したファイルは

・jquery-1.8.2.min.js (jQueryの本体)
・jquery.validationEngine.js (プラグインの本体)
・languages/jquery.validationEngine-ja.js (日本語ファイル)
・validationEngine.jquery.css (スタイルシート)

head要素内で上記ファイルが読み込めるようコードを記述。

```
    <!-- ▼jQuery本体 -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
    <!-- ▼バリデーション -->
    <link rel="stylesheet" href="css/validationEngine.jquery.css">
    <script src="js/jquery.validationEngine.js"></script>
    <script src="js/jquery.validationEngine-ja.js"></script>
    
    <script>
      $(function(){
        jQuery("#form").validationEngine();
      });
    </script>
```

フォームタグ内のチェックをしたいclass要素にvalidate[]という要素を追加

```
<form fole="form">
<div class="container">
	 		<div class="col-xs-8 col-xs-offset-2">
  				<div class="row">
   	 				<div class="col-sm-2"><label for="name">NAME</label></div>
   	 					<div class="col-sm-10 form-group">
   	   						<input type="text" class="validate[required] form-control input_per70" name="name"  id="name" placeholder="プラウド 太郎">
   	 					</div>
   	 					
   	 		----------以下省略----------

    		 <div class="form-group text-center">
               		 <!-- <button onClick="uploadFile();" type="submit" class="btn btn-dark">Send Inquiry</button> -->
                     <input onClick="uploadFile();" type="button" value="Send Inquiry"  class="btn btn-dark" />
          		</div>
   		</form>

```
<br>

#今回はまってしまった原因
---

①フォームチェックを行いたい対象のフォームIDがきちんと指定できていなかった

既存のファイルではform fole="form"という記述になっていました。
ここをform id="form"に変更しました。

②jQueryファイルを２つ読みこもうとしていた

設定を加える前に、すでにjquery.jsというフィルが存在しているところへ、
jquery-1.8.2.min.jsを読み込もうとしていました。

そのため、jquery.jsを削除。
こちらを削除したことで、その他の動作に影響もなさそうでした。

上記2点を行ったところ、しっかり動いてくれました。

![スクリーンショット](./2016/0527_validation/validation_test_2.png)

※ちなみに、jquery.jsとjquery.min.jsの違いとして、ファイルサイズの大きさ、
コードの見やすさがあるようです。
.minの方がサイズを小さくするために改行も削除され変数名も簡略化されていて読みにくく
なっているようですが。

自分でカスタマイズしたい人には圧縮されていない方がおすすめ、とのこと。
<br>

#おわりに

簡単にまとめましたが、ここに辿り着くまでコードを何度も読んだり、コードの順番を変えてみたり、ファイルの階層を変えてみたり、、
解決する気が全くしない...なんて思いながら。
本当に根気のいる作業だなと思いましたが、自分で解決できると楽しいですね！

ただ、まだこれで終わりではありません。
現在のままだと、必須項目ですというチェックをすることはできてもフォームが未入力でもフォームの送信ができてしまうんです...

この部分についてはまた調べてみようと思います。




  