#!/bin/bash
# Project 5: Configure AWS Resources for CI/CD Pipeline

set -e

echo "🚀 Configuring AWS Resources for CI/CD Pipeline..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables
REGION="us-east-1"
GITHUB_USERNAME="${1:-YOUR_GITHUB_USERNAME}"
REPO_NAME="${2:-my-app}"

if [ "$GITHUB_USERNAME" == "YOUR_GITHUB_USERNAME" ]; then
    echo -e "${YELLOW}Usage: ./configure-aws.sh <github-username> <repo-name>${NC}"
    echo -e "${YELLOW}Example: ./configure-aws.sh johndoe my-awesome-app${NC}"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Step 1: Create OIDC Provider
echo -e "${BLUE}Step 1: Creating OIDC Provider for GitHub Actions...${NC}"
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  2>/dev/null || echo "OIDC provider already exists"

echo -e "${GREEN}✓ OIDC Provider configured${NC}"

# Step 2: Create IAM Role
echo -e "${BLUE}Step 2: Creating IAM Role for GitHub Actions...${NC}"

cat > github-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_USERNAME}/${REPO_NAME}:*"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://github-trust-policy.json \
  --description "Role for GitHub Actions CI/CD" \
  2>/dev/null || echo "Role already exists"

# Attach policies
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
  2>/dev/null || true

aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess \
  2>/dev/null || true

echo -e "${GREEN}✓ IAM Role created${NC}"

# Step 3: Create S3 Bucket
echo -e "${BLUE}Step 3: Creating S3 Bucket for deployment...${NC}"

BUCKET_NAME="my-app-cicd-${ACCOUNT_ID}-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Disable block public access for website hosting
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
  --index-document index.html \
  --error-document error.html

# Create bucket policy
cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

WEBSITE_URL="http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"

echo -e "${GREEN}✓ S3 Bucket created${NC}"

# Step 4: Create CloudFront Distribution (Optional)
echo -e "${BLUE}Step 4: Creating CloudFront Distribution (optional)...${NC}"
read -p "Create CloudFront distribution? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > cloudfront-config.json << EOF
{
  "CallerReference": "cicd-$(date +%s)",
  "Comment": "CloudFront distribution for CI/CD app",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-${BUCKET_NAME}",
        "DomainName": "${BUCKET_NAME}.s3.${REGION}.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
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
      "Cookies": {
        "Forward": "none"
      }
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true
  },
  "DefaultRootObject": "index.html"
}
EOF

    CF_DIST_ID=$(aws cloudfront create-distribution \
      --distribution-config file://cloudfront-config.json \
      --query 'Distribution.Id' \
      --output text)
    
    CF_DOMAIN=$(aws cloudfront get-distribution \
      --id $CF_DIST_ID \
      --query 'Distribution.DomainName' \
      --output text)
    
    echo -e "${GREEN}✓ CloudFront Distribution created${NC}"
    echo -e "CloudFront Domain: ${BLUE}$CF_DOMAIN${NC}"
else
    CF_DIST_ID=""
    echo "Skipping CloudFront creation"
fi

# Save configuration
cat > aws-config.txt << EOF
AWS CI/CD Configuration
=======================

Account ID: $ACCOUNT_ID
Region: $REGION
GitHub Repo: $GITHUB_USERNAME/$REPO_NAME

Resources Created:
------------------
✓ OIDC Provider: token.actions.githubusercontent.com
✓ IAM Role: GitHubActionsRole
✓ S3 Bucket: $BUCKET_NAME
✓ Website URL: $WEBSITE_URL
EOF

if [ ! -z "$CF_DIST_ID" ]; then
    cat >> aws-config.txt << EOF
✓ CloudFront Distribution: $CF_DIST_ID
✓ CloudFront Domain: https://$CF_DOMAIN
EOF
fi

cat >> aws-config.txt << EOF

GitHub Secrets to Configure:
-----------------------------
AWS_ACCOUNT_ID: $ACCOUNT_ID
S3_BUCKET_NAME: $BUCKET_NAME
EOF

if [ ! -z "$CF_DIST_ID" ]; then
    echo "CLOUDFRONT_DISTRIBUTION_ID: $CF_DIST_ID" >> aws-config.txt
fi

cat >> aws-config.txt << EOF

Commands to Set GitHub Secrets:
--------------------------------
gh secret set AWS_ACCOUNT_ID --body "$ACCOUNT_ID"
gh secret set S3_BUCKET_NAME --body "$BUCKET_NAME"
EOF

if [ ! -z "$CF_DIST_ID" ]; then
    echo "gh secret set CLOUDFRONT_DISTRIBUTION_ID --body \"$CF_DIST_ID\"" >> aws-config.txt
fi

cat >> aws-config.txt << EOF

Test Deployment:
----------------
1. Push code to GitHub main branch
2. Monitor workflow: gh run watch
3. Visit: $WEBSITE_URL
EOF

if [ ! -z "$CF_DIST_ID" ]; then
    echo "4. Or visit: https://$CF_DOMAIN" >> aws-config.txt
fi

# Clean up temp files
rm -f github-trust-policy.json bucket-policy.json cloudfront-config.json

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ AWS Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "S3 Bucket: ${BLUE}$BUCKET_NAME${NC}"
echo -e "Website URL: ${BLUE}$WEBSITE_URL${NC}"
if [ ! -z "$CF_DIST_ID" ]; then
    echo -e "CloudFront: ${BLUE}https://$CF_DOMAIN${NC}"
fi
echo ""
echo "Next steps:"
echo "1. Configure GitHub secrets (see aws-config.txt)"
echo "2. Push code to GitHub"
echo "3. Monitor deployment workflow"
echo ""
echo "📝 Configuration saved to aws-config.txt"
echo ""
