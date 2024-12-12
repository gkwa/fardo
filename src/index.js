const AWS = require("aws-sdk")
const sqs = new AWS.SQS()
const ms = require("ms")
const fetch = require("node-fetch")

const STALE_THRESHOLD = ms("5s")
const NTFY_URL = "https://ntfy.sh/mtmonacelli-itsfergus"

exports.handler = async (event) => {
  try {
    console.log("Starting execution")

    const params = {
      QueueUrl: process.env.QUEUE_URL,
      MaxNumberOfMessages: 1,
      WaitTimeSeconds: 20,
      MessageAttributeNames: ["All"],
      AttributeNames: ["All"],
    }

    console.log("Fetching messages...")
    const data = await sqs.receiveMessage(params).promise()
    console.log("Received data:", JSON.stringify(data))

    if (!data.Messages || data.Messages.length === 0) {
      console.log("No messages found")
      return { statusCode: 200, body: "No messages found" }
    }

    const message = data.Messages[0]
    const sentTimestamp = parseInt(message.Attributes.SentTimestamp)
    const messageAge = Date.now() - sentTimestamp
    console.log(`Message age: ${messageAge}ms (${ms(messageAge, { long: true })})`)

    if (messageAge > STALE_THRESHOLD) {
      console.log("Message is stale, sending notification")
      const notifyResponse = await fetch(NTFY_URL, {
        method: "POST",
        body: `failed to fetch message newer than ${ms(STALE_THRESHOLD, { long: true })}`,
      })
      console.log("Notification response:", notifyResponse.status)
    }

    return {
      statusCode: 200,
      body: `Message age: ${ms(messageAge, { long: true })}`,
    }
  } catch (error) {
    console.error("Error:", error)
    throw error
  }
}
