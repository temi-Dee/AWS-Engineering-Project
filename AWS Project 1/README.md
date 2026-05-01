# SwiftRegister AWS Static Website

A beginner AWS Cloud engineering project that hosts a static website for a company registration agent using:

- Amazon S3 static website hosting
- Amazon CloudFront CDN
- AWS Certificate Manager (ACM) for HTTPS
- Amazon Route 53 custom domain DNS
- S3 bucket policies for public read access

## Project structure

- `index.html` — Home page
- `contact.html` — Contact page with email and WhatsApp options
- `css/styles.css` — Site styling
- `js/main.js` — Contact form behavior

## Website features

- Elegant layout and typography
- Hero image and service highlights
- WhatsApp contact button for direct chat
- Contact form that opens an email client
- Responsive design for desktop and mobile

## Manual AWS deployment guide

### Prerequisites

1. AWS account
2. Registered custom domain in Route 53 (for example `example.com`)
3. AWS CLI configured with `aws configure`
4. A unique S3 bucket name (for example `swiftregister-portfolio-12345`)

---

## Step 1: Create and configure the S3 bucket

1. Open the AWS Console and go to **S3**.
2. Create a new bucket with a globally unique name.
3. Disable **Block all public access** so the site can be served publicly.
4. In **Properties**, enable **Static website hosting**.
   - Select **Enable**
   - Index document: `index.html`
   - Error document: `index.html`
5. In **Permissions**, add this bucket policy to allow public read access:

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

Replace `YOUR_BUCKET_NAME` with your bucket name.

6. In the bucket's **Objects** section, upload the website files:

- `index.html`
- `contact.html`
- `css/styles.css`
- `js/main.js`

7. Confirm each object is publicly readable.

---

## Step 2: Test S3 website hosting

1. In the bucket **Properties**, copy the **Bucket website endpoint**.
2. Open it in your browser.
3. The site should load and show the homepage.

---

## Step 3: Request an ACM certificate for HTTPS

1. Open the AWS Console and go to **AWS Certificate Manager**.
2. Request a public certificate for your domain, for example:

- `example.com`
- `www.example.com`

3. Choose DNS validation and follow the instructions.
4. Validate the certificate once Route 53 adds the DNS records.

---

## Step 4: Create a CloudFront distribution

1. Open the AWS Console and go to **CloudFront**.
2. Create a new distribution:
   - Origin domain: your S3 bucket website endpoint, e.g. `YOUR_BUCKET_NAME.s3-website-us-east-1.amazonaws.com`
   - Viewer protocol policy: `Redirect HTTP to HTTPS`
   - Allowed HTTP methods: `GET, HEAD`
   - Alternate domain names (CNAMEs): `example.com`, `www.example.com`
   - SSL certificate: choose the ACM certificate you created
3. In **Default root object**, set: `index.html`
4. Save and create the distribution.

> Note: CloudFront may take several minutes to deploy.

---

## Step 5: Configure Route 53 DNS records

1. Open **Route 53** and select your hosted zone.
2. Create an **A record** for `example.com` using the CloudFront distribution alias.
3. Create an **A record** for `www.example.com` also using the CloudFront alias.
4. Ensure both records point to the CloudFront distribution.

---

## Step 6: Verify HTTPS and custom domain

1. Open `https://example.com` in your browser.
2. Confirm the site loads with a valid SSL certificate.
3. Test the contact page at `https://example.com/contact.html`.
4. Click the WhatsApp button and verify it opens the chat.

---

## Optional CLI deployment commands

If you prefer AWS CLI, you can upload your files with:

```powershell
aws s3 sync .\ "s3://YOUR_BUCKET_NAME" --exclude ".git/*"
```

To invalidate the CloudFront cache after updates:

```powershell
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/index.html" "/contact.html" "/css/*" "/js/*"
```

---

## Testing and validation

- Use the S3 website endpoint to confirm the static site is hosted.
- Verify the CloudFront domain returns HTTPS.
- Confirm the Route 53 custom domain resolves to CloudFront.
- Test the contact form by clicking the submit button and verifying your email client opens.
- Confirm the WhatsApp button opens the chat link.

## Notes

- Replace all placeholder values such as `YOUR_BUCKET_NAME`, `example.com`, and `+1 234 567 890` with your actual values.
- For production, use a real domain and valid WhatsApp phone number.

---

## Project goals covered

- AWS S3 static website hosting
- S3 bucket policy public read access
- CloudFront distribution with HTTPS
- ACM certificate validation
- Route 53 DNS records for a custom domain
- Static website design for a company registration agent
