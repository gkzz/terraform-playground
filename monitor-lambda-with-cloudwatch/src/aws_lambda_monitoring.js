const axios = require('axios');
const zlib = require('zlib');

//https://stackoverflow.com/questions/58556377/how-to-post-data-to-slack-using-nodejs-using-axios
const postToSlack = async (webHookPathUrl, record) => {
    console.log(`record: ${JSON.stringify(record)}`);
    /*
    2022-03-08T02:03:43.096Z	*******	INFO	record: [
    {
        "id": "*******",
        "timestamp": *******,
        "message": "2022-03-08T02:03:33.577Z\t*********\tINFO\tevent received: {\"Records\":[{\"EventSource\":\"aws:sns\",\"EventVersion\":\"1.0\",\"EventSubscriptionArn\":\"arn:aws:sns:REGION:*******:aws-budget-alert-to-slack-topic:*******\",\"Sns\":{\"Type\":\"Notification\",\"MessageId\":\"*******\",\"TopicArn\":\"arn:aws:sns:REGION:*******:aws-budget-alert-to-slack-topic\",\"Subject\":\"ggg\",\"Message\":\"ERROR\",\"Timestamp\":\"2022-03-08T02:03:33.449Z\",\"SignatureVersion\":\"1\",\"Signature\":\"略"
    },
    {
        "id": "*******",
        "timestamp": *******,
        "message": "2022-03-08T02:03:33.577Z\t*********\tINFO\tevent received: {\"Records\":[{\"EventSource\":\"aws:sns\",\"EventVersion\":\"1.0\",\"EventSubscriptionArn\":\"arn:aws:sns:REGION:*******:aws-budget-alert-to-slack-topic:*******\",\"Sns\":{\"Type\":\"Notification\",\"MessageId\":\"*******\",\"TopicArn\":\"arn:aws:sns:REGION:*******:aws-budget-alert-to-slack-topic\",\"Subject\":\"ggg\",\"Message\":\"ERROR\",\"Timestamp\":\"2022-03-08T02:03:33.449Z\",\"SignatureVersion\":\"1\",\"Signature\":\"略"
    }]
    */
    try {
        const payload = {
            record: '<!here> ' + record.Sns.Subject, //undefined
            attachments: [{
                fields: [{
                    title: 'MESSAGE',
                    value: record.Sns.Message,
                    short: true,
                }]
            }]
        };
        const options = {
            method: 'post',
            baseURL: webHookPathUrl,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            data: payload
        };
        await axios.request(options);
    } catch (e) {
        const status = e.response.status;
        console.error(`There was an error, HTTP status code: ${status}`);
    }
};

//https://gist.github.com/aflansburg/132ef45a5ad9006469d8286bb99a0ec5
function decryptCloudwatchGzip(cw){
    // write string to buffer
    const cwBuffer = Buffer.from(cw, 'base64');
    /*
    return new Promise(resolve => {
        let res = null;
        zlib.unzip(cwBuffer, (err, result) => {
            if (err){
                res = "Error occurred when attempting to unzip the Gzipped log data.\n" + JSON.stringify(err) + "\nOriginalEventData:\n-----" + JSON.stringify(cw);
            } else {
                const parsedResponse = JSON.parse(result);
                const messages = [];
                parsedResponse.logEvents.forEach(logEvent => {
                    if (logEvent.message.toLowerCase().includes('error')){
                        messages.push(":bangbang: " + logEvent.message);
                    }
                });
                res = messages.length > 0 ? messages.join('\n') : null;
            }
            resolve(res);
        });
    })
    */
    // https://stackoverflow.com/questions/50327304/aws-cloudwatch-log-subscription-filters-decode
    const logevents = JSON.parse(zlib.unzipSync(cwBuffer).toString()).logEvents;
    return logevents;

}

exports.handler = async (event) => {
    let record = "Event occurred, but no message was retrieved by the Lambda function.";
    if (event && event.awslogs){
        record = await decryptCloudwatchGzip(event.awslogs.data);
        // return if decrypt method returns null - means log message was not an error
        if (!record) return;
    } else if (event){
        record = JSON.stringify(event);
    }
    postToSlack(process.env.SLACK_WEBHOOK_URL, record);

};