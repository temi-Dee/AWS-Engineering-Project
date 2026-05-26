#!/bin/bash
# Project 1: Cleanup Static Website Resources

set -e

echo "🧹 Cleaning up Static Website resources..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Read deployment info
if [ -f deployment-info.txt ]; then
    BUCKET_NAME=$(grep "S3 Bucket:" deployment-info.txt | awk '{print $3}')
    DIST_ID=$(grep "CloudFront Distribution ID:" deployment-info.txt | awk '{print $5}')
    OAC_ID=$(grep "OAC ID:" deployment-info.txt | awk '{print $4}')
fi

# Step 1: Disable and delete CloudFront distribution
if [ ! -z "$DIST_ID" ]; then
    echo -e "${BLUE}Step 1: Disabling CloudFront distribution...${NC}"
    
    ETAG=$(aws cloudfront get-distribution-config --id $DIST_ID --query 'ETag' --output text 2>/dev/null || echo "")
    
    if [ ! -z "$ETAG" ]; then
        aws cloudfront get-distribution-config --id $DIST_ID --query 'DistributionConfig' > cf-config.json
        
        # Disable distribution
        jq '.Enabled = false' cf-config.json > cf-config-disabled.json
        
        aws cloudfront update-distribution \
          --id $DIST_ID \
          --distribution-config file://cf-config-disabled.json \
          --if-match $ETAG 2>/dev/null || true
        
        echo "Waiting for CloudFront distribution to be disabled..."
        aws cloudfront wait distribution-deployed --id $DIST_ID 2>/dev/null || true
        
        # Delete distribution
        NEW_ETAG=$(aws cloudfront get-distribution-config --id $DIST_ID --query 'ETag' --output text 2>/dev/null || echo "")
        if [ ! -z "$NEW_ETAG" ]; then
            aws cloudfront delete-distribution --id $DIST_ID --if-match $NEW_ETAG 2>/dev/null || true
        fi
        
        rm -f cf-config.json cf-config-disabled.json
    fi
    
    echo -e "${GREEN}✓ CloudFront distribution deleted${NC}"
fi

# Step 2: Delete S3 bucket
if [ ! -z "$BUCKET_NAME" ]; then
    echo -e "${BLUE}Step 2: Deleting S3 bucket...${NC}"
    aws s3 rm s3://$BUCKET_NAME --recursive 2>/dev/null || true
    aws s3 rb s3://$BUCKET_NAME 2>/dev/null || true
    echo -e "${GREEN}✓ S3 bucket deleted${NC}"
fi

# Step 3: Delete Origin Access Control
if [ -n "${OAC_ID:-}" ]; then
    echo -e "${BLUE}Step 3: Deleting Origin Access Control...${NC}"
    aws cloudfront delete-origin-access-control --id $OAC_ID 2>/dev/null || true
    echo -e "${GREEN}✓ OAC deleted${NC}"
fi

# Clean up local files
rm -f deployment-info.txt

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
