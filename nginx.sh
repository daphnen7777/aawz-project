#!/bin/bash

sudo apt update
sudo apt install -y git
sudo apt install -y aws-cli
mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -a -G docker ubuntu

sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release 

sudo chmod 666 /var/run/docker.sock

cd /home/ubuntu
git clone https://github.com/daphnen7777/aws-azure-project.git

cd /home/ubuntu/aws-azure-project/nginx

docker build -t nginx:1.0 .

# ECR 컨테이너 실행
docker run --name nginx -p 80:80 -d --restart always nginx:1.0