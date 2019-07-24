#/bin/sh


#关闭防火墙
sudo ufw disable


#swap
swapoff -a

#hosts
sudo echo "192.168.8.170 master-1
192.168.9.173 worker-1
192.168.9.174 worker-2
192.168.9.175 worker-3" >> /etc/hosts

sudo echo  "deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main" >> /etc/apt/sources.list
sudo apt-get update && apt-get install -y docker.io apt-transport-https curl kubelet kubeadm kubectl --allow-unauthenticated

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source ~/.bash_profile
