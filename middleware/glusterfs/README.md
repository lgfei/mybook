# glusterfs 安装使用

## 服务端安装

### 前置准备
至少准备两台节点，并修改主机名，假设主机名为 glusterfs-server01, glusterfs-server02
```shell
yum search centos-release-gluster
yum install centos-release-gluster41
```
```shell
vim /etc/hosts
```
<pre>
192.168.100.1 glusterfs-server01
192.168.100.2 glusterfs-server02
</pre>

### 安装
两台节点都需要执行
```shell
yum install glusterfs glusterfs-libs glusterfs-server
```

### 启动
```shell
systemctl enable glusterd
systemctl start glusterd
systemctl status glusterd
```

### 节点探测
在glusterfs-server01上执行
```shell
gluster peer probe glusterfs-server02
```
在glusterfs-server02上执行
```shell
gluster peer probe glusterfs-server01
```

### 创建数据卷
在两台上都执行
```shell
mkdir /data/glusterfs/storage_volume
```
在任意一台执行
```shell
gluster volume create storage_volume replica 2 glusterfs-server01:/data/glusterfs/storage_volume glusterfs-server02:/data/glusterfs/storage_volume
gluster volume start storage_volume
```
查是否启动成功
```shell
gluster volume list
gluster volume info
```

### 删除数据券
```shell
gluster volume stop storage_volume
storage_volume delete storage_volume
```

## 客户端使用

### 添加域名映射
```shell
vim /etc/hosts
```
<pre>
192.168.100.1 glusterfs-server01
192.168.100.2 glusterfs-server02
</pre>

### 安装glusterfs-fuse
```shell
yum install -y glusterfs-fuse
```

### 挂载
storage_volume：数据卷的名称，不是文件目录 <br>
/data/xxx：将服务端的文件挂载到客户的/data/xxx 目录下
```shell
mount -t glusterfs glusterfs-server01:/storage_volume /data/xxx
```

### 卸载
```shell
umount /data/xxx
```