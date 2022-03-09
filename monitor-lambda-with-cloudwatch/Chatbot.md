# AWS Chatbotの設定方法
- 以下の記事を参考にやったが、IAM Policyの設定でハマった
  - [Lambdaの実行時エラーをChatbotでSlackに通知するのが便利すぎる話 | public memo](https://masakimisawa.com/lambda_error_notification_slack_from_chatbot/)
- AWS Chatbotに付与するIAM Policyは自前で用意するより、AWSコンソールから `Policy Templates` を使うほうがシンプルな印象。
  - > For Policy Templates, select Read-only command permissions and Lambda-invoke command permissions.
  - Ref: [Tutorial: Using AWS Chatbot to run an AWS Lambda function remotely - AWS Chatbot](https://docs.aws.amazon.com/chatbot/latest/adminguide/chatbot-run-lambda-function-remotely-tutorial.html)

- TerraformではCloudWatch alarmとSNSの設定をやっている