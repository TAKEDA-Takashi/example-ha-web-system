#!/bin/bash

ACM_CERT_ARN=$(aws acm request-certificate --domain-name "$DOMAIN_NAME" --subject-alternative-names "www.${DOMAIN_NAME}" --validation-method DNS --query CertificateArn --output text)

aws acm describe-certificate --certificate-arn "$ACM_CERT_ARN" --query Certificate.DomainValidationOptions[].ResourceRecord --output text | awk '{print "aws route53 change-resource-record-sets --hosted-zone-id \"'"$HOSTED_ZONE_ID"'\" --change-batch \047{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"" $1 "\",\"Type\":\"" $2 "\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"" $3 "\"}]}}]}\047"}' | sh

aws elbv2 create-listener --load-balancer-arn "$ALB_ARN" --protocol HTTPS --port 443 --default-actions "Type=forward,TargetGroupArn=${TARGET_GROUP_ARN}" --certificates "CertificateArn=${ACM_CERT_ARN}"
