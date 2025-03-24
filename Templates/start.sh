#!/bin/bash
aws cloudformation create-stack --stack-name network --template-body file://network.yml
aws cloudformation wait stack-create-complete --stack-name network
aws cloudformation create-stack --stack-name rds --template-body file://rds.yml
aws cloudformation wait stack-create-complete --stack-name rds
aws cloudformation create-stack --stack-name efs --template-body file://efs.yml
aws cloudformation wait stack-create-complete --stack-name efs
aws cloudformation create-stack --stack-name ec2 --template-body file://ec2.yml
aws cloudformation wait stack-create-complete --stack-name ec2
aws cloudformation create-stack --stack-name elastic --template-body file://elasticstack.yml
aws cloudformation wait stack-create-complete --stack-name elastic
aws cloudformation create-stack --stack-name moszynski --template-body file://s3.yml
aws cloudformation wait stack-create-complete --stack-name moszynski
aws s3 cp trigger.zip s3://moszynski-s3-bucket
aws cloudformation create-stack --stack-name lambda --template-body file://lambda.yml
aws cloudformation wait stack-create-complete --stack-name lambda
aws s3api put-bucket-notification-configuration \
  --bucket moszynski-s3-bucket \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [
      {
        "LambdaFunctionArn": "arn:aws:lambda:us-east-1:<id>:function:FileUploadProcessor",
        "Events": ["s3:ObjectCreated:*"]
      }
    ]
  }'
