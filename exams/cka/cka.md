# CKA-Certified Kubernetes Administrator
https://www.cncf.io/certification/cka/

## Udemy笔记
https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/

### static pod
<组件名>-<节点主机名> 以这种命名出现的pod即为static pod <br>
例如：kube-apiserver，kube-controller-manager，kube-scheduler <br>
查看kubelet的配置文件
```shell
cat /var/lib/kubelet/config.yaml
```
查看配置项staticPodPath
```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 169.254.25.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionHard:
  memory.available: 5%
evictionMaxPodGracePeriod: 120
evictionPressureTransitionPeriod: 30s
evictionSoft:
  memory.available: 10%
evictionSoftGracePeriod:
  memory.available: 2m
featureGates:
  CSINodeInfo: true
  ExpandCSIVolumes: true
  RotateKubeletClientCertificate: true
  VolumeSnapshotDataSource: true
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
kubeReserved:
  cpu: 200m
  memory: 250Mi
maxPods: 110
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
systemReserved:
  cpu: 200m
  memory: 250Mi
volumeStatsAggPeriod: 0s
```
如上所示，表示在 /etc/kubernetes/manifests 目录下的组件为该节点的static pod, 会自动部署

### Dockerfile: ENTRYPOINT和CMD的区别
如果Dockerfile只定义了CMD，那么这个镜像在运行时可以覆盖CMD的内容，从而这个镜像可以不受限制的执行其他任务。  
如果定义了ENTRYPOINT，那么这个镜像启动时只能执行Dockerfile定义的命令，从而增强了镜像的安全性。
例如：  
Dockerfile1
```dockerfile
FROM ubuntu
CMD ["sleep", "5"]
```
Dockerfile2
```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep", "5"]
```
Dockerfile3
```dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"]
CMD ["5"]
```
加上Dockerfile1构建出来的镜像是 ubuntu:v1  
加上Dockerfile2构建出来的镜像是 ubuntu:v2  
加上Dockerfile3构建出来的镜像是 ubuntu:v3 
docker run ubuntu:v1 休眠5秒  
docker run ubuntu:v1 sleep 10 休眠10，原来的sleep 5被覆盖  
docker run ubuntu:v2 休眠5秒  
docker run ubuntu:v2 sleep 10 出错，实际执行的命令变成 sleep 5 sleep 10  
docker run ubuntu:v3 休眠5秒  
docker run ubuntu:v3 10 休眠10秒，CMD的内容被覆盖，实际执行的命令是sleep 10  

结论：CMD更灵活，ENTRYPOINT更安全，最好的方式是两者组合使用

### ConfigMap
```shell
kubectl create configmap <xxx-config> --from-literal=<key1>=<value1> --from-literal=<key2>=<value2>
```

### kubectl replace --force
当遇到 kube edit 不能保存时，会生成一个临时文件，kubectl replace --force 命令会先将原来的对象删除，然后再创建新的对象
```shell
kubectl replace --force -f /tmp/xxx.yaml
```

### Secret

#### base64 加解密
```shell
echo "明文" | base64
echo "密文" | base64 --decode
```
生成一个32字节的随机密钥并进行base64编码
```shell
head -c 32 /dev/urandom | base64
```
#### Encrypting Secret Data at Rest （静态加密 Secret 数据）
在没有启用Encrypting Secret Data at Rest时创建的Secret，虽然用kubectl查看是密文显示的，但实际在etcd中是明文存储的。 <br> 
验证及操作步骤详见：https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/ <br>
关键点:
- /etc/kubernetes/enc/enc.yaml
```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
      - configmaps
      - pandas.awesome.bears.example
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: <BASE 64 ENCODED SECRET>
      - identity: {}  # <-- identity 放在第一位表示解密
```
- /etc/kubernetes/manifests/kube-apiserver.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 10.10.30.4:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    ...
    - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml  # <-- add this line
    volumeMounts:
    ...
    - name: enc                           # <-- add this line
      mountPath: /etc/kubernetes/enc      # <-- add this line
      readonly: true                      # <-- add this line
    ...
  volumes:
  ...
  - name: enc                             # <-- add this line
    hostPath:                             # <-- add this line
      path: /etc/kubernetes/enc           # <-- add this line
      type: DirectoryOrCreate             # <-- add this line
  ...
