# AWS Cloud Engineering & DevOps — 20 Hands-On Projects

A self-paced, project-based learning path for anyone who wants to build real AWS and DevOps skills from scratch. Each project is a standalone, deployable exercise with step-by-step instructions, working code, and cleanup scripts.

**Who this is for:** Software engineers, sysadmins, or students who learn best by doing — not by watching videos. No prior AWS experience needed to start; by the end you will have hands-on practice with every major AWS service used in professional engineering roles.

**What you will have built after all 20 projects:**
- Deployed, globally distributed websites and APIs
- Automated infrastructure provisioned with Terraform
- Containerised applications running on ECS and EKS
- CI/CD pipelines with GitHub Actions
- Centralised logging, metrics, and alerting stacks
- Security automation, chaos experiments, and cost optimisation workflows

---

## Getting Started

See [QUICK_START.md](QUICK_START.md) for environment setup (AWS CLI, billing alerts, prerequisites).

**New to AWS?** Start at Project 1 and work forward in order.  
**Some AWS experience?** Jump to the level that matches your background using the table below.  
**Experienced?** Projects 12–20 cover Kubernetes, GitOps, observability, chaos engineering, and FinOps.

---

## Project Roadmap

### Beginner (Projects 1–5) — 1–2 weeks

Foundation projects covering core AWS services.

| # | Project | Key Services | Time |
|---|---------|-------------|------|
| 1 | [Static Website on S3 + CloudFront](./AWS%20Project%201%20-%20Static%20Website%20S3%20CloudFront) | S3, CloudFront, ACM, Route 53 | 1–2 hrs |
| 2 | [Linux Server Setup on EC2](./AWS%20Project%202%20-%20Linux%20Server%20Setup%20on%20EC2) | EC2, VPC, Security Groups, Nginx | 2–3 hrs |
| 3 | [Serverless Contact Form](./AWS%20Project%203%20-%20Serverless%20Contact%20Form) | Lambda, API Gateway, SES | 2–3 hrs |
| 4 | [RDS Database with Backups](./AWS%20Project%204%20-%20RDS%20Database) | RDS, Multi-AZ, CloudWatch | 2–3 hrs |
| 5 | [CI/CD Pipeline](./AWS%20Project%205%20-%20CI-CD%20Pipeline) | GitHub Actions, OIDC, S3 | 2–3 hrs |

### Intermediate (Projects 6–11) — 2–3 weeks

Infrastructure as Code, containers, and observability fundamentals.

| # | Project | Key Services | Time |
|---|---------|-------------|------|
| 6 | [Infrastructure as Code](./AWS%20Project%206%20-%20Infrastructure%20as%20Code) | Terraform, VPC, EC2, RDS modules | 3–4 hrs |
| 7 | [Containerise App](./AWS%20Project%207%20-%20Containerize%20App) | Docker, ECS, ECR, ALB | 3–4 hrs |
| 8 | [Centralised Logging](./AWS%20Project%208%20-%20Centralized%20Logging) | CloudWatch, CloudWatch Agent | 3–4 hrs |
| 9 | [Secrets Management](./AWS%20Project%209%20-%20Secrets%20Management) | Secrets Manager, Lambda rotation | 3–4 hrs |
| 10 | [Auto Scaling Web Tier](./AWS%20Project%2010%20-%20Auto%20Scaling%20Web%20Tier) | ALB, ASG, Launch Templates | 3–4 hrs |
| 11 | [Event-Driven Data Pipeline](./AWS%20Project%2011%20-%20Event-Driven%20Data%20Pipeline) | SQS, Lambda, S3, DynamoDB | 3–4 hrs |

### Advanced (Projects 12–16) — 3–4 weeks

Kubernetes, GitOps, observability, and enterprise deployment patterns.

