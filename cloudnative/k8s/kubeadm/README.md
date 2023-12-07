# kubeadm安装高可用k8s集群过程

## 机器准备 
```text
系统内核3.10以上，建议至少2核2G  
如果只是试验，可以只用1台mater,1台node。生产环境一般需要多master（至少3台），实现高可用   
此次我试验的架构如下：  
Kubernetes: v1.15.3  
Docker-ce: 18.06.1 
Keepalived保证apiserever服务器的IP高可用  
Haproxy实现apiserver的负载均衡 
```

| 节点名称 | 角色 | IP | 安装的软件 |
| --|:--:|:--|:--|
| 负载VIP | VIP | 192.168.1.200 | 不是一台真实的机器，是一个与master同网段未被占用的虚拟IP |
| master-01 | master | 192.168.1.101 | kubeadm、kubelet、kubectl、etcd、docker、haproxy、keepalived、ipvsadm |
| master-02 | master | 192.168.1.102 | kubeadm、kubelet、kubectl、etcd、docker、haproxy、keepalived、ipvsadm |
| master-03 | master | 192.168.1.103 | kubeadm、kubelet、kubectl、etcd、docker、haproxy、keepalived、ipvsadm |
| node-01 | node | 192.168.1.104 | kubeadm、kubelet、kubectl、docker、ipvsadm |
| node-02 | node | 192.168.1.105 | kubeadm、kubelet、kubectl、docker、ipvsadm |
| node-03 | node | 192.168.1.106 | kubeadm、kubelet、kubectl、docker、ipvsadm |

## 机器初始化配置
***注: 没有特别说明的，表示每台机器都要执行***
1. 关闭防火墙
    ```shell
    systemctl disable firewalld
    systemctl stop firewalld
    ```

2. 禁用selinux
    ```shell
    sed -ri 's#(SELINUX=).*#\1disabled#' /etc/selinux/config
    setenforce 0
    ```

3. 关闭swap
    ```shell
    swapoff -a
    ```

4. 添加hosts
    ```shell
    cat >>/etc/hosts<<EOF
    192.168.1.101 master-01
    192.168.1.102 master-02
    192.168.1.103 master-03
    192.168.1.104 node-01
    192.168.1.105 node-02
    192.168.1.106 node-03
    EOF
    ```

5. 在master-01上创建ssh秘钥，并分发给其他节点，方便从master上复制文件到其他节点
    ```shell
    cd ~
    ssh-keygen -t rsa
    ssh-copy-id master-02
    ssh-copy-id master-03
    ...
    ```

6. 配置内核参数
    ```shell
    cat <<EOF >  /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_nonlocal_bind = 1
    net.ipv4.ip_forward = 1
    vm.swappiness=0
    EOF
    sysctl --system
    ```

7. 加载ipvs模块（ipvs比iptables性能好）
    ```shell
    cat > /etc/sysconfig/modules/ipvs.modules <<EOF
    #!/bin/bash
    modprobe -- ip_vs
    modprobe -- ip_vs_rr
    modprobe -- ip_vs_wrr
    modprobe -- ip_vs_sh
    modprobe -- nf_conntrack_ipv4
    EOF
    chmod 755 /etc/sysconfig/modules/ipvs.modules
    bash /etc/sysconfig/modules/ipvs.modules
    lsmod | grep -e ip_vs -e nf_conntrack_ipv4
    ```

8. 安装ipvsadm
    ```shell
    yum install -y ipvsadm
    ipvsadm-save -n > /etc/sysconfig/ipvsadm
    systemctl enable ipvsadm
    systemctl start ipvsadm
    ```

## 部署keepalived和haproxy
***注: 只要在3台master节点部署***
1. 安装keepalived和haproxy
    ```shell
    yum install -y keepalived haproxy
    ```

2. 修改keepalived配置/etc/keepalived/keepalived.conf<br>
***注: master-01的priority 100，master-02的priority 99 ，master-03的priority 98***
      ```text
      global_defs {
        router_id csapiserver
      }
      vrrp_script chk_haproxy {
          script "killall -0 haproxy"
          interval 2
          weight 2
      }
      vrrp_instance VI_1 {
          state MASTER
          interface eth0
          virtual_router_id 51
          priority 100
          advert_int 1
          authentication {
              auth_type PASS
              auth_pass 1111
          }
          virtual_ipaddress {
              192.168.1.200
          }
          track_script {
              chk_haproxy
          }
      }
      ```

