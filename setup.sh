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

#パブリックサブネットのパブリックIP自動割り当て
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 modify-subnet-attribute --subnet-id subnet-f1446cf9d06f191c4 --map-public-ip-on-launch

#EC2用セキュリティグループ作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-security-group --group-name sensei-ec2-sg --description "Security group for EC2" --vpc-id vpc-59c000a31a31857fb

#EC2用SGインバウンドルール追加（SSH）
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress --group-id sg-73bead107f4a48753 --protocol tcp --port 22 --cidr 0.0.0.0/0

#EC2用SGインバウンドルール追加（HTTP）
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress --group-id sg-73bead107f4a48753 --protocol tcp --port 80 --cidr 0.0.0.0/0

#RDS用セキュリティグループ作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-security-group --group-name sensei-rds-sg --description "Security group for RDS" --vpc-id vpc-59c000a31a31857fb

#RDS用SGインバウンドルール追加（PostgreSQL：EC2SGからのみ許可）
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress --group-id sg-151e62b5bcdc06206 --protocol tcp --port 5432 --source-group sg-73bead107f4a48753

#KeyPair作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-key-pair --key-name sensei-no-atorie-key --query "KeyMaterial" --output text > ~/sensei-no-atorie-key.pem

#KeyPairのパーミッション設定
chmod 400 ~/sensei-no-atorie-key.pem

#EC2インスタンス起動
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 run-instances --image-id ami-04681a1dbd79675a5 --instance-type t2.micro --key-name sensei-no-atorie-key --subnet-id subnet-f1446cf9d06f191c4 --security-group-ids sg-73bead107f4a48753 --count 1