| # | Project | Key Services | Time |
|---|---------|-------------|------|
| 12 | [Kubernetes on EKS](./AWS%20Project%2012%20-%20Kubernetes%20EKS) | EKS, Helm, HPA, PDB | 4–6 hrs |
| 13 | [GitOps with ArgoCD](./AWS%20Project%2013%20-%20GitOps%20ArgoCD) | ArgoCD, Helm, App-of-Apps | 4–6 hrs |
| 14 | [Full Observability Stack](./AWS%20Project%2014%20-%20Full%20Observability%20Stack) | Prometheus, Grafana, Loki | 4–6 hrs |
| 15 | [Blue/Green & Canary Deployments](./AWS%20Project%2015%20-%20Blue-Green%20Canary%20Deployments) | CodeDeploy, ALB, ECS | 4–6 hrs |
| 16 | [AWS Security Posture](./AWS%20Project%2016%20-%20AWS%20Security%20Posture) | GuardDuty, Security Hub, Config | 4–6 hrs |

### Expert (Projects 17–20) — 4–6 weeks

Multi-region architecture, platform engineering, chaos testing, and cost governance.

| # | Project | Key Services | Time |
|---|---------|-------------|------|
| 17 | [Multi-Region Active-Active](./AWS%20Project%2017%20-%20Multi-Region%20Active-Active) | Global Accelerator, DynamoDB Global Tables | 6–8 hrs |
| 18 | [Platform Engineering](./AWS%20Project%2018%20-%20Platform%20Engineering) | Backstage, Terraform modules, IDP | 6–8 hrs |
| 19 | [Chaos Engineering](./AWS%20Project%2019%20-%20Chaos%20Engineering) | AWS FIS, Chaos Mesh, steady-state monitoring | 6–8 hrs |
| 20 | [FinOps Cost Optimisation](./AWS%20Project%2020%20-%20FinOps%20Cost%20Optimization) | Cost Explorer, Budgets, tagging SCPs | 6–8 hrs |

---

## How Each Project Is Structured

```
AWS Project N - Name/
├── README.md          # Step-by-step guide, architecture, cleanup, troubleshooting
├── deploy*.sh         # Automated deployment (Projects 1–7)
├── cleanup*.sh        # Resource teardown
└── ...                # Application code, configs, Helm charts, Terraform, etc.
```

Projects 1–7 include fully automated deploy/cleanup scripts — run one command and the infrastructure is live. Projects 8–20 are README-driven: all CLI commands are complete and copy-pasteable.

---

## Deployment Quick Reference

```bash
# Automated projects (1–7)
cd "AWS Project 2 - Linux Server Setup on EC2"
bash deploy.sh
# ... test, learn, then:
bash cleanup.sh

# README-based projects (8–20)
cd "AWS Project 8 - Centralized Logging"
# Open README.md and follow the steps
```

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for full deployment methods and [APPLICATIONS_SUMMARY.md](APPLICATIONS_SUMMARY.md) for a complete list of every file in every project.

---

## Cost Management

- **Always run cleanup scripts** after finishing a project — leaving resources running is the most common source of unexpected charges
- Most projects cost under $5 if cleaned up within 24 hours
- Set a billing alarm before starting (see QUICK_START.md)
- Default region is `us-east-1` — change with `aws configure set region YOUR_REGION`

---

## Skills Covered

| Domain | Topics |
|--------|--------|
| Core AWS | EC2, S3, RDS, Lambda, VPC, IAM, CloudFront |
| Infrastructure as Code | Terraform modules, state management |
| Containers | Docker, ECS, ECR, EKS, Kubernetes |
| CI/CD | GitHub Actions, CodeDeploy, GitOps, ArgoCD |
| Observability | CloudWatch, Prometheus, Grafana, Loki |
| Security | GuardDuty, Security Hub, Secrets Manager, Config |
| SRE | Auto scaling, chaos engineering, SLI/SLO |
| FinOps | Cost Explorer, budgets, tagging, right-sizing |

---

## Certification Alignment

Completing these projects builds hands-on experience directly relevant to:

- AWS Certified Solutions Architect — Associate
- AWS Certified Developer — Associate
- AWS Certified SysOps Administrator — Associate
- AWS Certified DevOps Engineer — Professional

---

Start with [Project 1](./AWS%20Project%201%20-%20Static%20Website%20S3%20CloudFront) or jump to whichever level matches your experience.
