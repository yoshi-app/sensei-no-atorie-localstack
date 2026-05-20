#!/bin/bash

#エイリアス設定（~/.bashrcに追記済み・初回のみ実行）
# echo "alias awslocal='aws --profile localstack --endpoint-url=http://localhost:4566'" >> ~/.bashrc && source ~/.bashrc
# 以降のコマンドはエイリアスなしのフルコマンドで記録

#VPC作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-vpc --cidr-block 10.0.0.0/16

#パブリックサブネット作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-subnet --vpc-id vpc-59c000a31a31857fb --cidr-block 10.0.1.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=sensei-public-subnet}]'

#プライベートサブネット作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-subnet --vpc-id vpc-59c000a31a31857fb --cidr-block 10.0.2.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=sensei-private-subnet}]'

#IGW作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-internet-gateway

#IGWをVPCにアタッチ
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 attach-internet-gateway --internet-gateway-id igw-2eaa4341363ae7d4a --vpc-id vpc-59c000a31a31857fb

#ルートテーブルにIGWへの経路を追加
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-route --route-table-id rtb-17c3d6a9a44b2b927 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-2eaa4341363ae7d4a

#パブリックサブネットにルートテーブルを関連付け
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 associate-route-table --route-table-id rtb-17c3d6a9a44b2b927 --subnet-id subnet-f1446cf9d06f191c4
