# 准备工作
首先去官网下载**vagrant**和**VritualBox**，
vagrant是一款用于创建和部署虚拟化开发环境的软件，而VritualBox就是创建虚拟机



# 1.进入root账户
```
sudo passwd root
su root 
```

# 2.安装Docker kubelet kubeadm kubectl

```
echo  "deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main" >> /etc/apt/sources.list
apt-get update && apt-get install -y docker.io apt-transport-https curl kubelet kubeadm kubectl --allow-unauthenticated
```


#  3.设置hosts

```
sudo echo "192.168.8.170 master-1
192.168.9.173 worker-1
192.168.9.174 worker-2
192.168.9.175 worker-3" >> /etc/hosts
```
**这里要把IP和主机名字改成自己的**

# 4.关闭swap
```
swapoff -a
```

# 5.关闭防火墙
```
ufw disable
```

# 【1-5】直接部署
**以上5步我已经写好了vagrantfile文件，大家可以直接运行**
```
vagrant up
```
**就可以**



---




# 6.初始化init
```
kubeadm init \
--apiserver-advertise-address=192.168.8.170 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.15.0 \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16
```

**这里会生成token，要记录下来，类似于**

```
kubeadm join 192.168.8.170:6443 --token ufocob.upw1fa0fqfiuxego \
    --discovery-token-ca-cert-hash sha256:52011414517c40d3079c4ac5d8296f77d80a70b7c20ddbb69ddb73a4e8f9bf9b
```
# 7.添加flannel网络插件
kubectl apply -f https:# raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml


# 8.在worker节点使用token加入集群
```
kubeadm join 192.168.8.170:6443 --token ufocob.upw1fa0fqfiuxego \
    --discovery-token-ca-cert-hash sha256:52011414517c40d3079c4ac5d8296f77d80a70b7c20ddbb69ddb73a4e8f9bf9b
```


---



#如果执行kubeadm init时没有记录下加入集群的命令，可以通过以下命令重新创建
```
kubeadm token create --print-join-command
```

# 解决master节点可能出现的connection refused情况
```
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source ~/.bash_profile
```
# 解决worker节点可能出现的connection refused情况
**首先将master节点生成的/etc/kubernetes/admin.conf文件拷贝到worker节点的/etc/kubernetes/文件夹中然后执行以下命令**
```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

apt-get intsall python-pip
pip install --upgrade pip
pip install kubernetes
