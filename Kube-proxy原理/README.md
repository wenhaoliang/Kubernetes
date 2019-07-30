# kube-proxy 工作原理

# 概念

Kubernetes 在每个节点上运行网络代理。这反映每个节点上 Kubernetes API 中定义的服务，并且可以做简单的 TCP 和 UDP 流转发或在一组后端中轮询，进行 TCP 和 UDP 转发。目前服务集群 IP 和端口通过由服务代理打开的端口 的 Docker-links-compatible 环境变量找到。有一个可选的为这些集群 IP 提供集群 DNS 的插件。用户必须 通过 apiserver API 创建服务去配置代理。

# 
一、**kube-proxy 监听 API server 中 service 和 endpoint 的变化情况，并通过 userspace、iptables、ipvs 或 winuserspace 等 proxier 来为服务配置负载均衡（仅支持 TCP 和 UDP）。
![kubeproxy.png](images/kube-proxy.png)**

- kube-proxy 其实就是管理 Service 的访问入口，包括集群内 Pod 到 Service 的访问和集群外访问 Service；
- kube-proxy 管理 Service 的 Endpoints，该 Service 对外暴露一个 Virtual IP，也称为 Cluster IP, 集群内通过访问这个  Cluster IP:Port 就能访问到集群内对应的 Serivce 下的 Pod；
- Service 是通过 Selector 选择的一组 Pods 的服务抽象，其实就是一个微服务，提供了服务的 LB 和反向代理的能力，而 kube-proxy 的主要作用就是负责 Service 的实现；
- Service 一个重要作用就是，一个服务后端的 Pods 可能会随着生存灭亡而发生 IP 的改变，Service 的出现，给服务提供了一个固定的 IP，而无视后端 Endpoint 的变化，而这种关联的维护主要依赖 kube-proxy 实现；

# 二、kube-proxy 内部原理
**kube-proxy 当前实现了三种代理模式：~~userspace、ipvs~~以及iptables，但是最新的实现方式是iptables方式，也是kube默认的方式。**

---
## 1、  userspace 模式

在这种模式下，kube-proxy 持续监听 Service 以及 Endpoints 对象的变化；
对每个 Service，它都为其在本地节点开放一个端口，作为其服务代理端口；
发往该端口的请求会采用一定的策略转发给与该服务对应的后端 Pod 实体。
kube-proxy 同时会在本地节点设置 iptables 规则，配置一个 Virtual IP，
把发往 Virtual IP 的请求重定向到与该 Virtual IP 对应的服务代理端口上。
其工作流程大体如下：
![Userspace.png](images/Userspace.png)

分析：该模式请求在到达 iptables 进行处理时就会进入内核，而 kube-proxy 监听则是在用户态，请求就形成了从用户态到内核态再返回到用户态的传递过程，一定程度降低了服务性能。


## 2、iptables 模式

kube-proxy 持续监听 Service 以及 Endpoints 对象的变化；
但它并不在本地节点开启反向代理服务，而是把反向代理全部交给 iptables 来实现；即 iptables 直接将对 VIP 的请求转发给后端 Pod，通过 iptables 设置转发策略。
其工作流程大体如下：
![iptables.png](images/iptables.png)

分析：该模式相比 userspace 模式，克服了请求在用户态-内核态反复传递的问题，性能上有所提升，但使用 iptables NAT 来完成转发，存在不可忽视的性能损耗，而且在大规模场景下，iptables 规则的条目会十分巨大，性能上还要再打折扣。


## 3、ipvs 模式

 与 iptables、userspace 模式一样，kube-proxy 依然监听 Service 以及 Endpoints 对象的变化；不过它并不创建反向代理，也不创建大量的 iptables 规则；而是通过 netlink 创建 ipvs 规则，并使用 k8s Service 与 Endpoints 信息，对所在节点的 ipvs 规则进行定期同步；netlink 与 iptables 底层都是基于 netfilter 钩子，但是 netlink 由于采用了 hash table 而且直接工作在内核态，在性能上比 iptables 更优。
![ipvs.png](images/ipvs.png)

分析：ipvs 是目前 kube-proxy 所支持的最新代理模式，相比使用 iptables，使用 ipvs 具有更高的性能。

