# AWS Projects Deployment Guide

## Deployment Methods

This guide covers the three ways to deploy projects in this repository.

## Project Deployment Types

### Automated Scripts (Projects 1–7)

Each of these projects includes a `deploy.sh` (or equivalent) script and a matching `cleanup.sh`. Run the deploy script and it handles everything automatically.

| Project | Deploy Script | Cleanup Script |
|---------|--------------|----------------|
| **Project 1** | `deploy-website.sh` | `cleanup-website.sh` |
| **Project 2** | `deploy.sh` | `cleanup.sh` |
| **Project 3** | `deploy.sh` | *(follow README)* |
| **Project 4** | `deploy-rds.sh` | `cleanup-rds.sh` |
| **Project 5** | `setup-project.sh` + `configure-aws.sh` | `cleanup-aws.sh` |
| **Project 6** | `create-terraform-project.sh` then `terraform apply` | `terraform destroy` |
| **Project 7** | `create-docker-app.sh` then `docker-compose up` | `docker-compose down` |

### README-Based (Projects 8–20)

All code examples are complete and ready to copy-paste from each project's README file.

## Deployment Methods

### Method 1: Automated Scripts

```bash
cd "AWS Project 2 - Linux Server Setup on EC2"
bash deploy.sh
# Wait for completion
bash cleanup.sh  # When done
```

### Method 2: README Instructions

```bash
cd "AWS Project 8 - Centralized Logging"
cat README.md
# Follow step-by-step instructions
# Copy-paste code examples
```

### Method 3: Project Generators (Projects 6–7)

```bash
# Project 6 — Terraform
cd "AWS Project 6 - Infrastructure as Code"
bash create-terraform-project.sh
cd terraform-project
terraform init
terraform plan
terraform apply
terraform destroy  # Cleanup

# Project 7 — Docker + ECS
cd "AWS Project 7 - Containerize App"
bash create-docker-app.sh
cd docker-ecs-app
docker-compose up --build
docker-compose down  # Cleanup
```

### Method 4: CI/CD Hybrid (Project 5)

```bash
cd "AWS Project 5 - CI-CD Pipeline"
bash setup-project.sh github-username repo-name
bash configure-aws.sh github-username repo-name
# Push to GitHub to trigger CI/CD
bash cleanup-aws.sh  # When done
```

## Learning Path by Week

### Week 1–2: Beginner (Projects 1–5)
**Focus:** AWS fundamentals, basic services  
**Time:** 2–3 hours per project  
**Cost:** ~$10–20 total

1. Static Website (S3, CloudFront)
2. EC2 Linux Server
3. Serverless Contact Form
4. RDS Database
5. CI/CD Pipeline

### Week 3–4: Intermediate (Projects 6–11)
**Focus:** IaC, containers, observability  
**Time:** 3–4 hours per project  
**Cost:** ~$30–50 total

6. Terraform IaC
7. Docker + ECS
8. Centralized Logging
9. Secrets Management
10. Auto Scaling
11. Event-Driven Pipeline

### Week 5–6: Advanced (Projects 12–16)
**Focus:** Kubernetes, GitOps, advanced deployments  
**Time:** 4–6 hours per project  
**Cost:** ~$50–100 total

12. Kubernetes EKS
13. GitOps ArgoCD
14. Observability Stack
15. Blue/Green Deployments
16. Security Posture

### Week 7–8: Expert (Projects 17–20)
**Focus:** Multi-region, platform engineering, chaos, FinOps  
**Time:** 6–8 hours per project  
**Cost:** ~$100–200 total

17. Multi-Region Active-Active
18. Platform Engineering
19. Chaos Engineering
20. FinOps Cost Optimization

## Cost Management

Most projects cost under $5 if cleaned up within 24 hours.

### Cost-Saving Tips
1. Always run cleanup scripts after each project
2. Use `t2.micro` or `t3.micro` instances
3. Set a billing alarm (see QUICK_START.md)
4. Delete resources immediately after testing

### Estimated Monthly Cost (if left running 30 days)

| Level | Monthly Cost |
|-------|-------------|
| Beginner (1–5) | $5–10 |
| Intermediate (6–11) | $20–40 |
| Advanced (12–16) | $50–100 |
| Expert (17–20) | $100–300 |

## Prerequisites

See **QUICK_START.md** for detailed setup instructions.

**Required for all projects:**
- AWS account with administrative access
- AWS CLI installed and configured
- Basic command line knowledge

**Project-specific tools:**
- Terraform >= 1.5 (Project 6)
- Docker Desktop (Project 7)
- kubectl and helm (Projects 12–13)
- Node.js >= 18 (Project 5)
- eksctl (Project 12)

## Troubleshooting

**"Insufficient permissions"**
```bash
aws iam get-user
aws iam list-attached-user-policies --user-name YOUR_USERNAME
```

**"Resource already exists"**
```bash
# Run the project's cleanup script first, then re-deploy
bash cleanup.sh
```

**"Region not supported"**
```bash
# Use us-east-1 for maximum service availability
aws configure set region us-east-1
```

For more help, check the Troubleshooting section in each project's README.

## Best Practices

- Read the entire README before starting
- Follow steps in order — later steps often depend on earlier ones
- Save important outputs (resource IDs, ARNs, endpoint URLs)
- Test functionality before moving on
- **Always run cleanup scripts** — undeleted resources keep billing
- Verify resources are deleted in the AWS Console after cleanup

## Success Criteria

A project is complete when:
- All resources are deployed and functional
- You can explain what each component does and why
- Cleanup is done and you have verified no resources remain

---

**Ready to deploy? Choose a project and start building.**
