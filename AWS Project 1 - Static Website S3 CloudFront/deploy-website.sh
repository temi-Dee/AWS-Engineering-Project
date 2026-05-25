#!/bin/bash
# Project 1: Deploy Static Website to S3 + CloudFront

set -e

echo "🚀 Deploying Static Website to S3 + CloudFront..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables
REGION="us-east-1"
BUCKET_NAME="my-static-website-$(date +%s)"

# Step 1: Create S3 Bucket
echo -e "${BLUE}Step 1: Creating S3 bucket...${NC}"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Step 2: Configure bucket for static website hosting
echo -e "${BLUE}Step 2: Configuring static website hosting...${NC}"
aws s3 website s3://$BUCKET_NAME \
  --index-document index.html \
  --error-document index.html

# Step 3: Disable block public access
echo -e "${BLUE}Step 3: Disabling block public access...${NC}"
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Step 4: Add bucket policy
echo -e "${BLUE}Step 4: Applying bucket policy...${NC}"
cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
  }]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# Step 5: Upload website files
echo -e "${BLUE}Step 5: Uploading website files...${NC}"
aws s3 sync . s3://$BUCKET_NAME \
  --exclude "*.sh" \
  --exclude "*.md" \
  --exclude "bucket-policy.json" \
  --exclude ".git/*"

# Step 6: Create CloudFront distribution
echo -e "${BLUE}Step 6: Creating CloudFront distribution...${NC}"
cat > cloudfront-config.json << EOF
{
  "CallerReference": "website-$(date +%s)",
  "Comment": "Static website distribution",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [{
      "Id": "S3-${BUCKET_NAME}",
      "DomainName": "${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com",
      "CustomOriginConfig": {
        "HTTPPort": 80,
        "HTTPSPort": 443,
        "OriginProtocolPolicy": "http-only"
      }
    }]
  },
  "DefaultRootObject": "index.html",
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-${BUCKET_NAME}",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {"Forward": "none"}
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true,
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    }
  }
}
EOF

DIST_ID=$(aws cloudfront create-distribution \
  --distribution-config file://cloudfront-config.json \
  --query 'Distribution.Id' \
  --output text)

DIST_DOMAIN=$(aws cloudfront get-distribution \
  --id $DIST_ID \
  --query 'Distribution.DomainName' \
  --output text)

# Clean up temp files
rm -f bucket-policy.json cloudfront-config.json

# Save deployment info
cat > deployment-info.txt << EOF
Static Website Deployment
=========================

S3 Bucket: $BUCKET_NAME
S3 Website URL: http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com
CloudFront Distribution ID: $DIST_ID
CloudFront URL: https://$DIST_DOMAIN

Note: CloudFront distribution takes 15-20 minutes to deploy.

Cleanup:
Run ./cleanup-website.sh to delete all resources
EOF

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "S3 Website URL: ${BLUE}http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com${NC}"
echo -e "CloudFront URL: ${BLUE}https://$DIST_DOMAIN${NC}"
echo ""
echo "⏳ CloudFront distribution is deploying (15-20 minutes)"
echo "📝 Deployment info saved to deployment-info.txt"
echo ""
