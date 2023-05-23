# Zookeeper
https://zookeeper.apache.org/

## 下载安装包
```shell
mkdir /usr/local/zookeeper  
mkdir /usr/local/zookeeper/var  
mkdir /usr/local/zookeeper/var/log  
cd /usr/local/zookeeper  
wget http://apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
```

## 解压
```shell
tar -zxvf zookeeper-3.4.14.tar.gz
```

## 修改配置
```shell
cd /usr/local/zookeeper/zookeeper-3.4.14/conf  
cp zoo_sample.cfg zoo.cfg  
vim zoo.cfg
```  
注释
<pre> 
#dataDir=/tmp/zookeeper
</pre>  
添加
<pre>  
dataDir=/usr/local/zookeeper/var  
dataLogDir=/usr/local/zookeeper/var/log  
</pre>

## 启动，查看状态，停止，重启
```shell
cd /usr/local/zookeeper/zookeeper-3.4.14/bin
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

## 错误排查
```shell
cd /usr/local/zookeeper/zookeeper-3.4.14/bin  
cat zookeeper.out
```
