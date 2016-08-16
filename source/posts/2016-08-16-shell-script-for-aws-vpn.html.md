---
title: AWSと他の環境をVPNで繋げる際の「VPN接続」の作成をシェルスクリプトにしてみた。
date: 2016-08-16
tags: AWS
author: kohei
ogp:
  og: 'AWSと他の環境をVPN接続する場合、AWS側では「VPN接続」を作成する必要があります。
管理画面からポチポチ操作するのは面倒なのでスクリプトを作成しました。'
---


# はじめに
AWSと他の環境をVPN接続する場合、AWS側では「VPN接続」を作成する必要があります。
管理画面からポチポチ操作するのは面倒なのでスクリプトを作成しました。


<br>
# 流れ
スクリプトの大まかな流れです。

・ 仮想プライベートゲートウェイの作成
・ 仮想プライベートゲートウェイをVPCへattach
・ カスタマーゲートウェイの作成
・ VPN接続の作成



<br>
# スクリプト

以下、スクリプトです。

```bash:create-vpn.sh
#!/bin/bash

# == Check number of arguments. ==================================== #
if [ $# -ne 2 ]; then
  echo "ERROR: Please check the number of arguments."
  echo "   -usage-----------------------------"
  echo "     $0 [VPC ID] [Counter VPN-IP] "
  echo "   -----------------------------------"
  echo ""
  exit 1
fi


# == Set ENV. ====================================================== #
VPC_ID="$1"
PUBLIC_IP="$2"
TAG_VALUE="VPNConnectTo${PUBLIC_IP}"


# == Create VPN ==================================================== #
# Create VPN Gateway
echo "==[VGW]======================================="
echo "Create the VGW."
VGW_ID=`aws ec2 create-vpn-gateway --type ipsec.1 | jq -r .VpnGateway.VpnGatewayId`

echo "VGW_ID:${VGW_ID}"
if [ -n "${VGW_ID}" -a "${VGW_ID}" != "null" ]; then
  echo "SUCCESS: Create the VirtualGateWay."
else
  echo "ERROR: Can't create the VirtualGateWay."
  exit 1
fi
echo ""

echo "Tagged to the VGW."
aws ec2 create-tags --resources ${VGW_ID} --tags Key=Name,Value=${TAG_VALUE}

echo "Attach the VGW to the VPC."
VGW_STAT=`aws ec2 attach-vpn-gateway --vpn-gateway-id ${VGW_ID} --vpc-id ${VPC_ID} | jq -r .VpcAttachment.State`

if [ "${VGW_STAT}" = "attaching" ]; then
  echo "SUCCESS: Attaching the VGW to the VPC."
else
  echo "ERROR: Can't attach the VGW to the VPC."
  exit 1
fi
echo ""
echo ""


# Create CustomerGateway
echo "==[CGW]======================================="
echo "Create the VGW."
CGW_ID=`aws ec2 create-customer-gateway --type ipsec.1 --public-ip ${PUBLIC_IP} --bgp-asn 65000 | jq -r .CustomerGateway.CustomerGatewayId`
 
echo "CGW_ID:${CGW_ID}"
if [ -n "${CGW_ID}" -a "${CGW_ID}" != "null" ]; then
  echo "SUCCESS: Create the CustomerGateWay."
else
  echo "ERROR: Can't create the CustomerGateWay."
  exit 1
fi
echo ""

echo "Tagged to the CGW."
aws ec2 create-tags --resources ${CGW_ID} --tags Key=Name,Value=${TAG_VALUE}
echo ""
echo ""


# Create VPN Connection
echo "==[VPN]======================================="
echo "Create the VPN."
VPN_ID=`aws ec2 create-vpn-connection --type ipsec.1 --customer-gateway-id ${CGW_ID} --vpn-gateway-id ${VGW_ID} | jq -r .VpnConnection.VpnConnectionId`

echo "VPN_ID:${VPN_ID}"
if [ -n "${VPN_ID}" -a "${VPN_ID}" != "null" ]; then
  echo "SUCCESS: Create the VPN Connection."
else
  echo "ERROR: Can't create the VPN Connection."
  exit 1
fi
echo ""

echo "Tagged to the VPN."
aws ec2 create-tags --resources ${VPN_ID} --tags Key=Name,Value=${TAG_VALUE}

echo ""
echo ""

echo "--------------------------------------------------"
echo "COMPLETED: All of the task has been completed."

exit 0
```


<br>
# 実行
コマンド実行例です。

```bash:実行例
$ sh create-vpn.sh vpc-1e1ed97b 210.129.19.42
```


<br>
# 結果
以下、管理画面から見た作成結果です。

・仮想プライベートゲートウェイ
![idcf-vpn_scrip03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/47834725-e13f-8cf9-d3a3-33f1cf51da26.png)

・カスタマーゲートウェイ
![idcf-vpn_scrip02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ee9a3f30-87a6-a69d-c6ad-6069eeb8928f.png)

・VPN接続
![idcf-vpn_scrip01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/39290a24-e4ab-22dd-1d50-ec27b4183345.png)


<br>
# おわりに
スクリプト実行後、「VPN接続」から「設定のダウンロード」をしてそのコンフィグを対向となるルーターに流し込めばOKです。

