#!/usr/bin/env bash

env=$1
name=$(jq -r ".name" ./src/package.json)
region=$(jq -r ".region" ./config.json)
deployment_bucket=$(jq -r ".deployment_bucket" ./config.json)
vpc_name=$(eval "echo \"$(jq -r ".vpc_name" ./config.json)\"" 2> /dev/null)
subnet1_name=$(eval "echo \"$(jq -r ".subnet1_name" ./config.json)\"" 2> /dev/null)
subnet2_name=$(eval "echo \"$(jq -r ".subnet2_name" ./config.json)\"" 2> /dev/null)
consul_endpoint=$(eval "echo \"$(jq -r ".consul_endpoint" ./config.json)\"" 2> /dev/null)
consul_port=$(eval "echo \"$(jq -r ".consul_port" ./config.json)\"" 2> /dev/null)

sam build --region $region

sam package \
    --output-template-file ${env}-packaged.yaml \
    --s3-bucket $deployment_bucket \
    --s3-prefix ${name}/${env} \
    --region $region

vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=[\"$vpc_name\"]" | jq -r ".Vpcs | .[0] | .VpcId")
subnet1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=[\"$subnet1_name\"]" | jq -r '.Subnets | map(.SubnetId) | .[0]')
subnet2=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=[\"$subnet2_name\"]" | jq -r '.Subnets | map(.SubnetId) | .[0]')

sam deploy \
    --template-file ${env}-packaged.yaml \
    --parameter-overrides="Env=$env PrivateSubnet1=$subnet1 PrivateSubnet2=$subnet2 VpcId=$vpc_id ConsulEndpoint=$consul_endpoint ConsulPort=$consul_port" \
    --stack-name ${name}-${env} \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $region

AWS_DEFAULT_REGION=$region aws cloudformation describe-stacks \
    --stack-name ${name}-${env} \
    --query 'Stacks[].Outputs[?OutputKey==`ConsulKVBackupFunction`]' \
    --output table
