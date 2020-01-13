#!/usr/bin/env bash

env=$1
name=$(jq -r ".name" ./src/package.json)
region=$(jq -r ".region" ./config.json)

sam logs -n ConsulKVBackupFunction --stack-name ${name}-${env} --tail --region $region
