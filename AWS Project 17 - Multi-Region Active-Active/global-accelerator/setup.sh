#!/bin/bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
PRIMARY_REGION="us-east-1"
SECONDARY_REGION="eu-west-1"

ACCELERATOR_ARN=$(aws globalaccelerator create-accelerator \
  --name global-app-accelerator \
  --ip-address-type IPV4 \
  --enabled \
  --query 'Accelerator.AcceleratorArn' --output text)

LISTENER_ARN=$(aws globalaccelerator create-listener \
  --accelerator-arn $ACCELERATOR_ARN \
  --protocol TCP \
  --port-ranges FromPort=80,ToPort=80 FromPort=443,ToPort=443 \
  --query 'Listener.ListenerArn' --output text)

echo "Accelerator ARN: $ACCELERATOR_ARN"
echo "Listener ARN: $LISTENER_ARN"
