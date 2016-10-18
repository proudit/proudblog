---
title: AWS EC2で長いリソースIDを使用する。
date: 2016-10-18
tags: AWS,EC2
author: kohei
ogp:
  og: 'DNSを他から**Route53**へ移行するときどうしてますか？
ゾーン情報があればGUIから「Import Zone File」でコピペして完了ですが、いちいち管理コンソールへログインしてHosted Zoneを作成して。。。ttl部分を避けてコピペしないと行けなかったり、複数ドメインあったら一つ一つファイル開いてコピペしないとだし>。。。って正直面倒で仕方ないです。。。'
---

# はじめに
去年の11月に告知された長いリソースIDの利用ですが、2016年12月上旬までが移行期間となります。
何もしなくても最終期限(2016年12月上旬)にはEC2のインスタンス、リザベーション、ボリューム、スナップショットの4項目で長いリソースID(8文字→17文字)へと自動的に切り替わります。
この設定はこれから作り出される新規のリソースに対しのアクションで、既存のリソースは変更されません。ただ、既存のインスタンスに対してスナップショットなどを新規作成した場合、そのリソースIDは長いリソースIDとなります。
ということで、もうあと２ヶ月以内には期限が来てしまいますが「コンソール」と「コマンドライン」の２種類の移行方法を試してみました。


<br>
# コンソールから設定
コンソールへログインしたら「サービス」 > 「EC2」 > 「リソースIDの長さの管理」をクリックします。

![longid01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e5cfbb3b-2491-387f-2565-1c4012d33f1b.png)

「リソースIDの長さの管理」の画面が開かれるのでここで設定したいIDタイプのチェックボックスにチェックを入れます。

![longid02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/48424ecc-942c-3688-371a-17e0cf91bfac.png)

以上で完了です。


<br>
# コマンドで設定
aws-cliを利用して設定を行います。

<br>
## 事前ステータス確認
まずは現状のステータスを確認しておきます。

```bash:ステータス確認
$ aws ec2 describe-id-format_
{
    "Statuses": [
        {
            "UseLongIds": false, 
            "Resource": "reservation"
        }, 
        {
            "UseLongIds": false, 
            "Resource": "instance"
        }, 
        {
            "UseLongIds": false, 
            "Resource": "volume"
        }, 
        {
            "UseLongIds": false, 
            "Resource": "snapshot"
        }
    ]
}
```

instance、reservation、volume、snapshotの４項目で「false」となっています。


<br>
## 長いリソースID
それでは切り替えを行います。

- reservation

```bash:reservation
$ aws ec2 modify-id-format --resource reservation --use-long-ids
```

- instance

```bash:instance
$ aws ec2 modify-id-format --resource instance --use-long-ids
```

- volume

```bash:volume
$ aws ec2 modify-id-format --resource volume --use-long-ids
```

- snapshot

```bash:snapshot
$ aws ec2 modify-id-format --resource snapshot --use-long-ids
```


<br>
# 切り替え後ステータス確認
再度ステータスを確認すると「true」となっているのが確認できます。

```bash:ステータス確認
$ aws ec2 describe-id-format
{
    "Statuses": [
        {
            "UseLongIds": true, 
            "Resource": "reservation"
        }, 
        {
            "UseLongIds": true, 
            "Resource": "instance"
        }, 
        {
            "UseLongIds": true, 
            "Resource": "volume"
        }, 
        {
            "UseLongIds": true, 
            "Resource": "snapshot"
        }
    ]
}
```

切り替えが完了しているのが確認できました。


<br>
# 短いリソースIDへの切り戻し
長いリソースIDへ切り替えたても短いリソースIDへ切り戻すことも可能です。

- reservation

```bash:reservation
$ aws ec2 modify-id-format --resource reservation --no-use-long-ids
```

- instance

```bash:instance
$ aws ec2 modify-id-format --resource instance --no-use-long-ids
```

- volume

```bash:volume
$ aws ec2 modify-id-format --resource volume --no-use-long-ids
```

- snapshot

```bash:snapshot
$ aws ec2 modify-id-format --resource snapshot --no-use-long-ids
```


<br>
# 切り戻し後ステータス確認
切り戻しも確認してみます。ステータスが「false」になっていれば完了です。

```bash:ステータス確認
$ aws ec2 describe-id-format
{
    "Statuses": [
        {
            "UseLongIds": false, 
            "Resource": "reservation"
        }, 
        {
            "UseLongIds": false, 
            "Resource": "instance"
        }, 
        {
            "UseLongIds": false, 
            "Resource": "volume"
        }, 
        {
            "UseLongIds": false, 
            "Resource": "snapshot"
        }
    ]
}
```

以上で切り戻しが完了しました。


<br>
# おわりに
もう今更の内容ですが、自動切り替え前にはどんなリスクがあるかは事前に切り替えて試してみた方が良いと思います。

