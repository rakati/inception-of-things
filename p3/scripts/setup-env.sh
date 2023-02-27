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
chmod 666 /var/run/docker.sock

# Setup k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=eth0 --write-kubeconfig-mode 644" sh -

# Setup k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# create new clusterl
k3d cluster create mycluster -p 8888:30014

# create namespaces
kubectl create namespace dev
kubectl create namespace argocd

# install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# argocd configuration
kubectl apply -f argocd.yaml

while ! kubectl -n argocd get secret argocd-initial-admin-secret; do echo "waiting for secret"; sleep 1; done

nohup kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 2>&1 &
# get password
echo -n "\n\nPassword is: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo