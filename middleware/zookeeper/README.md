# Zookeeper
https://zookeeper.apache.org/

## 下载安装包
```shell
mkdir -p /opt/zookeeper /opt/zookeeper/data /opt/zookeeper/dataLog
cd /opt/zookeeper  
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz --no-check-certificate
```
### 关于 --no-check-certificate
因为网站限制了只能用浏览器下载文件，如果不添加该参数可能会遇到以下问题。
- 错误1：
```text
ERROR: cannot verify apache.org's certificate, issued by ‘/C=US/O=Let's Encrypt/CN=R3’:
  Issued certificate has expired.
```
错误1可以通过下面的命令解决
```shell
yum install -y ca-certificates
```
- 错误2：
```text
Unable to establish SSL connection.
```
错误2可以通过添加代理参数user-agent解决，例如：
```shell
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz --user-agent="Mozilla/5.0 (X11;U;Linux i686;en-US;rv:1.9.0.3) Geco/2008092416 Firefox/3.0.3"
```

## 解压
```shell
tar -zxvf apache-zookeeper-3.8.3-bin.tar.gz
ln -s apache-zookeeper-3.8.3-bin zookeeper
```

## 修改配置
```shell
cd /opt/zookeeper/zookeeper/conf  
cp zoo_sample.cfg zoo.cfg  
vim zoo.cfg
```  
注释
```text
#dataDir=/tmp/zookeeper
``` 
添加
```text
dataDir=/opt/zookeeper/data
dataLogDir=/opt/zookeeper/dataLog 
```

## 启动，查看状态，停止，重启
```shell
cd /opt/zookeeper/zookeeper/bin
```
启动 
```shell 
./zkServer.sh start
```
查看状态 
```shell
./zkServer.sh status
```  
停止
```shell  
./zkServer.sh stop
```  
重启 
```shell 
./zkServer.sh restart  
```
查看日志
```shell
cd /opt/zookeeper/zookeeper/logs
```

## 客户端 zkCli.sh
```shell
cd /opt/zookeeper/zookeeper/bin
./zkCli.sh
```
执行上面的命令后，会进入对话框<br/>
查看目录
```shell
ls /
ls /zookeeper
ls /dubbo
get /dubbo
```
编辑目录
```shell
#创建了一个新的 znode 节点 zk 以及与它关联的字符串
create /zk "myData"
#修改值
set /zk "newVal"
#删除
delete /zk
```
