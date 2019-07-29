# kube-proxy 工作原理
kube-proxy 监听 API server 中 service 和 endpoint 的变化情况，并通过 userspace、iptables、ipvs 或 winuserspace 等 proxier 来为服务配置负载均衡（仅支持 TCP 和 UDP）。![kubeproxy.png](0)
![kube-proxy-1](https://feisky.gitbooks.io/kubernetes/components/images/kube-proxy.png)
