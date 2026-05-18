#!/bin/bash

#VPC作成
aws --profile localstack --endpoint-url=http://localhost:4566 ec2 create-vpc --cidr-block 10.0.0.0/16