```
- create secret
```shell
kubectl create secret generic mysecret -n default --from-literal=mykey=mydata
```
- 验证etcd是否加密存储
```shell
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/mysecret | hexdump -C
```
- 将所有secret重新写入
```shell
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

### 集群维护
驱逐节点上所有的pod
```shell
kubectl drain <node name> 
```
如果集群中已存在daemonsets
```shell
kubectl drain <node name> --ignore-daemonsets
```
如果这个节点上存在一个不是由deployment、replicaset等生成的pod，需要加上 --force，则这个pod将被强制删除且不会再其他节点重新创建
```shell
kubectl drain <node name> --force
```
禁用调度，保留节点上现有的pod
```shell
kubectl uncordon <node name>
```

### 升级集群
```shell
kubeadm upgrade plan
kubeadm upgrade apply <version>
kubeadm upgrade node
```

### 集群安全
#### TLS
- 对称加密：加解密使用同一个秘钥
- 非对称加密：用public-key加密，用private-key解密。（理论上也可以反过来用private-key加密，用public-key解密，但是通常public-key是公开的，这样的话就失去了非对称的意义了）
- CA机构：服务端向CA机构申请签名证书，然后将public-key和签名证书一起返回给客户端，确保客户端访问的服务器是合法的（防止钓鱼网站非法获取你的秘钥信息）。怎么验证CA机构的合法性呢？CA机构也会生成自己的秘钥对，客户端（例如：浏览器）会提前内置CA机构的public-key，这样客户端就能识别出服务器返回的证书是否合法。<br>
**在kubernetes中master节点充当CA server**
```shell
ssh-keygen
openssl genrsa -out server.key 2048
openssl rsa -in server.key -pubout > server.pem
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 3650
openssl x509 -noout -text -in server.crt
```

#### CertificateSigningRequest
- 第1步：创建私钥<br>
The following scripts show how to generate PKI private key and CSR. It is important to set CN and O attribute of the CSR. CN is the name of the user and O is the group that this user will belong to. You can refer to RBAC for standard groups.
````shell
openssl genrsa -out myuser.key 2048
openssl req -new -key myuser.key -out myuser.csr
````
- 第2步：将csr文件内容用base64编码输出
```shell
cat myuser.csr | base64 | tr -d "\n"
```
- 第3步：创建csr对象
```shell
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser
spec:
  request: <第2步输出的内容>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
EOF
```
- 第4步：审批
通过
```shell
kubectl certificate approve myuser
```
拒绝
```shell
kubectl certificate deny myuser
```
- 第5步：获取crt
```shell
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
```
- 第6步：赋予权限
创建角色
```shell
kubectl create role developer --verb=create --verb=get --verb=list --verb=update --verb=delete --resource=pods
```
为角色绑定用户
```shell
kubectl create rolebinding developer-binding-myuser --role=developer --user=myuser
```
- 第7步：添加至kubeconfig
add new credentials
```shell
kubectl config set-credentials myuser --client-key=myuser.key --client-certificate=myuser.crt --embed-certs=true
```
add the context
```shell
kubectl config set-context myuser --cluster=kubernetes --user=myuser
```
use then context
```shell
kubectl config use-context myuser
```

#### Notwork Policy
Calico 和 Flannel 应该怎么选？<br/>
答：Calico支持NetworkPlicy，而Flannel不支持。

#### imagePullSecrets
创建私钥仓库的token<br>
```shell
kubectl create secret -h

kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> 
--docker-email=<your-email>
```
使用token
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred
```

### 集群安装
#### kubeadm
- 第1步：准备机器，规划好master和worker节点，最低要求2核2G
- 第2步：在所有节点安装docker
- 第3步：在所有节点安装kubeadm
- 第4步：使用kubeadm init初始化master节点
- 第5步：安装网络插件
- 第6步：使用kubeadm join将worker节点加入集群

#### kube-proxy
```
- command:
  - /usr/local/bin/kube-proxy
  - --config=/var/lib/kube-proxy/config.conf
  - --hostname-override=$(NODE_NAME)
```
