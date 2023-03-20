#!/bin/bash

aws iam create-role --role-name "$ECS_TASK_EXEC_ROLE_NAME" --assume-role-policy-document file://apps/ecs-tasks-trust-policy.json
aws iam attach-role-policy --role-name "$ECS_TASK_EXEC_ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
aws iam attach-role-policy --role-name "$ECS_TASK_EXEC_ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-role-policy --role-name "$ECS_TASK_EXEC_ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

aws ecs create-cluster --cluster-name "$ECS_CLUSTER_NAME"

SG_ECS_TASK_ID=$(aws ec2 create-security-group --group-name ecs-task-sg --vpc-id "$VPC_ID" --description "ECS Task" --output text)

aws ec2 authorize-security-group-ingress --group-id "$SG_ECS_TASK_ID" --protocol all --source-group "$SG_ALB_ID"

SG_VPC_ENDPOINT_ID=$(aws ec2 create-security-group --group-name vpc-endpoint-sg --vpc-id "$VPC_ID" --description "VPC Endpoint" --output text)

aws ec2 authorize-security-group-ingress --group-id "$SG_VPC_ENDPOINT_ID" --protocol all --cidr 0.0.0.0/0

aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --vpc-endpoint-type Interface --service-name "com.amazonaws.${REGION}.ecr.dkr" --subnet-ids "$SUBNET_PRIVATE1_ID" "$SUBNET_PRIVATE2_ID" --security-group-ids "$SG_VPC_ENDPOINT_ID"
aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --vpc-endpoint-type Interface --service-name "com.amazonaws.${REGION}.ecr.api" --subnet-ids "$SUBNET_PRIVATE1_ID" "$SUBNET_PRIVATE2_ID" --security-group-ids "$SG_VPC_ENDPOINT_ID"
aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --service-name "com.amazonaws.${REGION}.s3" --route-table-ids "$RTB_PRIVATE_ID"
aws ec2 create-vpc-endpoint --vpc-id "$VPC_ID" --vpc-endpoint-type Interface --service-name "com.amazonaws.${REGION}.logs" --subnet-ids "$SUBNET_PRIVATE1_ID" "$SUBNET_PRIVATE2_ID" --security-group-ids "$SG_VPC_ENDPOINT_ID"

aws ecs create-service --cluster "$ECS_CLUSTER_NAME" --service-name web-service --task-definition web-service --desired-count 2 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_PRIVATE1_ID},${SUBNET_PRIVATE2_ID}],securityGroups=[${SG_ECS_TASK_ID}]}" --load-balancers "targetGroupArn=${TARGET_GROUP_ARN},containerName=nginx,containerPort=80"
