---
title: "aws-cli で CloudFront の設定を変更する。"
date: 2018-04-27
tags: AWS, aws-cli, CloudFront
author: kohei
ogp:
  og: 'CloudFrontは設定変更を誤った場合の影響が大きいです。そのためより安全に正確に変更作業を行うのにaws-cliを使うのが良いと思いました。'
---

# はじめに
CloudFrontは設定変更を誤った場合の影響が大きいです。そのためより安全に正確に変更作業を行うのにaws-cliを使うのが良いと思いました。


<br>
# 設定の確認
まず今回は通信用にサポートされる _SSL/TLS_ プロトコルの変更を行うことにします。

ディストリビューションで現在設定されている内容を確認するには _cloudfront_ の _get-distribution-config_ コマンドで確認できます。
ただ、そのまま出力されると内容が多くて分かりにくいので、TLSの部分だけ抜き出します。

```bash:TLS確認
$ aws cloudfront get-distribution-config --id "xxxxxxxxxxxxx" | jq '.["DistributionConfig"]["ViewerCertificate"]["MinimumProtocolVersion"]'
"TLSv1"
```

現在の設定は _TLSv1_ が設定されています。


<br>
# 設定変更
それでは設定変更を行います。
まずは現在の設定状況を管理コンソールからも確認して見ます。

![スクリーンショット 2018-03-25 15.35.58.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1df97fd7-c5e8-d1b3-a92c-708e1ca5a242.png)

今回は赤枠の _TLSv1_ を _TLSv1.1_2016_ へ切り替えたいと思います。
まず、先ほどの _get-distribution-config_ で表示される _DistributionConfig_ の部分をテキストへ出力します。

```bash:dist.conf
$ aws cloudfront get-distribution-config --id "xxxxxxxxxxxxx" | jq '.DistributionConfig' > dist.conf
```

出力したらそのファイルを開き _TLSv1_ の部分を _TLSv1.1_2016_ へ変更します。
サポートされる _SSL/TLS_ プロトコル は[こちら](https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html)で確認してください。

```bash:変更確認
$ cat dist.conf | jq '.["ViewerCertificate"]["MinimumProtocolVersion"]'
"TLSv1"
```

次に _ETag_ を取得します。このETagの取得が今回のポイントです。

```bash:ETag
$ aws cloudfront get-distribution-config --id "xxxxxxxxxxxxx" --profile proudit | jq '.ETag'
"EZLFL1SIXPXTL"
```

この _ETag_ がマッチしないと設定の変更ができません。
それでは設定を更新します。

```bash:update-distribution
$ aws cloudfront update-distribution --id "xxxxxxxxxxxxx" --distribution-config file://dist.conf --if-match EZLFL1SIXPXTL
```

それでは _Security Policy_ をもう一度確認して見ます。

```bash:確認
$ aws cloudfront get-distribution-config --id "xxxxxxxxxxxxx" | jq '.["DistributionConfig"]["ViewerCertificate"]["MinimumProtocolVersion"]'
"TLSv1.1_2016"
```

管理コンソールからも変更されていることが確認ができました。

![スクリーンショット 2018-03-25 15.41.16.png](https://qiita-image-store.s3.amazonaws.com/0/82090/754f824e-6499-1970-2e9a-43a3a3f5fffb.png)


<br>
# おわりに
管理コンソールでの設定変更は誤操作を誘発しやすくなります。コマンドの場合、作業ログの保存はもちろん、設定情報の変更前と変更後の差分をdiffなどで確認した上で更新できるのオススメです。

