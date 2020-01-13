#!/usr/bin/env bash

env=$1
name=$(jq -r ".name" ./src/package.json)
region=$(jq -r ".region" ./config.json)

aws cloudformation delete-stack --stack-name ${name}-${env} --region $region
