---
title: [ActiveDirectory]ADアカウントユーザにデフォルトでローカルユーザの管理権限を設定する方法
date: 2017-05-22
tags: ActiveDirectory,
author: ayako
ogp:
  og:
    description: ''
---

#はじめに
---

ADで作成されたアカウントユーザでクライアントPCにログインすると、通常は管理権限なしの一般ユーザとなっています。

一般ユーザではアプリケーションの追加ができず、PCに変更することが一苦労。
管理権限を追加するため、ローカルの管理ユーザでログインし、ADアカウントユーザへ管理権限を付与する。
結構めんどうな作業ですよね？

初回ログイン時から自動的にローカル管理権限がついていればとっても楽！
今回はこの部分をADのOGP設定で解決します！

環境：
Amazon Directory Service MicrosoftAD

#グループポリシーの管理で制限されたグループの設定を行う
---


まず、スタートボタン　＞　管理ツール　＞　グループポリシーの管理　を開きます。
管理ツールにグループポリシーの管理が表示されない場合は、

サーバマネージャ　＞　機能　＞　機能の追加　＞グループポリシーの管理をチェック　＞　インストール
で機能の追加をおこなってください。

グループポリシーの管理を開いたら、【Default Domain Policy】配下の【Computer】を右クリック。
【このドメインにGPOを作成し.....】をクリック。


![GPO0.png](https://qiita-image-store.s3.amazonaws.com/0/174392/415de7d7-0f22-877c-7cf9-2e6d07a8c627.png)

任意のGPO名を入力。ここではtest00としています。

![GPO01.png](https://qiita-image-store.s3.amazonaws.com/0/174392/75f512d3-a9b0-1cc6-d337-4cae2cebe1e1.png)

作成したGPOを右クリックして編集。

![GPO03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/2d27230a-3acb-c2f8-b2f7-7fc9e1af156d.png)

Windowsの設定　＞　セキュリティの設定　＞　制限されたグループ　

![GPO04.png](https://qiita-image-store.s3.amazonaws.com/0/174392/a12141eb-f0b8-9a61-6742-0a643461c878.png)

制限されたグループを右クリックし、グループの追加

![GPO05.png](https://qiita-image-store.s3.amazonaws.com/0/174392/5b57be17-d388-7e19-25bb-e32a29a710fc.png)

参照をクリックしたら、【Administrator】を入力し、選択。選択したらOK。

![スクリーンショット 2017-05-22 11.34.53.png](https://qiita-image-store.s3.amazonaws.com/0/174392/d4ed8f7f-60ab-ca39-e0ff-f6b47337932f.png)

その後、プロパティが表示されるので、上段のこのグループのメンバーに【Domain Users】を追加。

![GPO06.png](https://qiita-image-store.s3.amazonaws.com/0/174392/59a0c6fb-9d5c-e642-170c-78dd6c0ca2cf.png)

続いて同じように、【Domain Users】側からも【Administrator】への所属をさせます。
今回は下段に【Administrator】を追加。

![GPO07.png](https://qiita-image-store.s3.amazonaws.com/0/174392/207fc68a-3296-cee0-0b90-3ae528b92b42.png)

以上で、GPOの設定は完了です。

#設定したGPOを即時反映させるには

クライアントに反映されるまで時間がかかるよようなので、強制的に有効化を行いたい場合は、コマンドで実行。

```
gpupdate /force
```

#設定内容の反映を確認
---


クライアントPCを再起動させて、ローカルアカウントに権限が追加されているか確認します。

コントロールパネル　＞　ユーザアカウント　＞　ユーザアカウントの管理　＞　詳細設定タブ

![スクリーンショット 2017-05-22 11.56.18.png](https://qiita-image-store.s3.amazonaws.com/0/174392/650005ef-a18d-36de-6da0-817e05297913.png)

グループからAdministratorの詳細を確認します。

![スクリーンショット 2017-05-22 11.56.28.png](https://qiita-image-store.s3.amazonaws.com/0/174392/30004e95-c996-9977-fff2-7a3cc7d23551.png)

【Domain Users】がグループに追加されていることが確認できました！

![権限確認.png](https://qiita-image-store.s3.amazonaws.com/0/174392/3743a1b6-973f-e244-53da-901dd6400bd5.png)

これで、ADで追加したユーザがクライアントPCに管理権限が付与された状態でログインすることができるようになりました。
