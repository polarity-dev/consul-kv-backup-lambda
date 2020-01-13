# consul-kv-backup-lambda

## Requirements
* AWS CLI - [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and [configure it with your AWS credentials].
* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Node.js - [Install Node.js 10](https://nodejs.org/en/), including the NPM package management tool.
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)


## Deploy application

```bash
$ npm run deploy <env>
```


## Use the SAM CLI to build and test locally

```bash
$ npm run test
```

## Fetch Lambda function logs

```bash
$ npm run logs <env>
```

## Cleanup

```bash
$ npm run destroy <env>
```
