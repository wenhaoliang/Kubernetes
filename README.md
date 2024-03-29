# 准备工作
首先去官网下载**vagrant**和**VritualBox**，
vagrant是一款用于创建和部署虚拟化开发环境的软件，而VritualBox就是虚拟机软件。

# 【1-4】直接部署
**以下4步我已经写好了vagrantfile文件，大家可以下载我上传的vagrantfile和setup.sh文件，然后直接运行**
```
vagrant up
```
**就可以自动化的生成对应的一台master节点和三台worker节点**


# 1.安装Docker kubelet kubeadm kubectl

```
echo  "deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main" >> /etc/apt/sources.list
apt-get update && apt-get install -y docker.io apt-transport-https curl kubelet kubeadm kubectl --allow-unauthenticated
```


#  2.设置hosts

```
echo "192.168.8.170 master1
192.168.8.171 worker1
192.168.8.172 worker2
192.168.8.173 worker3" >> /etc/hosts
```
**这里要把IP和主机名字改成自己的**

# 3.关闭swap
```
swapoff -a
```

# 4.关闭防火墙
```
ufw disable
```

---

# 接下来我们打开登陆自己的虚拟机，进入master节点

# 5.在master节点进入root账户
```
sudo passwd root
su root 
```

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
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

# 然后master节点的任务完成了，我们打开三台worker节点，并进入root账户
##  8.在worker节点使用token加入集群
```
kubeadm join 192.168.8.170:6443 --token ufocob.upw1fa0fqfiuxego \
    --discovery-token-ca-cert-hash sha256:52011414517c40d3079c4ac5d8296f77d80a70b7c20ddbb69ddb73a4e8f9bf9b
```
# 部署到此结束

---


