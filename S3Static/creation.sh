aws cloudformation create-stack --stack-name moszynskitest --template-body file://S3Static.yml

aws cloudformation wait stack-create-complete --stack-name moszynskitest

aws s3 cp index.html s3://moszynskitest-s3-bucket/


