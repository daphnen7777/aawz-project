#!/bin/bash

sudo apt update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -G docker ubuntu

sudo chmod 666 /var/run/docker.sock

cd /home/ubuntu
git clone https://github.com/daphnen7777/aws-azure-project.git

cd /home/ubuntu/aws-azure-project/mysql

docker build -t mysql:1.0 .

docker run -d --name mysql -p 3306:3306 --restart always mysql:1.0