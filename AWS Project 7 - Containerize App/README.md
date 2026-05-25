# Project 7: Containerize Application with Docker and ECS

## Overview

Your multi-service application needs to be containerized and deployed in the cloud. You want to use Docker for consistency across environments and deploy to a scalable container orchestration platform. In this project you will create Docker images for a Node.js backend and an Nginx frontend, push them to Amazon ECR, and deploy them to Amazon ECS Fargate with an Application Load Balancer.

## Prerequisites

1. An AWS account with ECR and ECS permissions
2. Docker installed locally
3. AWS CLI configured with credentials
4. Node.js for local development
5. Basic understanding of Docker concepts
6. Git for version control

## Project Structure

```
app/
├── backend/
│   ├── server.js       # Express API server
│   ├── package.json
│   └── Dockerfile
├── frontend/
│   ├── index.html      # Static UI
│   ├── nginx.conf      # Nginx reverse-proxy config
│   └── Dockerfile
└── .github/
    └── workflows/
        └── docker-build.yml   # CI pipeline
```

## Steps

### Step 1: Build and Test Locally

```bash
# Build backend image
docker build -t backend-api:latest ./app/backend

# Build frontend image
docker build -t frontend-web:latest ./app/frontend

# Test backend locally
docker run -d -p 3000:3000 --name backend backend-api:latest
curl http://localhost:3000/health

# Test frontend locally (proxies /api/ to backend container)
docker network create app-net
docker run -d --network app-net --name backend backend-api:latest
docker run -d --network app-net -p 80:80 frontend-web:latest
curl http://localhost/api/data
```

### Step 2: Create Amazon ECR Repositories

```bash
REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ecr create-repository --repository-name backend-api  --region $REGION
aws ecr create-repository --repository-name frontend-web --region $REGION

BACKEND_REPO=$(aws ecr describe-repositories \
  --repository-names backend-api \
  --query 'repositories[0].repositoryUri' --output text)

FRONTEND_REPO=$(aws ecr describe-repositories \
  --repository-names frontend-web \
  --query 'repositories[0].repositoryUri' --output text)

echo "Backend:  $BACKEND_REPO"
echo "Frontend: $FRONTEND_REPO"
```

### Step 3: Push Images to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin \
    $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Tag and push backend
docker tag backend-api:latest $BACKEND_REPO:latest
docker push $BACKEND_REPO:latest

# Tag and push frontend
docker tag frontend-web:latest $FRONTEND_REPO:latest
docker push $FRONTEND_REPO:latest
```

### Step 4: Create ECS Cluster and Log Groups

```bash
aws ecs create-cluster --cluster-name my-app-cluster

aws logs create-log-group --log-group-name /ecs/backend-api
aws logs create-log-group --log-group-name /ecs/frontend-web
```

### Step 5: Create ECS Task Execution Role

```bash
cat > task-execution-trust.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ecs-tasks.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document file://task-execution-trust.json

aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### Step 6: Register Task Definitions

```bash
# Backend task definition
cat > backend-task-def.json << EOF
{
  "family": "backend-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
  "containerDefinitions": [{
    "name": "backend",
    "image": "${BACKEND_REPO}:latest",
    "portMappings": [{"containerPort": 3000, "protocol": "tcp"}],
    "environment": [
      {"name": "PORT", "value": "3000"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/backend-api",
        "awslogs-region": "${REGION}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
EOF

aws ecs register-task-definition --cli-input-json file://backend-task-def.json

# Frontend task definition
cat > frontend-task-def.json << EOF
{
  "family": "frontend-web",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
  "containerDefinitions": [{
    "name": "frontend",
    "image": "${FRONTEND_REPO}:latest",
    "portMappings": [{"containerPort": 80, "protocol": "tcp"}],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/frontend-web",
        "awslogs-region": "${REGION}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
EOF

aws ecs register-task-definition --cli-input-json file://frontend-task-def.json
```

### Step 7: Create Application Load Balancer

