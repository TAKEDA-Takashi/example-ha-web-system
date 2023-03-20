#!/bin/bash

AWS_ACCOUNT_ID=123456789012

REGION=ap-northeast-1
AZ1="${REGION}a"
AZ2="${REGION}c"

ECR_REPO_NAME=ha-web-system
ECS_TASK_EXEC_ROLE_NAME=ecsTaskExecutionRole
ECS_CLUSTER_NAME=ha-web-cluster

DOMAIN_NAME=example.com
