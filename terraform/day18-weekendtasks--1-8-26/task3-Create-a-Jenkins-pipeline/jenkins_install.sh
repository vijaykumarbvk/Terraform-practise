cat > jenkins_install.sh << 'EOF'
#!/bin/bash
set -e

apt-get update -y
apt-get install -y fontconfig openjdk-17-jre unzip

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  "https://pkg.jenkins.io/debian-stable binary/" | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update -y
apt-get install -y jenkins

curl -fsSL https://releases.hashicorp.com/terraform/1.10.0/terraform_1.10.0_linux_amd64.zip -o terraform.zip
unzip terraform.zip -d /usr/local/bin/
rm terraform.zip

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

systemctl enable jenkins
systemctl start jenkins
EOF