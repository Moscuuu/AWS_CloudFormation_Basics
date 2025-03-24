#!/bin/bash

curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/mssql-release.repo
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel

export PATH="$PATH:/opt/mssql-tools/bin"
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

export AWS_REGION="us-east-1"  

S3_BUCKET="moszynski-s3-bucket"

DB_ENDPOINT=$(aws cloudformation list-exports --region $AWS_REGION \
    --query "Exports[?Name=='DBEndpoint'].Value" --output text)

if [[ -z "$DB_ENDPOINT" ]]; then
    echo "ERROR: Failed to retrieve DB Endpoint!" >&2
    exit 1
fi

if [[ -z "$S3_BUCKET" ]]; then
    echo "ERROR: Failed to retrieve S3 Bucket Name!" >&2
    exit 1
fi

EXPORT_FILE="/home/ec2-user/order.txt"

bcp "[Microsoft.eShopOnWeb.CatalogDb].dbo.Orders" out "$EXPORT_FILE" -c -t"," -S "$DB_ENDPOINT,1433" -U admin -P "MySecurePassword123" || {
    echo "ERROR: BCP export failed!" >&2
    exit 1
}

aws s3 cp "$EXPORT_FILE" "s3://$S3_BUCKET/" --region us-east-1 || {
    echo "ERROR: Upload to S3 failed!" >&2
    exit 1
}

echo "Export completed successfully!"
