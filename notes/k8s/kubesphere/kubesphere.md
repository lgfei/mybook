# kubesphere采坑记

## etcd节点必须是奇数个，否则出现如下错误
<pre>
TASK [etcd : Gen_certs | run cert generation script] **************************************************************
Wednesday 03 June 2020 09:46:45 +0800 (0:00:00.389) 0:03:40.178 ********
fatal: [ts-dev-k8s-node-10-9-252-120 -> ts-dev-k8s-master-10-9-251-87]: FAILED! => {
"changed": true,
"cmd": [
"bash",
"-x",
"/usr/local/bin/etcd-scripts/make-ssl-etcd.sh",
"-f",
"/etc/ssl/etcd/openssl.conf",
"-d",
"/etc/ssl/etcd/ssl"
],
"delta": "0:00:00.010355",
"end": "2020-06-03 09:46:46.125081″,
"rc": 127,
"start": "2020-06-03 09:46:46.114726"
}

STDERR:

bash: /usr/local/bin/etcd-scripts/make-ssl-etcd.sh: No such file or directory

MSG:

non-zero return code
</pre>
## node节点的selinux需要手动禁用，否则node节点添加失败

## 提前下载镜像要在所有节点都下载，不只是taskbox

## jq安装问题
kubesphere安装错误信息
<pre> 
FAILED - RETRYING: KubeSphere| Installing JQ (YUM) (5 retries left)
# 手动安装jq错误信息
Error: Package: jq-1.6-1.el7.x86_64 (/jq-1.6-1.el7.x86_64)
           Requires: libonig.so.2()(64bit)
           Available: oniguruma-5.9.5-3.el7.x86_64 (centos-ceph-luminous)
               libonig.so.2()(64bit)
           Installed: oniguruma-6.7.0-1.el7.x86_64 (@centos-openstack-queens)
              ~libonig.so.4()(64bit)
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
</pre>

解决问题
```shell
rpm -qa |grep oniguruma
rpm -e oniguruma-6.7.0-1.el7.x86_64 --nodeps
yum install jq.x86_64 0:1.6-1.el7
```

## common.yml里面的
<pre>
FAILED - RETRYING: Metrics-Server | Waitting for v1beta1.metrics.k8s.io ready
</pre>

## metrics-server FailedDiscoveryCheck
查找到出问题的apiservice
```shell
kubectl get apiservice
```
删除出问题的apiservice
```shell
kubectl delete apiservice v1beta1.metrics.k8s.io
```

## kubesphere安装状态查看
```shell
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath={.items[0].metadata.name}) -f
```

## 从 Kubernetes 上卸载 KubeSphere
- [kubesphere-delete.sh](https://github.com/lgfei/mybook/tree/master/notes/k8s/kubesphere/kubesphere-delete.sh)

执行卸载脚本可能出现 namespce一直处于 Terminating 状态。以kubesphere-system为例
```shell
kubectl get ns kubesphere-system  -o json > kubesphere-system.json
```
编辑json文件，删除spec字段的内存，因为k8s集群时需要认证的
```shell
vi kubesphere-system.json
```
<pre>
# 将
    "spec": {
        "finalizers": [
            "kubernetes"
        ]
    },
# 改为
    "spec": {
    },
</pre>
 
新开一个窗口运行kubectl proxy跑一个API代理在本地的8081端口
```shell
kubectl proxy --port=8081
```
再回到当前窗口
```shell
curl -k -H "Content-Type:application/json" -X PUT --data-binary @kubesphere-system.json http://127.0.0.1:8081/api/v1/namespaces/kubesphere-system/finalize
```
再次查看命名空间
```shell
kubectl get ns
```