---
title: "AWS Step Functions を使ってワークフロー処理を行う。"
date: 2018-02-06
tags: AWS, Amazon Step Functions
author: kohei
ogp:
  og: 'Amazon Web Services ブログでAWS Step Functions – ビジュアルワークフローを使ったアプリケーションのビルドと配布というのがあったので、AWS Step Functionsを使ってビジュアルワークフローを作成してみました。'
---

# はじめに
 **Amazon Web Services ブログ** で [AWS Step Functions – ビジュアルワークフローを使ったアプリケーションのビルドと配布](https://aws.amazon.com/jp/blogs/news/new-aws-step-functions-build-distributed-applications-using-visual-workflows/)というのがあったので、 [AWS Step Functions](https://aws.amazon.com/jp/step-functions/) を使ってビジュアルワークフローを作成してみました。


<br>
# AWS Step Functions とは？
視覚的なワークフローを使って、分散アプリケーションやマイクロサービスのコンポーネントを調整できるサービスです。


<br>
# 料金は？
ワークフローの状態遷移に対して料金がかかります。
とは言っても毎月4,000回までが無料枠なので試しに使ってみる分には気にする必要なさそうです。
しかもこの無料枠は登録して12ヶ月間の期間限定ではなく、無期限とのことです。
ただ、追加料金としてデータ転送やLambda、EC2などの使用料は別途かかります。
そこらへんについては以下を参照ください。
・[AWS Step Functions 料金](https://aws.amazon.com/jp/step-functions/pricing/)


<br>
# ビジュアルワークフローの作成

## Lambdaの準備
まずは Step Functions で利用するLambda関数を準備します。
今回はサンプルのHello Worldを使うことにします。
![スクリーンショット 2018-02-01 14.38.04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6f03db6a-5d69-d385-93d2-04d8fcdbbe16.png)

関数の作成が完了すると右上にARNが表示されます。これのARNはこれから作成する Step Functions で利用します。
![スクリーンショット 2018-02-01 14.38.58.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b164717a-1ba2-a23c-c38c-c98bf8eb7d2a.png)

<br>
## ステートマシンの作成
それでは Step Functions でステートマシンを作成したいと思います。
まだ１つも作成したことない場合は、以下のような画面が表示されると思うので「今すぐ始める」をクリックして始めます。
![スクリーンショット 2018-02-01 14.40.02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ad13e013-7224-94d4-dbe4-837de935ce1a.png)

すると**ステートマシンの作成**をどうするか選択が求められます。今回はテンプレートをベースにするので、**「テンプレート」**を選択し、**テンプレートの選択**では**「Hello world」**を選びます。
![スクリーンショット 2018-02-01 14.41.16.png](https://qiita-image-store.s3.amazonaws.com/0/82090/90039a63-10de-61ff-d3f4-61bebf52bfa7.png)

<br>
## ステートマシンのコードとビジュアルワークフロー
ステートマシンの名前に「MyStateMachine」(任意)を入力します。また、実行するためのIAMロールはデフォルトのままです。
![スクリーンショット 2018-02-01 14.44.06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/22d4938e-9c6d-4440-3989-bb0c2bbb6fd0.png)

コードの部分は以下をまずコピペします。

```json:コード
{
  "Comment": "A simple example of the Steps language using an AWS Lambda Function",
  "StartAt": "Hello",

  "States": {
    "Hello": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-1:99999999999:function:HelloWord_Step",
      "Next": "Parallel"
    },

    "Parallel": {
      "Type": "Parallel",
      "Next": "Goodbye",
      "Branches": [
        {
          "StartAt": "p1",
          "States": {
            "p1": {
                  "Type": "Task",
                  "Resource": "arn:aws:lambda:eu-west-1:9999999999:function:HelloWord_Step",
              "End": true
            }
          }
        },

        {
          "StartAt": "p2",
          "States": {
            "p2": {
                  "Type": "Task",
                  "Resource": "arn:aws:lambda:eu-west-1:99999999999:function:HelloWord_Step",
              "End": true
            }
          }
        }
      ]
    },

    "Goodbye": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-1:99999999999:function:HelloWord_Step",
      "End": true
    }
  }
}
```

コピペしたら以下のように`Resource`の部分をクリックします。すると利用できるLambda関数が表示されるので、先ほど作成したLambda関数へ変更します。
今回の場合、`Resource`箇所は4つ存在するので全部変更しましょう。

![スクリーンショット 2018-02-01 14.44.49.png](https://qiita-image-store.s3.amazonaws.com/0/82090/532685b5-6109-5cb9-98f1-5b5fff028a91.png)

変更が終わったらビジュアルワークフローの文字の横にある更新マークをクリックします。
すると先ほどコピペしたコードの内容がビジュアルフローとして反映されます。

![スクリーンショット 2018-02-01 21.29.14.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b5932b45-42f4-6d61-2a8b-7d528ac85cce.png)

ワークフローの設定が終わったら**「ステートマシンの作成」**をクリックします。

![スクリーンショット 2018-02-01 14.45.43.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f52b3ab4-5b90-4f1f-f1cc-b82e5440fc9d.png)

以上で完了です。

<br>
## ステートマシンの実行
ワークフローの設定が完了したので、**「新しい実行」**からステートマシンを実行します。
![スクリーンショット 2018-02-01 14.46.00.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4f0d0b1d-87ab-b08f-6821-c65bbbb94dd0.png)

するとポップアップが出るのでそのまま**「実行の開始」**をクリックします。
![スクリーンショット 2018-02-01 14.47.01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c61f4eb2-31b0-9808-e458-534286de211d.png)

実行IDの横がぐるぐる更新マークから緑チェックマークに変わったら成功です。

![スクリーンショット 2018-02-01 14.47.16.png](https://qiita-image-store.s3.amazonaws.com/0/82090/60ad85ad-f366-581a-7714-5c6c91f5d4cb.png)

**実行の詳細**にある**入力**と**出力**のタブをクリックするとそれぞれのデータが確認できます。
![スクリーンショット 2018-02-01 22.06.15.png](https://qiita-image-store.s3.amazonaws.com/0/82090/01fcbf8a-c564-36e0-0d07-519865edef26.png)


<br>
# ビジュアルワークフローについて
確認したいステップをクリックすると右の**ステップ詳細**のところでリソース情報や入出力値を確認することができます。

![スクリーンショット 2018-02-01 15.11.01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b2c91e88-9ce9-ed19-4e4b-e567b0d08a76.png)

また、パラレル処理などは外枠をクリックすると処理全体の詳細を確認することができます。

![スクリーンショット 2018-02-01 15.11.48.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d7156d2c-b01f-fd4b-2ee1-6820bd540e42.png)

ここでの入力は前のステップ(Hello)で実行された出力結果です。

![スクリーンショット 2018-02-01 15.11.57.png](https://qiita-image-store.s3.amazonaws.com/0/82090/97bbc64c-1956-5645-710a-bd8a06daf04c.png)

また、出力ではパラレル処理されたp1とp2の両ステップを合わせた値となります。

![スクリーンショット 2018-02-01 15.12.03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d2e2e8f0-7304-dbc1-cb99-cc912915e1a4.png)

<br>
## Step Console
AWS Step Functions は各ステップに関する情報を記録しています。内容は、このStep Console で確認することができます。

![スクリーンショット 2018-02-02 0.54.50.png](https://qiita-image-store.s3.amazonaws.com/0/82090/65882678-41eb-b2ad-14d1-2ee3d09232e5.png)


<br>
# おわりに
AWS Step Functions を使うことで、複数ステップからなるアプリケーションをシンプルに構築できます。また、視覚化されたフローによって各ステップのステータスや状態遷移を容易に確認できたり、もしエラーが発生した場合は再試行をしてくれたりととても使い勝手が良さそうです。