```bash
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' --output text)

SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].SubnetId' --output text)

# ALB security group
ALB_SG=$(aws ec2 create-security-group \
  --group-name alb-sg \
  --description "ALB Security Group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $ALB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0

# ECS tasks security group
ECS_SG=$(aws ec2 create-security-group \
  --group-name ecs-tasks-sg \
  --description "ECS Tasks Security Group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $ECS_SG --protocol tcp --port 3000 --source-group $ALB_SG
aws ec2 authorize-security-group-ingress \
  --group-id $ECS_SG --protocol tcp --port 80 --source-group $ALB_SG

# Create ALB
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name my-app-alb \
  --subnets $SUBNET_IDS \
  --security-groups $ALB_SG \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Create target groups
BACKEND_TG=$(aws elbv2 create-target-group \
  --name backend-tg \
  --protocol HTTP --port 3000 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-path /health \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

FRONTEND_TG=$(aws elbv2 create-target-group \
  --name frontend-tg \
  --protocol HTTP --port 80 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-path / \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

# Create listener (default -> frontend, /api/* -> backend)
LISTENER_ARN=$(aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP --port 80 \
  --default-actions Type=forward,TargetGroupArn=$FRONTEND_TG \
  --query 'Listeners[0].ListenerArn' --output text)

aws elbv2 create-rule \
  --listener-arn $LISTENER_ARN \
  --priority 10 \
  --conditions Field=path-pattern,Values='/api/*' \
  --actions Type=forward,TargetGroupArn=$BACKEND_TG
```

### Step 8: Create ECS Services

```bash
SUBNET_ARRAY=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].SubnetId' --output json)

# Backend service
aws ecs create-service \
  --cluster my-app-cluster \
  --service-name backend-service \
  --task-definition backend-api \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration \
    "awsvpcConfiguration={subnets=$SUBNET_ARRAY,securityGroups=[$ECS_SG],assignPublicIp=ENABLED}" \
  --load-balancers \
    "targetGroupArn=$BACKEND_TG,containerName=backend,containerPort=3000"

# Frontend service
aws ecs create-service \
  --cluster my-app-cluster \
  --service-name frontend-service \
  --task-definition frontend-web \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration \
    "awsvpcConfiguration={subnets=$SUBNET_ARRAY,securityGroups=[$ECS_SG],assignPublicIp=ENABLED}" \
  --load-balancers \
    "targetGroupArn=$FRONTEND_TG,containerName=frontend,containerPort=80"
```

### Step 9: Configure Auto Scaling

```bash
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/my-app-cluster/backend-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10

aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --resource-id service/my-app-cluster/backend-service \
  --scalable-dimension ecs:service:DesiredCount \
  --policy-name cpu-scaling-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleInCooldown": 300,
    "ScaleOutCooldown": 60
  }'
```

## CLI Automation

The `create-docker-app.sh` script scaffolds the full application directory and pushes images to ECR in one step:

```bash
bash create-docker-app.sh
cd docker-ecs-app
docker-compose up --build      # test locally
./deploy-to-ecs.sh             # push images to ECR
```

## Testing and Validation

```bash
# Get ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --load-balancer-arns $ALB_ARN \
  --query 'LoadBalancers[0].DNSName' --output text)

echo "Application URL: http://$ALB_DNS"

# Test frontend
curl -s http://$ALB_DNS | head -20

# Test backend via ALB path routing
curl -s http://$ALB_DNS/api/data

# Check service health
aws ecs describe-services \
  --cluster my-app-cluster \
  --services backend-service frontend-service \
  --query 'services[*].{Name:serviceName,Running:runningCount,Desired:desiredCount,Status:status}'

# Stream backend logs
aws logs tail /ecs/backend-api --follow
```

## Cleanup

```bash
# Scale services to 0 then delete
aws ecs update-service --cluster my-app-cluster --service backend-service  --desired-count 0
aws ecs update-service --cluster my-app-cluster --service frontend-service --desired-count 0
aws ecs delete-service --cluster my-app-cluster --service backend-service  --force
aws ecs delete-service --cluster my-app-cluster --service frontend-service --force

aws ecs delete-cluster --cluster my-app-cluster

aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
aws elbv2 delete-target-group --target-group-arn $BACKEND_TG
aws elbv2 delete-target-group --target-group-arn $FRONTEND_TG

aws ec2 delete-security-group --group-id $ALB_SG
aws ec2 delete-security-group --group-id $ECS_SG

aws ecr delete-repository --repository-name backend-api  --force
aws ecr delete-repository --repository-name frontend-web --force

aws logs delete-log-group --log-group-name /ecs/backend-api
aws logs delete-log-group --log-group-name /ecs/frontend-web
```

## Learning Objectives

After completing this project you will understand:

- Writing Dockerfiles for Node.js and Nginx services
- Building, tagging, and pushing images to Amazon ECR
- Defining ECS task definitions with Fargate launch type
- Creating ECS services with ALB load balancing
- Routing traffic to multiple containers via ALB listener rules
- Configuring container logs with CloudWatch Logs
- Implementing ECS service auto-scaling
- Using ECR lifecycle policies to manage image retention
