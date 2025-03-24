#!/bin/bash

INSTANCE_ID=""
for i in {1..3}; do
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=ASGInstance" "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].InstanceId" --output text)

    if [[ -n "$INSTANCE_ID" ]]; then
        break
    fi
    sleep 5  
done

if [[ -z "$INSTANCE_ID" ]]; then
    echo "Failed to retrieve running instance ID!"
    exit 1
fi

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)


STACK_NAME="elastic"

PRIVATE_IP=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='ESPrivateIP'].OutputValue" --output text)

if [ -z "$PRIVATE_IP" ]; then
  echo "Error: Unable to retrieve the ElasticStack Private IP from CloudFormation outputs."
else
  echo "ElasticStack Private IP: $PRIVATE_IP"
fi

ssh -o StrictHostKeyChecking=no -i vockey.pem -L 5601:$PRIVATE_IP:5601 ec2-user@$PUBLIC_IP

