# Project 1: Static Website Hosting with S3 and CloudFront

## Overview

You have a static website for a company registration platform that needs to be served globally with low latency and high availability. In this project you will deploy the site to Amazon S3, distribute it worldwide via CloudFront, secure it with SSL/TLS, and optionally route a custom domain through Route 53.

**What you will build:**
- S3 bucket configured for static website hosting
- CloudFront distribution with HTTPS enforcement
- ACM certificate for SSL/TLS
- Route 53 DNS records pointing to CloudFront (optional)

**Estimated time:** 1–2 hours  
**Estimated cost:** < $1 (CloudFront + S3 Free Tier)

---

## Prerequisites

- AWS account with administrative access
- AWS CLI installed and configured (`aws configure`)
- A registered domain name if you want custom DNS (can be purchased via Route 53)
- Basic familiarity with DNS and HTTP/HTTPS

---

## Project Structure

```
AWS Project 1 - Static Website S3 CloudFront/
├── index.html            # Home page
├── contact.html          # Contact form page
├── css/
│   └── styles.css        # Responsive styling
├── js/
│   └── main.js           # Form validation and submission
├── deploy-website.sh     # Automated deployment script
└── cleanup-website.sh    # Resource cleanup script
```

---

## Step 1: Create and Configure the S3 Bucket

1. Open the AWS Console and navigate to **Amazon S3**.
2. Click **Create Bucket** and enter a globally unique name, for example `regpro-website-12345`.
3. Select your preferred region, for example `us-east-1`.
4. Under **Block Public Access settings**, uncheck **Block all public access**.
5. Acknowledge the warning and click **Create Bucket**.
6. Open the bucket, go to **Properties**, scroll to **Static website hosting**, and click **Edit**:
   - Select **Enable**
   - Index document: `index.html`
   - Error document: `index.html`
   - Click **Save changes**.

---

## Step 2: Set the Bucket Policy for Public Read Access

