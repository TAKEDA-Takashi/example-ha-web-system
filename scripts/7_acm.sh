#!/bin/bash

ACM_CERT_ARN=$(aws acm request-certificate --domain-name "$DOMAIN_NAME" --subject-alternative-names "www.${DOMAIN_NAME}" --validation-method DNS --query CertificateArn --output text)

sleep 5

aws acm describe-certificate --certificate-arn "$ACM_CERT_ARN" --query Certificate.DomainValidationOptions[].ResourceRecord --output text | awk '{print "aws route53 change-resource-record-sets --hosted-zone-id \"'"$HOSTED_ZONE_ID"'\" --change-batch \047{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"" $1 "\",\"Type\":\"" $2 "\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"" $3 "\"}]}}]}\047"}' | sh

while :; do
  STATUS=$(aws acm describe-certificate --certificate-arn "$ACM_CERT_ARN" --query Certificate.Status --output text)

  if [[ "$STATUS" == "ISSUED" ]]; then
    echo "ACM証明書のDNS検証が完了しました。"
    break
  elif [[ "$STATUS" == "FAILED" ]]; then
    echo "ACM証明書のDNS検証に失敗しました。"
    exit 1
  else
    echo "ACM証明書のDNS検証が完了していません。5秒待機します。"
    sleep 5
  fi
done

aws elbv2 create-listener --load-balancer-arn "$ALB_ARN" --protocol HTTPS --port 443 --default-actions "Type=forward,TargetGroupArn=${TARGET_GROUP_ARN}" --certificates "CertificateArn=${ACM_CERT_ARN}"