3. 修改haproxy配置/etc/haproxy/haproxy.cfg
    ```haproxy
    global
        daemon
        nbproc    4
        user      haproxy
        group     haproxy
        maxconn   50000
        pidfile   /var/run/haproxy.pid
        log       127.0.0.1   local0
        chroot    /var/lib/haproxy
    defaults
        log       global
        log       127.0.0.1   local0
        maxconn   50000
        retries   3
        balance   roundrobin
        option    httplog
        option    dontlognull
        option    httpclose
        option    abortonclose
        timeout   http-request 10s
        timeout   connect 10s
        timeout   server 1m
        timeout   client 1m
        timeout   queue 1m
        timeout   check 5s
    listen stats :1234
        stats     enable
        mode      http
        option    httplog
        log       global
        maxconn   10
        stats     refresh 30s
        stats     uri /
        stats     hide-version
        stats     realm HAproxy
        stats     auth admin:admin@haproxy
        stats     admin if TRUE
    listen kube-api-lb
        bind      0.0.0.0:8443
        balance   roundrobin
        mode      tcp
        option    tcplog
        server    master-01 192.168.1.101:6443 weight 1 maxconn 10000 check inter 10s rise 2 fall 3
        server    master-02 192.168.1.102:6443 weight 1 maxconn 10000 check inter 10s rise 2 fall 3
        server    master-03 192.168.1.103:6443 weight 1 maxconn 10000 check inter 10s rise 2 fall 3
    ```

4. 启动服务
    ```shell
    systemctl enable keepalived && systemctl start keepalived 
    systemctl enable haproxy && systemctl start haproxy 
    ```

## 安装docker
***注: 每台机器都安装***
1. 添加yum源
    ```shell
    cd /etc/yum.repos.d/
    wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    ```

2. 安装docker
    ```shell
    yum list docker-ce.x86_64 --showduplicates | sort -r
    yum -y install docker-ce-18.06.1.ce-3.el7
    ```
3. 根据自己的情况修改/etc/docker/daemon.json
没有这个文件则新建，也可以没有这个文件，则按默认配置启动docker
    ```json
    {
      "registry-mirrors": ["https://iljr3exx.mirror.aliyuncs.com"],
      "insecure-registries":["registry.topmall.com:5000","hub.wonhigh.cn"],
      "disable-legacy-registry": true,
      "bip":"192.168.5.1/24"
    }
    ```

4. 启动
    ```shell
    systemctl enable docker && systemctl start docker
    docker version
    ```

5. 常用操作
    - 删除所有没有启用的镜像
      ```shell
      docker system prune --volumes -a -f
      ```
    - 删除所有none标签的镜像
      ```shell
      docker rmi $(docker images | grep none | awk '{print $3}')
      ```
    - 删除已退出的所有容器
      ```shell
      docker rm `docker ps -a | grep Exited | awk '{print $1}'`
      ```

## 部署kubernetes
1. 添加yum源
    ```shell
    cat << EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF
    ```

2. 每台机都安装kubelet，kubectl，kubeadm
    ```shell
    yum install -y kubelet-1.15.3 kubeadm-1.15.3 kubectl-1.15.3
    ```

