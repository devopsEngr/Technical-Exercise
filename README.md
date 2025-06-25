
# Spring Boot Hello App on AWS (Terraform + Docker)

This project is a complete infrastructure and application deployment that:
- Builds and packages a SpringBoot app with a '/hello' endpoint returning '200 OK'.
- Packages the app using Docker, pushes it to AWS ECR
- Provisions AWS infrastructure with Terraform
- Deploys app to EC2 (via Auto Scaling Group) in a private Subnet, fronted by a public ALB.

---


# Project Structure

```
.
├── src/main/java                   # Spring Boot Java source code
├── Dockerfile                      # Builds the Spring Boot JAR into a Docker image
├── terraform/
│   ├── main.tf                     # VPC, EC2 Launch Template, Auto Scaling Group
│   ├── alb.tf                      # Application Load Balancer & Target Group
│   ├── ec2_sg.tf                   # Security Groups for ALB and EC2
│   ├── iam.tf                      # IAM role for EC2 to pull ECR images and enable SSM
│   ├── output.tf                   # Terraform output values (e.g., ALB URL)
│   ├── variables.tf                # Input variables for reuse
│   └── user_data.sh.tpl            # Bootstrap script to pull and run Docker container
```

---

## ⚙️ Features

- **Spring Boot REST endpoint** at `/hello` returns `"OK"` and HTTP 200.
- Docker image is built using `buildx` and pushed to ECR:
  ```bash
  docker buildx build --platform linux/amd64 -t <ecr_repo>:latest --push .
  ```
- EC2 runs in **private subnet** for better security.
- Public traffic flows via **ALB**, which forwards to EC2 over port 8080.
- ALB performs **health checks** on `/hello`.

---

## 🔐 Security Best Practices Implemented

✅ EC2s are in **private subnet**, not exposed to internet  
✅ Only ALB in public subnet  
✅ **Security Groups** allow:
- Port 80: ALB ← Internet
- Port 8080: EC2 ← ALB only  
✅ No public IP on EC2  
✅ IAM role allows only:
- ECR pull (`AmazonEC2ContainerRegistryReadOnly`)
- SSM session (`AmazonSSMManagedInstanceCore`)  
✅ SSM access enabled – no SSH keys required  
✅ Minimal port exposure (no 22 for SSH)

---

## URL

Once deployed, your app is accessible at:

```
http://<alb_dns_name>/hello
```

Example:
```
http://web-app-alb-1775295125.ap-southeast-2.elb.amazonaws.com/hello
```

Returns:
```
OK
```

---

## How to Test

1. Open the ALB URL in your browser:  
   You’ll see `OK` if it's healthy.

2. From terminal:
   ```bash
   curl http://<alb_dns_name>/hello
   ```
