#!/bin/bash
# Project 1: Deploy Static Website to S3 + CloudFront (OAC - private bucket)

set -e

echo "🚀 Deploying Static Website to S3 + CloudFront..."

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REGION="us-east-1"
BUCKET_NAME="my-static-website-$(date +%s)"

# ── Step 1: Create private S3 bucket ────────────────────────────────────────
echo -e "${BLUE}Step 1: Creating private S3 bucket...${NC}"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Block all public access — CloudFront will access via OAC, not public URLs
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo -e "${GREEN}✓ Private S3 bucket created${NC}"

# ── Step 2: Upload website files ─────────────────────────────────────────────
echo -e "${BLUE}Step 2: Uploading website files...${NC}"
aws s3 sync . s3://$BUCKET_NAME \
  --exclude "*.sh" \
  --exclude "*.md" \
  --exclude ".git/*" \
  --exclude "deployment-info.txt"
echo -e "${GREEN}✓ Files uploaded${NC}"

# ── Step 3: Create CloudFront Origin Access Control ──────────────────────────
echo -e "${BLUE}Step 3: Creating CloudFront Origin Access Control...${NC}"
OAC_ID=$(aws cloudfront create-origin-access-control \
  --origin-access-control-config "{
    \"Name\": \"oac-${BUCKET_NAME}\",
    \"Description\": \"OAC for ${BUCKET_NAME}\",
    \"SigningProtocol\": \"sigv4\",
    \"SigningBehavior\": \"always\",
    \"OriginAccessControlOriginType\": \"s3\"
  }" \
  --query 'OriginAccessControl.Id' --output text)
echo -e "${GREEN}✓ OAC created: $OAC_ID${NC}"

# ── Step 4: Create CloudFront distribution ───────────────────────────────────
echo -e "${BLUE}Step 4: Creating CloudFront distribution...${NC}"
cat > /tmp/cf-config-${BUCKET_NAME}.json << EOF
{
  "CallerReference": "website-$(date +%s)",
  "Comment": "Static website - ${BUCKET_NAME}",
  "Enabled": true,
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [{
      "Id": "S3-${BUCKET_NAME}",
      "DomainName": "${BUCKET_NAME}.s3.${REGION}.amazonaws.com",
      "S3OriginConfig": {"OriginAccessIdentity": ""},
      "OriginAccessControlId": "${OAC_ID}"
    }]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-${BUCKET_NAME}",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"],
      "CachedMethods": {"Quantity": 2, "Items": ["GET", "HEAD"]}
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {"Forward": "none"}
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true,
    "TrustedSigners": {"Enabled": false, "Quantity": 0}
  },
  "CustomErrorResponses": {
    "Quantity": 1,
    "Items": [{
      "ErrorCode": 404,
      "ResponsePagePath": "/index.html",
      "ResponseCode": "200",
      "ErrorCachingMinTTL": 300
    }]
  }
}
EOF

DIST_ID=$(aws cloudfront create-distribution \
  --distribution-config file:///tmp/cf-config-${BUCKET_NAME}.json \
  --query 'Distribution.Id' --output text)

DIST_ARN=$(aws cloudfront get-distribution \
  --id $DIST_ID \
  --query 'Distribution.ARN' --output text)

DIST_DOMAIN=$(aws cloudfront get-distribution \
  --id $DIST_ID \
  --query 'Distribution.DomainName' --output text)

rm -f /tmp/cf-config-${BUCKET_NAME}.json
echo -e "${GREEN}✓ CloudFront distribution created: $DIST_ID${NC}"

# ── Step 5: Grant CloudFront OAC read access to the bucket ───────────────────
echo -e "${BLUE}Step 5: Applying bucket policy for CloudFront OAC...${NC}"
cat > /tmp/bucket-policy-${BUCKET_NAME}.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowCloudFrontOAC",
    "Effect": "Allow",
    "Principal": {"Service": "cloudfront.amazonaws.com"},
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${BUCKET_NAME}/*",
    "Condition": {
      "StringEquals": {
        "AWS:SourceArn": "${DIST_ARN}"
      }
    }
  }]
}
EOF

aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file:///tmp/bucket-policy-${BUCKET_NAME}.json

rm -f /tmp/bucket-policy-${BUCKET_NAME}.json
echo -e "${GREEN}✓ Bucket policy applied${NC}"

# ── Save deployment info ──────────────────────────────────────────────────────
cat > deployment-info.txt << EOF
Static Website Deployment
=========================
S3 Bucket:                    $BUCKET_NAME
OAC ID:                       $OAC_ID
CloudFront Distribution ID:   $DIST_ID
CloudFront URL:               https://$DIST_DOMAIN

Note: CloudFront distribution takes 15-20 minutes to fully deploy.
Note: The S3 bucket is private — objects are accessible only via CloudFront.

Cleanup:
  Run ./cleanup-website.sh to delete all resources
EOF

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "CloudFront URL: ${BLUE}https://$DIST_DOMAIN${NC}"
echo "(S3 bucket is private — no direct bucket URL)"
echo ""
echo "⏳ CloudFront distribution is deploying (~15-20 minutes)"
echo "📝 Deployment info saved to deployment-info.txt"