3. 编辑kubeadm初始化yaml文件[kubeadm-init.yaml](https://github.com/lgfei/mybook/blob/master/notes/k8s/kubeadm/kubeadm-init.yml)
    - advertiseAddress: 192.168.1.101
    - kubernetesVersion: v1.15.3
    - service-node-port-range: 3000-39999
    - apiServer
      ```yml
      apiServer:
        extraArgs:
          service-node-port-range: 3000-39999
        CertSANs:
        - 192.168.1.101
        - 192.168.1.102
        - 192.168.1.103
        - master-01
        - master-02
        - master-03
      controlPlaneEndpoint: 192.168.1.200:8443
      ```
    - networking
      ```yml
      networking:
        dnsDomain: cluster.local
        serviceSubnet: 100.96.0.0/12
        podSubnet: 100.244.0.0/16
      ```

4. 预下载镜像
    ```shell
    kubeadm config images pull --config kubeadm-init.yaml
    ```

5. 初始化
    ```shell
    kubeadm init --config kubeadm-init.yaml
    ```
    初始化成功会输出如下日志信息，注意保存
    ```text
    [init] Using Kubernetes version: v1.15.3
    [preflight] Running pre-flight checks
      [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Activating the kubelet service
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [master-01 localhost] and IPs [192.168.1.101 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [master-01 localhost] and IPs [192.168.1.101 127.0.0.1 ::1]
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    [certs] apiserver serving cert is signed for DNS names [master-01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [100.96.0.1 10.234.9.126 192.168.1.200]
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    [kubelet-check] Initial timeout of 40s passed.
    [apiclient] All control plane components are healthy after 40.509663 seconds
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node suzhou-tsc-k8s-master-10-234-9-126-vm.belle.lan as control-plane by adding the label "node-role.kubernetes.io/master=''"
    [mark-control-plane] Marking the node suzhou-tsc-k8s-master-10-234-9-126-vm.belle.lan as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
    [bootstrap-token] Using token: jtkhrx.w9w6u0s8stpaianz
    [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    [addons] Applied essential addon: CoreDNS
    [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
    [addons] Applied essential addon: kube-proxy

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
      https://kubernetes.io/docs/concepts/cluster-administration/addons/

    You can now join any number of control-plane nodes by copying certificate authorities 
    and service account keys on each node and then running the following as root:

      kubeadm join 192.168.1.200:8443 --token jtkhrx.w9w6u0s8stpaianz \
        --discovery-token-ca-cert-hash sha256:11902c4de08e89cd7d2da1d7543e086720061ce48acf5ce48fec1f825c8aef44 \
        --control-plane

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 192.168.1.200:8443 --token jtkhrx.w9w6u0s8stpaianz \
        --discovery-token-ca-cert-hash sha256:11902c4de08e89cd7d2da1d7543e086720061ce48acf5ce48fec1f825c8aef44
    ```
    - [init]：指定版本进行初始化操作
    - [preflight] ：初始化前的检查和下载所需要的Docker镜像文件
    - [kubelet-start] ：生成kubelet的配置文件”/var/lib/kubelet/config.yaml”，没有这个文件kubelet无法启动，所以初始化之前的kubelet实际上启动失败。
    - [certificates]：生成Kubernetes使用的证书，存放在/etc/kubernetes/pki目录中。
    - [kubeconfig] ：生成 KubeConfig 文件，存放在/etc/kubernetes目录中，组件之间通信需要使用对应文件。
    - [control-plane]：使用/etc/kubernetes/manifest目录下的YAML文件，安装 Master 组件。
    - [etcd]：使用/etc/kubernetes/manifest/etcd.yaml安装Etcd服务。
    - [wait-control-plane]：等待control-plan部署的Master组件启动。
    - [apiclient]：检查Master组件服务状态。
    - [uploadconfig]：更新配置
    - [kubelet]：使用configMap配置kubelet。
    - [patchnode]：更新CNI信息到Node上，通过注释的方式记录。
    - [mark-control-plane]：为当前节点打标签，打了角色Master，和不可调度标签，这样默认就不会使用Master节点来运行Pod。
    - [bootstrap-token]：生成token记录下来，后边使用kubeadm join往集群中添加节点时会用到
    - [addons]：安装附加组件CoreDNS和kube-proxy

6. 为kubectl准备Kubeconfig文件
    ```shell
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    ```

7. 添加master节点
    - 将master-01的k8s证书复制到master-02，master-03
      ```shell
      USER=root
      CONTROL_PLANE_IPS="master-02 master-03"
      for host in ${CONTROL_PLANE_IPS}; do
          ssh "${USER}"@$host "mkdir -p /etc/kubernetes/pki/etcd"
          scp /etc/kubernetes/pki/ca.* "${USER}"@$host:/etc/kubernetes/pki/
          scp /etc/kubernetes/pki/sa.* "${USER}"@$host:/etc/kubernetes/pki/
          scp /etc/kubernetes/pki/front-proxy-ca.* "${USER}"@$host:/etc/kubernetes/pki/
          scp /etc/kubernetes/pki/etcd/ca.* "${USER}"@$host:/etc/kubernetes/pki/etcd/
          scp /etc/kubernetes/admin.conf "${USER}"@$host:/etc/kubernetes/
      done
      ```
    - 加入集群
      ```shell
      kubeadm join 192.168.1.200:8443 --token jtkhrx.w9w6u0s8stpaianz \
        --discovery-token-ca-cert-hash sha256:11902c4de08e89cd7d2da1d7543e086720061ce48acf5ce48fec1f825c8aef44 \
        --control-plane
      ```

8. 添加node节点(node-01,node-02,node-03)<br>
***注: 和master节点的区别在于 --control-plane***
    - 加入集群
      ```shell
      kubeadm join 192.168.1.200:8443 --token jtkhrx.w9w6u0s8stpaianz \
          --discovery-token-ca-cert-hash sha256:11902c4de08e89cd7d2da1d7543e086720061ce48acf5ce48fec1f825c8aef44
      ```
    - 将master节点的/etc/kubernetes/admin.conf复制到相同的目录后，执行
      ```shell
      mkdir -p $HOME/.kube
      cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      chown $(id -u):$(id -g) $HOME/.kube/config
      ```

9. 查看集群状态  
    ```shell
    kubectl version
    kubectl get cs  //1.6版本 kubectl get cs 已废弃
    ```
    ```text
    NAME                 STATUS    MESSAGE             ERROR
    scheduler            Healthy   ok                  
    controller-manager   Healthy   ok                  
    etcd-0               Healthy   {"health":"true"} 
    ```
    ```shell
    kubectl get nodes
    ```
    ```text
    NAME        STATUS      ROLES    AGE     VERSION
    master-01   NotReady    master   2d18h   v1.15.3
    master-02   NotReady    master   2d17h   v1.15.3
    master-03   NotReady    master   2d5h    v1.15.3
    node-01     NotReady    node     2d5h    v1.15.3
    node-01     NotReady    node     2d17h   v1.15.3
    node-01     NotReady    node     2d17h   v1.15.3
    ```

10. 重新生成token <br/>
    当出现error execution phase preflight: couldn't validate the identity of the API Server: abort connecting to API servers after timeout of 5m0s时，
    表示token失效（集群注册token的有效时间为24小时），可以通过下面的命名重新生成token
    ```shell
    kubeadm token create
    ```
    如果忘记了sha256，可以通过如下命令查看
    ```shell
    openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
    ```
    生成token后可以用下面的命令组装出新的join命令
    ```shell
    kubeadm token create <新的token> --print-join-command --ttl=0
    ```
    也可以直接一步到位，用下面的命令生成新的join命令
    ```shell
    kubeadm token create --print-join-command
    ```

11. 部署flannel或者calico<br>
***注: 部署任何组件，一定不要直接用网上下载的yaml文件部署，一定要下载下来仔细对比，修改相应配置项，类似于*** 
    ```shell
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    ``` 
    上一步结束后，看到节点的状态是NotReady，是因为还没部署网络插件<br>
    - 修改kube-flannel.yml文件内容：[kube-flannel.yml](https://github.com/lgfei/mybook/blob/master/notes/k8s/kubeadm/kube-flannel.yml)<br>
    需要修改的地方<br>
    net-conf.json
      ```text
        net-conf.json: |
          {
            "Network": "100.244.0.0/16", # 和kubeadm-init.yml中设置的podSubnet一致
            "Backend": {
              "Type": "vxlan"
            }
          }
      ```
      flannel插件部署成功后，所有节点的状态会依次变成Ready
    - 部署calico出现 ***BIRD is not ready: BGP not established：xxx*** <br/>
      修改calico.yaml 配置文件，将 IP_AUTODETECTION_METHOD 环境变量改成指定的网卡（我环境里的网卡名是：eth0），如下所示：
      ```shell
      kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=eth0
      ```

12. kubectl常用命令
    - 标签管理
      ```shell
      kubectl label nodes node-01 node-role.kubernetes.io/node=            // 标记为node节点
      kubectl label nodes node-01 k8s.lgfei.com/namespace=dev              // 添加标签
      kubectl label nodes node-01 k8s.lgfei.com/namespace=prd --overwrite  // 修改标签
      kubectl label nodes node-01 k8s.lgfei.com/namespace-                 // 删除标签
      ```
    - 组件管理
      ```shell
      kubectl get cs
      kubectl get nodes --show-labels
      kubectl get ns
      kubectl get pods --all-namespaces
      kubectl get svc
      kubectl get deployment
      kubectl get configmaps
      kubectl describe pod xxx
      kubectl delete pod xxx
      kubectl delete pods xxx --grace-period=0 --force  // 强制删除
      ...
      ```

## 重新初始化
***除了第一步，其他步骤可视情况而定，重新初始化之后的步骤请参考上面安装步骤***
1. 重新初始化k8s
    ```shell
    kubeadm reset
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
    ipvsadm --clear
    ```

2. 卸载docker
    ```shell
    systemctl stop docker
    yum installed list | grep docker
    yum erase docker \
              docker-client \
              docker-client-latest \
              docker-common \
              docker-latest \
              docker-latest-logrotate \
              docker-logrotate \
              docker-selinux \
              docker-engine-selinux \
              docker-engine \
              docker-ce
    ```

3. 卸载虚拟网卡
    ```shell
    ifconfig
    ifconfig cni0 down
    ip link delete cni0
    ifconfig flannel.1 down 
    ip link delete flannel.1
    ifconfig tunl0 down 
    ip link delete tunl0
    rm -rf /var/lib/cni/
    rm -f /etc/cni/net.d/*
    ```

4. 如果你要升级kubelet而发现kubelet版本一直是旧版本的时候，则需要手动删除kubelet
    ```shell
    whereis kubelet
    ```
    会出现如下信息，手动删除文件，再重新安装
    ```text
    kubelet: /usr/bin/kubelet /root/local/bin/kubelet
    ```

## 证书续签
kubeadm默认的证书有效期是1年，证书过期之后，会导致kubectl命令不可用
1. 先备份
    ```shell
    cp -rp /etc/kubernetes /etc/kubernetes.bak
    cp -r /var/lib/etcd /var/lib/etcd.bak
    ```

2. 查看证书有效期
    - 单个文件查看
      ```shell
      openssl x509 -in /etc/kubernetes/ssl/apiserver.crt -noout -text |grep ' Not '
      ```
    - 批量查看
      ```shell
      for item in `find /etc/kubernetes/ssl -maxdepth 2 -name "*.crt"`;
      do 
          openssl x509 -in $item -text -noout| grep Not;
          echo ======================$item===============;
      done
      ```
      或者
      ```shell
      for item in `find /etc/kubernetes/pki -maxdepth 2 -name "*.crt"`;
      do 
          openssl x509 -in $item -text -noout| grep Not;
          echo ======================$item===============;
      done
      ```

3. 生成集群配置文件
    ```shell
    kubeadm config view > ./cluster.yaml
    ```

4. 手工修改kubeadm生成证书的有效时间
***默认一年，不想修改则跳过***
    - 查看当前kubeadm版本
      ```shell
      kubeadm version
      ```
    - 修改源码 <br/>
    下载kubernetes源码，找到对应版本的源码[源码地址](https://github.com/kubernetes/kubernetes.git)
      ```text
      文件路径cmd\kubeadm\app\constants\constants.go
      第46行  CertificateValidity = time.Hour * 24 * 365  修改为   CertificateValidity = time.Hour * 24 * 365 * 10
      ```
    - 重新编译
      ```shell
      cd  /xxx/kubernetes
      make WHAT=cmd/kubeadm GOFLAGS=-v
      ```
    - 编译完成后会有新的kubeadm命令文件
      ```shell
      cd _output/bin/
      cp kubeadm /usr/local/bin/
      ```

5. 证书续期
    - 如果使用的k8s容器etcd集群模式，则直接用下面命令生成新的证书
      ```shell
      kubeadm alpha certs renew all --config=./cluster.yaml
      ```
    - 如果你使用的是ectd外部集群模式，则要按文件分别处理
      ```shell
      kubeadm alpha certs renew admin.conf
      kubeadm alpha certs renew controller-manager.conf --config ./cluster.yaml
      kubeadm alpha certs renew scheduler.conf
      kubeadm alpha certs renew apiserver-kubelet-client --config ./cluster.yaml
      kubeadm alpha certs renew apiserver --config ./cluster.yaml
      kubeadm alpha certs renew front-proxy-client --config ./cluster.yaml
      ```
    - 查看续期结果
      ```shell
      kubeadm alpha certs check-expiration --config cluster.yaml
      ```

6. 重新生成配置文件
    ```shell
    kubeadm init phase kubeconfig all --config=./cluster.yaml
    ```

7. 重启kubelet、apiserver、controller-manager、scheduler、etcd
    ```shell
    docker ps | grep -E 'k8s_kube-apiserver|k8s_kube-controller-manager|k8s_kube-scheduler|k8s_etcd_etcd' | awk -F ' ' '{print $1}' |xargs docker restart
    ```