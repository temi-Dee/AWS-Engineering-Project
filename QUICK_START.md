# Quick Start Guide

## 🎯 Setup Your Environment

### 1. Install AWS CLI

```bash
# Windows (PowerShell as Administrator):
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# macOS:
brew install awscli

# Linux:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

### 2. Configure AWS CLI

```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (us-east-1 recommended)
# - Default output format (json)

# Verify
aws sts get-caller-identity
```

### 3. Set Up Billing Alerts

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alarm \
  --alarm-description "Alert when charges exceed $10" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --dimensions Name=Currency,Value=USD \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

## 🚀 Start Your First Project

### Choose Your Starting Point

**Complete Beginner?** → Project 1 (Static Website)  
**Have AWS Experience?** → Project 6 (Terraform)  
**Experienced with Cloud?** → Project 12 (Kubernetes)

### Deploy a Project

```bash
# Navigate to project
cd "AWS Project 1 - Static Website S3 CloudFront"

# Read the README
cat README.md

# Follow instructions
# Deploy resources
# Test functionality
# ALWAYS clean up when done!
```

## 📚 Recommended Learning Path

### Week 1-2: Beginner Projects (1-5)
- **Time**: 2-3 hours per project
- **Focus**: AWS fundamentals, basic services
- **Projects**: Static website, EC2, Lambda, RDS, CI/CD

### Week 3-4: Intermediate Projects (6-11)
- **Time**: 3-4 hours per project
- **Focus**: IaC, containers, observability
- **Projects**: Terraform, Docker/ECS, logging, secrets, auto-scaling, event-driven

### Week 5-6: Advanced Projects (12-16)
- **Time**: 4-6 hours per project
- **Focus**: Kubernetes, GitOps, advanced deployments
- **Projects**: EKS, ArgoCD, observability stack, blue/green, security

### Week 7-8: Expert Projects (17-20)
- **Time**: 6-8 hours per project
- **Focus**: Multi-region, platform engineering, chaos, FinOps
- **Projects**: Global architecture, Backstage, FIS, cost optimization

## 💰 Cost Estimates

| Project Level | Estimated Cost | Duration |
|--------------|----------------|----------|
| Beginner (1-5) | $0-5 (Free Tier) | 2-3 hours each |
| Intermediate (6-11) | $5-15 | 3-4 hours each |
| Advanced (12-16) | $10-30 | 4-6 hours each |
| Expert (17-20) | $20-50 | 6-8 hours each |

**💡 Cost Saving Tips:**
- Use Free Tier eligible resources
- Always clean up after each project
- Use `t2.micro` or `t3.micro` instances
- Delete resources immediately after testing
- Set up billing alerts

## 🎓 Learning Tips

### 1. Document Everything
```bash
# Create a learning journal
mkdir my-aws-journey
cd my-aws-journey

# For each project, create notes
echo "# Project 1 Notes" > project-1-notes.md
echo "## What I Learned" >> project-1-notes.md
echo "## Challenges Faced" >> project-1-notes.md
echo "## Key Takeaways" >> project-1-notes.md
```

### 2. Take Screenshots
- Architecture diagrams you create
- AWS Console configurations
- Successful deployments
- Error messages (for troubleshooting practice)

### 3. Experiment
- Modify configurations
- Try different instance types
- Test failure scenarios
- Break things intentionally (in safe environments)

### 4. Build a Portfolio
- Create a GitHub repository
- Document your projects
- Share your learnings
- Include architecture diagrams

## 🔧 Common Issues and Solutions

### Issue: AWS CLI Not Configured
```bash
# Solution: Configure AWS CLI
aws configure
# Or check current configuration
aws configure list
```

### Issue: Permission Denied
```bash
# Solution: Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name YOUR_USERNAME
```

### Issue: Resources Already Exist
```bash
# Solution: Use unique names or clean up existing resources
aws s3 ls  # List existing S3 buckets
aws ec2 describe-instances  # List EC2 instances
```

### Issue: Costs Accumulating
```bash
# Solution: Check current charges
aws ce get-cost-and-usage \
  --time-period Start=2026-05-01,End=2026-05-04 \
  --granularity DAILY \
  --metrics BlendedCost

# Delete all resources from a project
# Follow the cleanup section in each project README
```

## 📖 Additional Resources

### AWS Documentation
- [AWS Getting Started](https://aws.amazon.com/getting-started/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

### Learning Platforms
- [AWS Skill Builder](https://skillbuilder.aws/)
- [AWS Workshops](https://workshops.aws/)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)

### Community
- [AWS Reddit](https://reddit.com/r/aws)
- [AWS re:Post](https://repost.aws/)
- [Stack Overflow - AWS Tag](https://stackoverflow.com/questions/tagged/amazon-web-services)

## ✅ Project Completion Checklist

For each project:
- [ ] Read the entire README before starting
- [ ] Understand the architecture
- [ ] Deploy all resources
- [ ] Test functionality
- [ ] Take notes and screenshots
- [ ] **Clean up ALL resources**
- [ ] Document lessons learned
- [ ] Move to next project

## 🎯 Certification Path

After completing these projects, you'll be well-prepared for:
- ✅ AWS Certified Solutions Architect - Associate
- ✅ AWS Certified Developer - Associate
- ✅ AWS Certified SysOps Administrator - Associate
- ✅ AWS Certified DevOps Engineer - Professional
- ✅ AWS Certified Solutions Architect - Professional

## 🚨 Important Reminders

1. **Always Clean Up**: Run cleanup commands after each project
2. **Monitor Costs**: Check AWS Billing Dashboard daily
3. **Use Free Tier**: Stick to Free Tier eligible resources when possible
4. **Set Billing Alerts**: Get notified before costs accumulate
5. **Don't Share Credentials**: Never commit AWS keys to Git
6. **Use IAM Roles**: Prefer IAM roles over access keys when possible

## 🎉 Ready to Start?

```bash
# Navigate to Project 1
cd "AWS Project 1 - Static Website S3 CloudFront"

# Read the README
cat README.md

# Start building!
```

**Good luck on your AWS learning journey! 🚀**

---

Need help? Open an issue in this repository or refer to the troubleshooting section in each project's README.
