---
title: "Redmineにプラグインを追加する。"
date: 2017-08-22
tags: redmine
author: kohei
ogp:
  og: '先日、Redmineのプラグイン追加作業を行ったので、その内容についてまとめておきます'
---

# はじめに
先日、Redmineのプラグイン追加作業を行ったので、その内容についてまとめておきます。

<br>
# 作業
具体的な方がイメージしやすいと思うので、今回は [**clipboard_image_paste**](https://github.com/peclik/clipboard_image_paste) というプラグインの追加を例として行いたいと思います。

まずは作業ディレクトリへ移動です。既にインストールしてある *redmine* のディレクトリ配下に *plugins* というディレクトリがあるはずなのでそこへまず移動します。

```bash:ディレクトリ移動
$ cd /var/lib/redmine/plugins
```

移動したら、今回のプラグインは *git* のリポジトリに存在するので `git clone` でダウンロードします。

```bash:ダウンロード
$ git clone https://github.com/peclik/clipboard_image_paste.git
Cloning into 'clipboard_image_paste'...
remote: Counting objects: 456, done.
remote: Total 456 (delta 0), reused 0 (delta 0), pack-reused 456
Receiving objects: 100% (456/456), 262.35 KiB | 0 bytes/s, done.
Resolving deltas: 100% (168/168), done.
Checking connectivity... done.
```

ダウンロードしたらその所有者をredmineのディレクトリと同じにしておきましょう。
デフォルトは *redmine* になってるかなとも思いますが、場合によったら *apache* などになってる可能性もあるのでそこは確認して変更してください。

```bash:所有者変更
$ chown -R redmine.redmine clipboard_image_paste
```

それではいよいよインストールです。と言っても以下の一行を実行するだけです。

```bash:インストール
$ bundle exec rake redmine:plugins:migrate RAILS_ENV=production
(in /var/lib/redmine)
Migrating clipboard_image_paste (Clipboard image paste)...
Migrating redmine_absolute_dates (Redmine Absolute Dates plugin)...
Migrating redmine_banner (Redmine Banner plugin)...
== 1 CreateBanners: migrating =================================================
-- create_table(:banners)
   -> 0.0749s
== 1 CreateBanners: migrated (0.0751s) ========================================

== 2 RenameColumnType: migrating ==============================================
-- rename_column(:banners, :type, :style)
   -> 0.0544s
== 2 RenameColumnType: migrated (0.0547s) =====================================

== 3 AddDisplayPartToBanners: migrating =======================================
-- add_column(:banners, :display_part, :string, {:default=>"all", :null=>false})
   -> 0.0397s
== 3 AddDisplayPartToBanners: migrated (0.0399s) ==============================

== 4 ChangeColumnStyle: migrating =============================================
-- change_column(:banners, :style, :string, {:default=>"info", :null=>false})
   -> 0.0245s
== 4 ChangeColumnStyle: migrated (0.0247s) ====================================

== 5 ChangeColumnBannerDescription: migrating =================================
-- change_column(:banners, :banner_description, :text)
   -> 0.0382s
== 5 ChangeColumnBannerDescription: migrated (0.0384s) ========================
```

特に問題なくインストールができたら、あとは apache再起動 をするだけです。

```bash:apache再起動
$ sudo service httpd restart
```

<br>
# 確認
作業が正常に完了すると **[管理] > [プラグイン]** の項目に先ほど追加したプラグインが表示されます。

![スクリーンショット 2017-08-13 15.03.27.png](https://qiita-image-store.s3.amazonaws.com/0/82090/adf50906-46f5-6564-058f-3328b08c3e21.png)


# おわりに
今回はプラグインのダウンロードに`git clone`を使いましたが、そのディレクトリに配置できればどんな方法でも構いません。
ですが、`git`を使った方がアップデードした際に`pull`で簡単に取得できるので便利なので利用できるならおすすめです。

