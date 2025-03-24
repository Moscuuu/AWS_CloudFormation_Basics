#!/bin/bash

# Get running instance ID (Retry up to 3 times if not found)
INSTANCE_ID=""
for i in {1..3}; do
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=ASGInstance" "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].InstanceId" --output text)

    if [[ -n "$INSTANCE_ID" ]]; then
        break
    fi
    sleep 5  # Wait before retrying
done

if [[ -z "$INSTANCE_ID" ]]; then
    echo "Failed to retrieve running instance ID!"
    exit 1
fi

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

if [[ -z "$PUBLIC_IP" ]]; then
    echo "Failed to retrieve public IP address!"
    exit 1
fi

echo "Connecting to: $PUBLIC_IP"


# Connect via SSH and execute exporting script
ssh -o StrictHostKeyChecking=no -i vockey.pem ec2-user@$PUBLIC_IP 'bash -s' < exporter.sh
