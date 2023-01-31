#!bin/bash

set -x

#####JENKINS#####
sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo yum install git -y

######DOCKER######
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock
sudo setfacl --modify user::rw /var/run/docker.sock

#####HELM#####
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short
#####KUBECTL#####
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#####KIND####
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

echo "
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
- role: worker" >> cluster.yaml

kind create cluster --config cluster.yaml
sudo mkdir -p /var/lib/jenkins/.kube/
kind get kubeconfig > config
sudo cp config /var/lib/jenkins/.kube/config 
sudo chown -R jenkins: /var/lib/jenkins/ 
sudo chmod 600 /var/lib/jenkins/.kube/config
sudo cat /var/lib/jenkins/secrets/initialAdminPassword








