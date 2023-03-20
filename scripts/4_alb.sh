#!/bin/bash

SG_ALB_ID=$(aws ec2 create-security-group --group-name alb-sg --vpc-id "$VPC_ID" --description "Allow all inbound traffic" --output text)

aws ec2 authorize-security-group-ingress --group-id "$SG_ALB_ID" --protocol all --cidr 0.0.0.0/0

ALB_ARN=$(aws elbv2 create-load-balancer --name web-alb --subnets "$SUBNET_PUBLIC1_ID" "$SUBNET_PUBLIC2_ID" --security-groups "$SG_ALB_ID" --query LoadBalancers[].LoadBalancerArn --output text)

TARGET_GROUP_ARN=$(aws elbv2 create-target-group --name web-target-gr --protocol HTTP --port 80 --target-type ip --vpc-id "$VPC_ID" --query TargetGroups[].TargetGroupArn --output text)

aws elbv2 create-listener --load-balancer-arn "$ALB_ARN" --protocol HTTP --port 80 --default-actions "Type=forward,TargetGroupArn=${TARGET_GROUP_ARN}"