1. In your bucket, go to **Permissions** → **Bucket policy** → **Edit**.
2. Paste the following policy, replacing `YOUR_BUCKET_NAME` with your bucket name:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    }
  ]
}
```

3. Click **Save changes**.

---

## Step 3: Upload Website Files

1. In your bucket, click **Upload**.
2. Add the following files, preserving the folder structure:
   - `index.html`
   - `contact.html`
   - `css/styles.css`
   - `js/main.js`
3. Click **Upload**.
4. Copy the **Bucket website endpoint** from **Properties → Static website hosting** and open it in a browser to confirm the site loads.

---

## Step 4: Request an ACM Certificate

> ACM certificates for CloudFront **must** be requested in `us-east-1` regardless of your bucket's region.

1. In the AWS Console, switch to **us-east-1** and open **AWS Certificate Manager**.
2. Click **Request a certificate** → **Request a public certificate** → **Next**.
3. Add your domain names, for example:
   - `example.com`
   - `www.example.com`
4. Choose **DNS validation** and click **Request**.
5. Expand the certificate and click **Create records in Route 53** (or add the CNAME records manually if your DNS is elsewhere).
6. Wait for the certificate status to change to **Issued** before proceeding.

---

## Step 5: Create a CloudFront Distribution

1. Open **CloudFront** and click **Create distribution**.
2. Under **Origin**:
   - **Origin domain**: paste your S3 bucket website endpoint (`YOUR_BUCKET_NAME.s3-website-us-east-1.amazonaws.com`), **not** the S3 REST endpoint.
   - **Origin protocol policy**: HTTP only (S3 website endpoints do not support HTTPS).
3. Under **Default cache behavior**:
   - **Viewer protocol policy**: Redirect HTTP to HTTPS
   - **Allowed HTTP methods**: GET, HEAD
4. Under **Settings**:
   - **Alternate domain names (CNAMEs)**: `example.com`, `www.example.com`
   - **Custom SSL certificate**: select the ACM certificate you just created
   - **Default root object**: `index.html`
5. Click **Create distribution**.
6. Wait for the distribution status to show **Enabled** (10–15 minutes).

---

## Step 6: Configure Route 53 DNS

1. Open **Route 53** and select your hosted zone.
2. Click **Create record**:
   - Record type: **A**
   - Enable **Alias**
   - Route traffic to: **Alias to CloudFront distribution**
   - Select your distribution from the dropdown
   - Record name: leave blank for the apex (`example.com`)
3. Repeat for `www.example.com`.
4. Wait for DNS propagation (typically 5–30 minutes).

---

## Console Deployment

Steps 1–6 above are the complete AWS Management Console deployment path. Use this quick reference and cleanup guide alongside them.

### Quick Reference

| Step | Service | Action |
|------|---------|--------|
| 1 | S3 → Create bucket | Unique name, disable Block Public Access, enable static hosting |
| 2 | S3 → Permissions → Bucket policy | Paste public read policy |
| 3 | S3 → Upload | Upload `index.html`, `contact.html`, `css/`, `js/` |
| 4 | Certificate Manager (us-east-1) | Request public certificate, DNS validation |
| 5 | CloudFront → Create distribution | Origin = S3 website endpoint, HTTPS redirect, attach ACM cert |
| 6 | Route 53 → Hosted zone | A alias record → CloudFront distribution |

### Console Cleanup

1. Go to **CloudFront** → select your distribution → **Disable** → wait for **Deployed** status → **Delete**
2. Go to **S3** → open your bucket → select all objects → **Delete objects** → then **Delete bucket**
3. Go to **Certificate Manager** (us-east-1) → select your certificate → **Delete**
4. Go to **Route 53** → hosted zone → delete the A records pointing to CloudFront

---

## Automated Deployment (CLI)

If you prefer to deploy using the provided script:

```bash
cd "AWS Project 1 - Static Website S3 CloudFront"
bash deploy-website.sh
```

The script creates the S3 bucket, configures static hosting, sets the bucket policy, uploads all site files, and creates a CloudFront distribution. Deployment details are saved to `deployment-info.txt`.

To upload updates and invalidate the CloudFront cache manually:

```bash
aws s3 sync . s3://YOUR_BUCKET_NAME \
  --exclude "*.sh" --exclude "*.md" --exclude ".git/*"

aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/index.html" "/contact.html" "/css/*" "/js/*"
```

---

## Cleanup

To delete all resources and avoid ongoing charges:

```bash
bash cleanup-website.sh
```

This disables and removes the CloudFront distribution, then empties and deletes the S3 bucket.

---

## Testing and Validation

| Check | Expected Result |
|-------|----------------|
| S3 website endpoint in browser | Home page loads |
| CloudFront domain (`https://xxxx.cloudfront.net`) | Site loads over HTTPS |
| Custom domain (`https://example.com`) | Resolves to CloudFront |
| Browser padlock / certificate | Valid ACM certificate |
| `/contact.html` | Contact page loads |
| WhatsApp float button | Opens WhatsApp chat link |

---

## Notes

- S3 bucket names are globally unique across all AWS accounts.
- ACM certificates used with CloudFront must be in `us-east-1`.
- CloudFront has a worldwide network of edge locations — users are served from the nearest one.
- Use **Cache invalidation** after every content update to ensure visitors see the latest version.
- Replace placeholder values (`YOUR_BUCKET_NAME`, `example.com`, phone numbers) with your own before deploying.

---

## Learning Objectives

After completing this project you will understand:

- Static website hosting on Amazon S3
- S3 bucket policies for public read access
- Global content delivery with Amazon CloudFront
- SSL/TLS certificate management with AWS Certificate Manager
- DNS routing with Amazon Route 53
- Cache invalidation strategies


{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::staticwebsitey65r5d/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::3651414:distribution/E14XLO158T6HYP"
                }
            }
        }
    ]
}