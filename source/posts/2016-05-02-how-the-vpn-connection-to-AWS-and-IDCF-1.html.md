---
title: 第１回 AWSとIDCFをVPN接続する - IDCF準備編（全４回）
date: 2016-05-02
tags: IDCFクラウド, AWS, VPN, VyOS, vpc 
author: kohei
---

# はじめに
---
IDCFクラウドにVyOSで仮想マシンを作成して、IDCFクラウドとAWSをVPNで接続する設定を説明します。
![idcf-vpn-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9b15d672-f654-ab05-fb61-57cf8951b58e.png)
できるだけ行っていることが意識しやすいように作業ポイントごとに回を区切っています。
今回はIDCFクラウドで仮想マシンを作成し、グローバルIPアドレスを付与しFWの設定まで行います。
![idcf-vpn-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/903a6791-fb65-6fd3-5ecd-566c1a605c52.png)

<br>
# ゲートウェイの作成 - IDCF
---
IDCFクラウドでは仮想マシンでVyOSが選択できるのでそれを利用します。

<br>
## 仮想マシンの作成
---
・IDCF クラウドにログインします。
https://account.idcfcloud.com/
![idcf-vpn_1-1_00.png](https://qiita-image-store.s3.amazonaws.com/0/82090/14be8274-6b3c-bc32-5a40-2260daa2f051.png)

<br>
・「コンピューティング」をクリックします。
![idcf-vpn_1-1_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/43a362af-8f77-5bea-0cf8-c800b7c81e52.png)

<br>
・「仮想マシンの作成」をクリックします。（左右どちらでもOKです。）
![idcf-vpn_1-1_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7f671fe5-d7a5-a66c-f352-b7d9ba5762c9.png)

<br>
・以下の情報を入力し「確認画面へ」をクリックします。

```text:今回の構成
マシンタイプ：Light（light.S1）
イメージ：その他（VyOS  1.1.3 64-bit）
ボリューム： -
SSH Key：SSH Key選択（今回は事前に用意していたのを利用）
仮想マシン台数：1
ネットワークインターフェース：radian-network1（今回はデフォルトで用意されているNWを選択）
詳細情報：マシン名１ VPN-ToAWS
```
![idcf-vpn_1-1_03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7e55e559-412e-9d0f-ca87-98c2b62e8e16.png)
![idcf-vpn_1-1_04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ae2d311f-62cb-c581-8ae2-63b7856eb8a0.png)
![idcf-vpn_1-1_05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/be27ebf2-83f0-c239-2d23-3498f472958d.png)
![idcf-vpn_1-1_06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5c87f2c9-e073-7e61-bf83-019821763867.png)
![idcf-vpn_1-1_07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e2c47ce6-7fd8-9fcf-c779-c58193a27ef8.png)
![idcf-vpn_1-1_08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bf3cfa22-1e05-e24d-ce78-1fe15b58cf14.png)
![idcf-vpn_1-1_09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e86ed5a9-f660-a71d-2135-6f32f675215f.png)
![idcf-vpn_1-1_10.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5d6a9ff8-9214-969e-efc1-b6cb8492ac0d.png)

<br>
・内容を確認しOKであれば「作成」をクリックします。
![idcf-vpn_1-1_11.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a64b4ce0-4892-6887-9f29-ecd829841090.png)


<br>
## IPアドレスの設定
---
・「IPアドレス > IPアドレスの取得」をクリックします。
![idcf-vpn_1-2_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/07d6794b-b879-f36a-4785-2e0bb94174a3.png)

<br>
・IPアドレス名の入力、ゾーンとネットワークを選択し「取得する」をクリックします。

```text:内容
IPアドレス名：VPN-IDCF
ゾーン：radian
ネットワーク：radian-network1
```
![idcf-vpn_1-2_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8645e217-5952-842e-1d63-f9654c9d8b69.png)

<br>
・「はい」をクリックします。
![idcf-vpn_1-2_03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/942402b6-bd04-f810-dcc6-97d4cb56b371.png)

<br>
・取得した「IPアドレス」をクリックします。
![idcf-vpn_1-2_04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/70c9d053-4532-86de-192f-f06392d4348a.png)

<br>
・「NAT」をクリックし、先ほど作成した仮想マシンを選択して「有効化」をクリックします。
![idcf-vpn_1-2_05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4d02ded3-ac82-4b4b-ff71-c8aa409886ae.png)

<br>
・「はい」をクリックします。
![idcf-vpn_1-2_06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/820ca11d-cbf1-254a-ca5c-fb2cfab98a17.png)


<br>
## FWの設定
---
・「ファイアウォール」でポートの許可を設定します。

```text:許可内容
[コメント]        [ソースCIDR]  [タイプ]  [ポートレンジ]
NAT Traversal  0.0.0.0/0    UDP      4500
NAT Traversal  0.0.0.0/0    UDP      500
SSH            接続元IP      TCP      22
```
![idcf-vpn_1-3_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2037ff02-908e-afe1-06de-fafa1f985985.png)

ここでSSHを許可していますが、これは作業するための設定です。全て(全４回)が完了したら削除しましょう。

<br>
# おわりに
---
今回は基本的にIDCFクラウドで仮想マシンを作成するための作業と同じです。
VyOSでFWでポート4500(UDP)とポート500(UDP)を許可しているのがVPN特有の設定です。

次回はAWS側でゲートウェイを準備します。

[>> 第２回 AWSとIDCFをVPN接続する - AWS準備編（全４回）](http://qiita.com/kooohei/items/fbc6b32f5a70bf3cfa20)

