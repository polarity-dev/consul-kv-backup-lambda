#!/usr/bin/env bash

name=$(jq -r ".name" ./src/package.json)

sam build

sam local invoke ConsulKVBackupFunction --env-vars env.json
