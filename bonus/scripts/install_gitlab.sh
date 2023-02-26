#!/bin/bash

echo "Update system packages  -qq 2>/dev/null"
apt-get update
echo "===================[> Install GITLAB"
apt-get install -qq -y vim git wget curl locales locales-all
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get update
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo apt install -y gitlab-ce
sudo gitlab-ctl reconfigure
echo "===================[> Gitlab installation successfully done"
kubectl config view --raw  -o=jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode