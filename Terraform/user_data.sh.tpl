#!/bin/bash
yum update -y
yum install -y docker aws-cli -y

systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user


aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com >> /var/log/ecr-login.log 2>&1

# Pull the image
docker pull ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/springboot-hello-app:${image_version} >> /var/log/docker-pull.log 2>&1


docker run -d -p 8080:8080 ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/springboot-hello-app:${image_version} >> /var/log/docker-run.log 2>&1
