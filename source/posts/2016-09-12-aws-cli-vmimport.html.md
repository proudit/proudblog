---
title: AWS CLIでVMwareイメージをインポート 
date: 2016-09-12
tags: aws-cli
author: toguma
ogp:
  og: 'AWS CLIでVMwareイメージをインポート | AWS公式ページや他同内容のqiitaとやっていることは一緒だと面白くないので、
所属しているJAWS-CLI支部のハンズオン形式同様、全てコマンドライン＝コピー＆ペーストで完結出来るようにしてみました。'
---

業務上、VM(vSphere5)をAWS EC2にインポートする必要があったので、その際の記録。
方式はImportImage。

AWS公式ページや他同内容のqiitaとやっていることは一緒だと面白くないので、
所属しているJAWS-CLI支部のハンズオン形式同様、全てコマンドライン＝コピー＆ペーストで完結出来るようにしてみました。
（VMイメージ取り出しでvmwareClient＝GUI利用しているのはご容赦くださいw）

---

# 0. 移設対象VMの用意

対象VM

- vSphere5.01 hypervisor (無償ライセンス版）
- CentOS6.5(64bit)
- redmien/gitlab用サーバ (要はrubyアプリ)

ちなみに、移行対象VMのNW/アカウント周りの状況も記載

- iptablesは停止（もともと使用していなかった）
- eth0利用、非DHCP(固定IP設定）
- rootログイン不可
- sudo可能な管理用IDにはSSH+公開鍵方式によりログイン可能。

<br>
特に意識してなかったが簡単なスタンドアロンサーバであった為か、
偶然以下の事前準備構成にマッチしてた模様。
<br>
[VM Import/Export Prerequisites](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/VMImportPrerequisites.html)

<br>
<br>

## 0-1 VMDKの取得


vmdkファイルが正常に取り出せれば方法は特に問わないが、今回は、vclientから、OVFエクスポートした上で、vmdkを取得。

ちなみに、当方の環境はAWS側の管理用windowsサーバ内のvSphereClientでvSphereへ接続し、OVFテンプレート形式でエクスポート。

![スクリーンショット 2016-08-25 16.59.09.png](https://qiita-image-store.s3.amazonaws.com/0/89940/db266118-45fc-6927-5ed9-6070fa31f677.png)

<br>
<br>
エクスポートは容量、環境(vSphereサーバ〜Clientとの回線状況、ディスク速度など）によって時間が変わる。参考までに筆者の環境では実質利用領域4GBのOSで約30分。

完了後、VMDKファイルが正常に取得できていることを確認。
（最終的に利用するのはVMDKファイル）

<br>
<br>
<img width="699" alt="スクリーンショット 2016-09-11 23.54.00.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/1abb4b85-dc5d-1b76-6380-9b1c6421a6cb.png">

<br>
<br>

このVMDKファイルをvSphereClient端末から、直接対象S3バケットへUPするか、
作業端末から参照可能な様に準備する。


**以下例は、vmdkファイルを作業端末(Mac)に保管の上、CLIにて実施。**


<br>
<br>

# 前提条件

---

<br>

###必要IAM権限
IAM、EC2、S3へのフルアクセス権限

###ローカル環境

- AWS CLIバージョン　1.10.14
- Mac OSX EL Capitan

<br>
# 1. S3へvmdkファイルをUP

---

## 1-1 変数定義

```:変数定義
VMIMPORT_BUCKET="任意のバケット名"
VMDK_FILE_NAME="s3へUPするvmdkファイル名"
```

```:変数確認
cat << EXT
      VMIMPORT_BUCKET=${VMIMPORT_BUCKET}
      VMDK_FILE_NAME=${VMDK_FILE_NAME}
EXT
```

## 1-2 バケット作成

```:バケット作成(aws-cli)
aws s3 mb s3://${VMIMPORT_BUCKET}
```

## 1-3 バケットへUP

VMDKファイルがカレントディレクトリにあることを確認

```:ファイル確認
ls ${VMDK_FILE_NAME}
```

S3へUP(aws-cli)

```:S3へUP(aws-cli)
aws s3 cp ${VMDK_FILE_NAME} s3://${VMIMPORT_BUCKET}
```

<br>
<br>


# 2. IAM準備
---

<br>
1. AWS内のVMコンバーターへの権限移譲用のrole作成。(create-role + assumeRole)
2. 上記roleへS3バケット権限の割り当て(put-role-policy)

1,2の作業にはIAM操作可能な権限が必要
3の作業にはIAM権限は不要だが、指定のS3/EC2操作の権限が必要。
今回は単純化の為に、全てを同一IAMユーザにて実施

<br>
## 2-1 AWSコンバーターへ権限移譲用のrole作成
 policyを準備
 
変数定義

```:変数定義
TRUST_POLICY_JSON="trust-policy.json" \
      && echo ${TRUST_POLICY_JSON}
```

policy用json作成


```:policy用json作成
cat << EOF > ${TRUST_POLICY_JSON}
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:ExternalId": "vmimport"
            }
         }
      }
   ]
}

EOF

cat ${TRUST_POLICY_JSON}
```

jsonフォーマットを確認

```コマンド
jsonlint -q ${TRUST_POLICY_JSON}
```

権限移譲ロール(= ロール名 vmimport)の作成

```aws-cli
aws iam create-role --role-name vmimport --assume-role-policy-document file://${TRUST_POLICY_JSON}
```

実行結果例

```:実行結果例
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17", 
            "Statement": [
                {
                    "Action": "sts:AssumeRole", 
                    "Effect": "Allow", 
                    "Condition": {
                        "StringEquals": {
                            "sts:ExternalId": "vmimport"
                        }
                    }, 
                    "Principal": {
                        "Service": "vmie.amazonaws.com"
                    }
                }
            ]
        }, 
        "RoleId": "AROAJZ2LW4SPAT7XXXXXXX", 
        "CreateDate": "2016-09-11T15:45:23.690Z", 
        "RoleName": "vmimport", 
        "Path": "/", 
        "Arn": "arn:aws:iam::XXXXXXXXXXXXXX:role/vmimport"
    }
}
```

<br>
## 2-2 移譲用ロールへの権限割り当て
policyを準備

```:変数定義
ROLE_POLICY_JSON="role-policy.json" \
      && echo ${ROLE_POLICY_JSON}
```

変数確認


```:変数確認
cat << ETX

          ROLE_POLICY_JSON: ${ROLE_POLICY_JSON}
          VMIMPORT_BUCKET: ${VMIMPORT_BUCKET}

ETX
```

policy用json作成


```:policy用json作成
cat << EOF > ${ROLE_POLICY_JSON}
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource": [
            "arn:aws:s3:::${VMIMPORT_BUCKET}"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetObject"
         ],
         "Resource": [
            "arn:aws:s3:::${VMIMPORT_BUCKET}/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
EOF

cat ${ROLE_POLICY_JSON}
```

jsonフォーマットを確認

```コマンド
jsonlint -q ${ROLE_POLICY_JSON}
```

vmimportロールへ割り当て

```:aws-cli
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://${ROLE_POLICY_JSON}
```

<br>
<br>
ここまでで、
1. AWS内のVMコンバーターへの権限移譲用のrole作成。(create-role + assumeRole)
2. 上記roleへS3バケット権限の割り当て(put-role-policy)
の作業が完了。


<br>
<br>

# 3 VMイメージのインポート

---

<br>
ようやく準備が整ったので、実際にVMをインポートしていきます。

<br>
## 3-1 インポート用json準備

変数定義

```:変数定義
VMIMPORT_JSON="vmimport.json" \
      && echo ${VMIMPORT_JSON}
VMIMPORT_DESC="VM Import by AWS CLI" \
      && echo ${VMIMPORT_DESC}
```

変数確認

```:変数確認
cat << EXT
      VMIMPORT_JSON=${VMIMPORT_JSON}
      VMIMPORT_DESC=${VMIMPORT_DESC}
      VMIMPORT_BUCKET=${VMIMPORT_BUCKET}
      VMDK_FILE_NAME=${VMDK_FILE_NAME}
EXT
```

インポート指示用Jsonファイル作成

```:json作成
cat << EOF > ${VMIMPORT_JSON}
{
	"Description": "${VMIMPORT_DESC}",
	"DiskContainers": [
		{
		"Description": "${VMIMPORT_DESC}",
		"UserBucket": {
			"S3Bucket": "${VMIMPORT_BUCKET}",
			"S3Key" : "${VMDK_FILE_NAME}"
			}
		}
	]
}
EOF

cat ${VMIMPORT_JSON}
```

jsonフォーマットを確認

```コマンド
jsonlint -q ${VMIMPORT_JSON}
```

<br>
## 3-2 インポート実行

VMイメージのイメージインポート開始

```:インポート実行
aws ec2 import-image --cli-input-json file://${VMIMPORT_JSON}
```

実行結果例


```:実行結果例
{
    "Status": "active", 
    "Description": "VM Import by AWS CLI", 
    "Progress": "2", 
    "SnapshotDetails": [
        {
            "UserBucket": {
                "S3Bucket": "cli-vmimport", 
                "S3Key": "centos64-disk1.vmdk"
            }, 
            "DiskImageSize": 0.0
        }
    ], 
    "StatusMessage": "pending", 
    "ImportTaskId": "import-ami-ffmjni7l"
}
```

<br>
## 3-3 インポート結果確認

進捗確認コマンド

```:進捗確認
aws ec2 describe-import-image-tasks 
```

進捗例(コンバート中)


```:進捗例(コンバート中)
{
    "ImportImageTasks": [
        {
            "Status": "active", 
            "Description": "VM Import by AWS CLI", 
            "Progress": "28", 
〜略〜
            "StatusMessage": "converting", 
            "ImportTaskId": "import-ami-ffmjni7l"
        }
    ]
}
```

進捗例（アップデート中）

```:進捗例（アップデート中）
{
    "ImportImageTasks": [
        {
            "Status": "active", 
            "Description": "VM Import by AWS CLI", 
            "Progress": "41", 
〜略〜
            "StatusMessage": "updating", 
            "ImportTaskId": "import-ami-ffmjni7l"
        }
    ]
}
```

進捗例（ブート中）

```:進捗例（ブート中）
{
    "ImportImageTasks": [
        {
            "Status": "active", 
            "Description": "VM Import by AWS CLI", 
            "Progress": "59", 
〜略〜
            "StatusMessage": "booting", 
            "ImportTaskId": "import-ami-ffmjni7l"
        }
    ]
}
```

進捗例（イメージ化中）

```:進捗例（イメージ化中）
{
    "ImportImageTasks": [
        {
            "Status": "active", 
            "Description": "VM Import by AWS CLI", 
            "Progress": "76", 
〜略〜
            "StatusMessage": "preparing ami", 
            "ImportTaskId": "import-ami-ffmjni7l"
        }
    ]
}
```

完了


```:完了
{
    "ImportImageTasks": [
        {
            "Status": "completed", 
            "LicenseType": "BYOL", 
            "Description": "VM Import by AWS CLI", 
            "ImageId": "ami-3fea3d5e", 
            "Platform": "Linux", 
            "Architecture": "x86_64", 
            "SnapshotDetails": [
                {
                    "DeviceName": "/dev/sda1", 
                    "Description": "VM Import by AWS CLI", 
                    "Format": "VMDK", 
                    "DiskImageSize": 3317887488.0, 
                    "SnapshotId": "snap-3ca55e00", 
                    "UserBucket": {
                        "S3Bucket": "cli-vmimport", 
                        "S3Key": "centos64-disk1.vmdk"
                    }
                }
            ], 
            "ImportTaskId": "import-ami-ffmjni7l"
        }
    ]
}
```

<br>
## 3-4 イメージ確認

<br>
完了するとSnapshotに以下のようにインポートしたイメージが作成されている。

<br>
<img width="1042" alt="スクリーンショット 2016-09-12 01.38.43.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/ef25e424-32f5-cc96-1260-2b5bae9f6f02.png">

<br>
あとは、このスナップショットからAMIを作成し、任意のインスタンスとして立ち上げればOK。

もし、起動してもログインできない場合は、セキュリティグループ、ログインキーが正しいかどうかを確認すること。
それでもダメな場合は、元々のVMイメージが、インポート条件を満たしていない可能性がありますので、以下条件と照らし合わせてみてください。

<br>
[VM Import/Export Prerequisites](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/VMImportPrerequisites.html)


<br>
以上です。
この記事が皆様のお役に立てれば幸いです。

