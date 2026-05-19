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
