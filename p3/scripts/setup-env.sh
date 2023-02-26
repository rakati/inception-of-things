#!/bin/bash

# 1. install docker

apt-get update

apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-cache policy docker-ce

apt-get install -y docker-ce docker-ce-cli containerd.io

## docker without sudo
newgrp docker

# Setup k3s
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# Setup k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# create new clusterl
k3d cluster create mycluster -p 8888:30014

# create namespaces
kubectl create namespace dev
kubectl create namespace argocd

kubectl apply -f app.yaml

# install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# argocd configuration
kubectl apply -f argocd.yaml

# get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Change the argocd-server service type to LoadBalancer:
nohup kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 2>&1 &
