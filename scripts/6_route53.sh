#!/bin/bash

HOSTED_ZONE_ID=$(aws route53 create-hosted-zone --name "$DOMAIN_NAME" --caller-reference $(date +%Y-%m-%d-%H-%M-%S) --query HostedZone.Id --output text | awk -F'/' '{print $NF}')

ALB_DNS_NAME=$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" --query 'LoadBalancers[].DNSName' --output text)

ALB_HOSTED_ZONE_ID=$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" --query 'LoadBalancers[].CanonicalHostedZoneId' --output text)

aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"www.'"$DOMAIN_NAME"'","Type":"A","AliasTarget":{"HostedZoneId":"'"$ALB_HOSTED_ZONE_ID"'","DNSName":"'"$ALB_DNS_NAME"'","EvaluateTargetHealth":false}}}]}'
