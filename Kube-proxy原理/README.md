# kube-proxy 工作原理
kube-proxy 监听 API server 中 service 和 endpoint 的变化情况，并通过 userspace、iptables、ipvs 或 winuserspace 等 proxier 来为服务配置负载均衡（仅支持 TCP 和 UDP）。![kubeproxy.png](images/kube-proxy.png)

- kube-proxy 其实就是管理 Service 的访问入口，包括集群内 Pod 到 Service 的访问和集群外访问 Service；
- kube-proxy 管理 Service 的 Endpoints，该 Service 对外暴露一个 Virtual IP，也称为 Cluster IP, 集群内通过访问这个  Cluster IP:Port 就能访问到集群内对应的 Serivce 下的 Pod；
- Service 是通过 Selector 选择的一组 Pods 的服务抽象，其实就是一个微服务，提供了服务的 LB 和反向代理的能力，而 kube-proxy 的主要作用就是负责 Service 的实现；
- Service 一个重要作用就是，一个服务后端的 Pods 可能会随着生存灭亡而发生 IP 的改变，Service 的出现，给服务提供了一个固定的 IP，而无视后端 Endpoint 的变化，而这种关联的维护主要依赖 kube-proxy 实现；

二、kube-proxy 内部原理

       kube-proxy 当前实现了三种代理模式：userspace、iptables 以及 ipvs。

2.1  userspace 模式

       在这种模式下，kube-proxy 持续监听 Service 以及 Endpoints 对象的变化；

       对每个 Service，它都为其在本地节点开放一个端口，作为其服务代理端口；

       发往该端口的请求会采用一定的策略转发给与该服务对应的后端 Pod 实体。

kube-proxy 同时会在本地节点设置 iptables 规则，配置一个 Virtual IP， 把发往 Virtual IP 的请求重定向到与该 Virtual IP 对应的服务代理端口上。

其工作流程大体如下：



