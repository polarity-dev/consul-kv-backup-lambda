const fetch = require("node-fetch")
const crypto = require("crypto")
const AWS = require("aws-sdk")
const s3 = new AWS.S3()
const debug = require("debug")("consul-kv-backup-lambda")
const { NODE_ENV, CONSUL_HOST, CONSUL_PORT, S3_BUCKET } = process.env
const consul = require("consul")({
  host: CONSUL_HOST,
  port: CONSUL_PORT,
  promisify: true
})


exports.lambdaHandler = async () => {
  const keys = await consul.kv.keys("")
  debug("keys:", keys)
  const state = await Promise.all(keys.map(async key => {
    const { Value } = await consul.kv.get(key)
    if (Value) {
      const value = Buffer.from(JSON.stringify(JSON.parse(Value) || Value, null, 2))
      return {
        key,
        flags: 0,
        value: value.toString("base64")
      }

    } else {
      return {
        key,
        flags: 0,
        value: Value
      }
 
    }
  }))
  debug("state", state)
  const json = JSON.stringify(state, null, 2)
  const hash = crypto.createHash("md5").update(json).digest("hex")
  debug("hash", hash)
  await s3.putObject({
    Body: json,
    Bucket: S3_BUCKET,
    Key: `${NODE_ENV}/${hash}.json`
  }).promise()
  await s3.putObject({
    Body: json,
    Bucket: S3_BUCKET,
    Key: `${NODE_ENV}/backup.json`
  }).promise()

  return true
}
