# AWS CloudFormation Basics

Repository for storing CloudFormation templates and shell scripts for the "Cloud Automation Concepts" course at Saxion University of Applied Sciences.

## Project Overview

This repository contains CloudFormation templates and supporting scripts to deploy a complete cloud infrastructure on AWS. The architecture includes:

- Networking infrastructure (VPC, subnets, internet gateway)
- Database (Microsoft SQL Server RDS)
- Elastic File System (EFS)
- EC2 instances with auto-scaling
- Elastic Load Balancer (ELB)
- Elastic Stack (Elasticsearch, Logstash, Kibana, Filebeat)
- S3 bucket for static website hosting
- Lambda function with S3 trigger

## Repository Structure

```
├── LICENSE                       # MIT License
├── README.md                     # This file
├── S3Static                      # Static website deployment
│   ├── S3Static.yml              # CloudFormation template for S3 static website
│   ├── creation.sh               # Deployment script for S3 static website
│   └── index.html                # Sample HTML content
├── Templates                     # Main CloudFormation templates
│   ├── ec2.yml                   # EC2 with auto-scaling and load balancer
│   ├── efs.yml                   # Elastic File System
│   ├── elasticstack.yml          # Elasticsearch, Logstash, Kibana, Filebeat
│   ├── lambda.yml                # Lambda function with S3 trigger
│   ├── network.yml               # VPC, subnets, routing
│   ├── rds.yml                   # RDS SQL Server database
│   ├── s3.yml                    # S3 bucket for Lambda code
│   └── start.sh                  # Main deployment script
├── connector.sh                  # Script to connect to EC2 instance
├── exporter.sh                   # Script to export data from SQL Server to S3
└── proof_elastic.sh              # Script to set up SSH tunnel for Kibana
```

## Deployment Instructions

### Full Stack Deployment

To deploy the complete infrastructure:

1. Ensure you have AWS CLI configured with appropriate credentials
2. Navigate to the Templates directory
3. Run the start script:

```bash
cd Templates
chmod +x start.sh
./start.sh
```

This will sequentially deploy:
1. Network infrastructure
2. RDS database
3. Elastic File System
4. EC2 instances with auto-scaling
5. Elastic Stack
6. S3 bucket for Lambda code
7. Lambda function with S3 trigger

### Individual Component Deployment

Each component can also be deployed individually using AWS CLI:

```bash
aws cloudformation create-stack --stack-name <stack-name> --template-body file://<template-file>.yml
```

## Accessing Resources

### Static Website

After deploying the S3 static website:

```bash
cd S3Static
chmod +x creation.sh
./creation.sh
```

The website URL will be output at the end of the deployment process, usually in the format:
`http://moszynskitest-s3-bucket.s3-website-<region>.amazonaws.com`

### Elastic Stack

To access Kibana:

```bash
chmod +x proof_elastic.sh
./proof_elastic.sh
```

This creates an SSH tunnel, allowing you to access Kibana at: `http://localhost:5601`

### Exporting Data

To export data from SQL Server to S3:

```bash
chmod +x connector.sh
./connector.sh
```

## Architecture Components

### Network
- VPC with CIDR block 10.0.0.0/16
- 2 public subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 private subnets (10.0.51.0/24, 10.0.52.0/24)
- Internet Gateway and Route Tables

### Database
- Microsoft SQL Server Web Edition
- Deployed in private subnet
- Security group limiting access to VPC CIDR

### EC2 and Auto Scaling
- Launch template with user data for application deployment
- Auto Scaling Group with target tracking scaling policy
- Scheduled scaling for peak hours
- Application Load Balancer for distribution

### Elastic Stack
- Deployed in private subnet with NAT Gateway
- Elasticsearch for data storage and search
- Logstash for data processing
- Kibana for visualization
- Filebeat for log collection

### S3 and Lambda
- S3 bucket for static website hosting
- S3 bucket for Lambda code
- Lambda function triggered by S3 object creation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributors

- Aleksander Andrzej Moszyński & Alex Avila Gomez - Course: Cloud Automation Concepts at Saxion University of Applied Sciences
