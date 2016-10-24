---
title: JAWS FESTA 2016に行ってきました！
date: 2016-10-24
tags: JAWS-UG
author: kohei
ogp:
  og: 'JAWS FESTA 2016に行ってきました！'
---

10/22(土)に開催された、[JAWS FESTA 2016](http://jft2016.jaws-ug.jp)に行ってきました！
<br>
![jaws-festa-2016](http://jft2016.jaws-ug.jp/wp-content/themes/jawsfesta2016/images/default-image.png)

<br>
2013 関西、2014 東北、2015 九州と続き、2016は東海道！場所は名古屋。
会場は名古屋工業大学で開催されました。

![map1](http://jft2016.jaws-ug.jp/wp-content/uploads/2016/10/festamap.png)
![map2](http://jft2016.jaws-ug.jp/wp-content/uploads/2016/10/festaroom.png)

学生や子連れの方とかも結構参加していて、今までJAWS DAYSとかしか参加してなかったのでとても新鮮でした。

<br>
10:00開場でオープニングは11:00から。5111教室で元AWS Enterprise Evangelistの渥美さんが「金融クラウド＆FINTECH最前線。～AWSで金融からイノベーション！」という題目で金融クラウドをとりまく業界動向とその背景、今後の動きについて話してくださりました。

![facebook01](https://scontent.xx.fbcdn.net/t31.0-8/p720x720/14682058_1288387947852148_8660944754944267812_o.jpg)
出典：[JAWS FESTA facebook](https://www.facebook.com/JawsFesta/)

<br>
お昼(12:00ころ)からはAWSジャパンさん、cloudpackさん、サーバーワークスさんなどのいろんな企業さんがランチセッションを開いてお昼ご飯を食べながらの講演会もありました。

<br>
そして13:00！いよいよ楽しみにしていた"IoTハンズオン「RaspberryPiで照度計の計測値をAWSに送って可視化しよう」"が始まります。
<br>
実は今回のFestaでは、
- 13:00〜14:50 [【前半の部】IoTハンズオン「RaspberryPiで照度計の計測値をAWSに送って可視化しよう」](http://jft2016.jaws-ug.jp/speaker/345)
- 15:00〜16:50 [【後半の部】IoTハンズオン「ミニチュアIoT家電をAWS IoT + SORACOM Beamで制御してみよう」](http://jft2016.jaws-ug.jp/speaker/349)
というのに参加を申し込みしています。
このセッションは具材準備などの関係もあって事前登録制で有料です。といっても通しで1300円くらい。安いですね！

<br>
**【前半の部】IoTハンズオン「RaspberryPiで照度計の計測値をAWSに送って可視化しよう」**
ここでのハンズオンでは、
・ラズパイとブレッドボードを使って、簡易照度センサーを作り、そこで取得した値をDynamoDBへ格納
・[IoT.kyoto](http://www.iot.kyoto)がDynamoDBに格納したデータを取り出して可視化する
ということを行いました。

![img1](../images/2016/1024_fawsfesta/jawsfesta2016_iot11.jpg)

つまりこれと、
![img2](../images/2016/1024_fawsfesta/jawsfesta2016_iot12.jpg)

これで、
![img3](../images/2016/1024_fawsfesta/jawsfesta2016_iot13.jpg)

これを作りました！
![img4](../images/2016/1024_fawsfesta/jawsfesta2016_iot15.jpg)

そして、ラズパイでプログラムを動かして照度値を取得します。
![img5](../images/2016/1024_fawsfesta/jawsfesta2016_iot16.jpg)

バッチリ動いてますね。

そしたら、この値をDynamoDBへ送って、http://www.iot.kyotoで可視化で完了です。
![img6](../images/2016/1024_fawsfesta/jawsfesta2016_iot17.png)

こんなことをやりました。めちゃくちゃ面白かったです！

なのでぜひご興味のある方はトライしてみてください。
[RaspberryPiでセンサーデータをfluentdを使ってDynamoDBに送って可視化してみよう＜完全編＞](http://qiita.com/Ichiro_Tsuji/items/fce61bdd5974a2c9cf14)


<br>
**【後半の部】IoTハンズオン「ミニチュアIoT家電をAWS IoT + SORACOM Beamで制御してみよう」**
ここでのハンズオンは、
・ラズパイでミニチュアライトを作成してPythonプログラムでライトのオン・オフを制御させる
・それをSORACOM BeamとAWS IoT Thingsを使って手元のPCからオン・オフをリモート制御できるようにする
といことを行いました。

すみません。。。後半はバタバタしてて完全に写真撮るのわすれました。。。
![img7](../images/2016/1024_fawsfesta/jawsfesta2016_iot21.jpg)

なので知りたい方は是非以下をトライしてみてください。
[「SORACOM x RaspberryPi ハンズオン 〜超音波センサー編〜」](https://github.com/soracom/handson/blob/master/ultrasonic-sensor/seminar.md)
[ミニチュアIoT家電をAWS IoT + SORACOM Beamで制御してみよう](http://qiita.com/dietposter/items/62c64c9f479144cb6469#step-21aws-iot-thingsを作成)


<br>
FESTAの最後はパネルディスカッションです。

<br>
ハンズラボ長谷川さんがモデレーターをし、パネラーとして元AWSの小島さん、さくらインターネットの田中さん、サイボウズの伊佐さんが登壇されました。
普段は話せないあんなことやこんなことを話してくださりあっという間のディスカッションでした。
![img8](../images/2016/1024_fawsfesta/jawsfesta2016_end.png)

<br>
そしてFESTAの後は懇親会へ！

<br>
さすがに大学でドンチャン騒ぎはできませんねw
場所を「サッポロビール 名古屋ビール園 浩養園」へ移しスタートです。

<br>
AWSカルタや、
![img9](../images/2016/1024_fawsfesta/jawsfesta2016_uchiage2.jpg)

<br>
LT大会。
![img10](../images/2016/1024_fawsfesta/jawsfesta2016_uchiage5.jpg)

<br>
もちろんパイ投げもw
![img11](../images/2016/1024_fawsfesta/jawsfesta2016_uchiage3.jpg)

<br>
ということでとても楽しい1日でした。

<br>
![jft2016](http://jft2016.jaws-ug.jp/wp-content/uploads/2016/10/29872137013_692c0b3bd2_k.jpg)
出典：[AWS User Group Japan](http://jft2016.jaws-ug.jp)

<br>
運営の皆様。楽しい時間をありがとうございましたm(__)m
運営の皆様。楽しい時間をありがとうございましたm(__)m
