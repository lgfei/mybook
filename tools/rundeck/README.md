# rundeck 
* [开源地址](https://github.com/rundeck/rundeck) 
* [官网地址](http://rundeck.org/) 
* [下载路径](https://docs.rundeck.com/downloads.html)  

## 安装部署
先安装jdk
```shell
cd /usr/local
mkdir rundeck
```
将下载好的rundeck-3.0.23-20190619.war上传到/usr/local/rundeck
```shell
java -jar rundeck-3.0.23-20190619.war
```
此时会生成如下几个目录
* etc：存储RunDeck使用的到的框架配置信息，如日志框架log4j，以及指定其他所有配置的磁盘存储路径，如以上所示目录，都可在etc中的配置文件指定
* libext: 存储插件依赖jar
* projects：存储新建的项目信息，包括项目节点信息等
* server：存储RunDeck配置信息（用户体系，数据库连接）。RunDeckserver本身的日志信息、项目元数据库信息、webui项目信息、web容器的依赖（jetty）
* tools：存放项目依赖的jar包，相关指令集
* var:存放远程主机key信息，如ssh的密码，服务私钥。保存新建项目的日志信息，生命周期数据等。存储项目节点资源模型缓存信息，等

## 修改配置
修改host,port,url
```shell
vim $RUNDECK_HOME/etc/framework.properties
```
修改为
<pre>
framework.server.name = yourip
framework.server.hostname = yourip
framework.server.port = 4440
framework.server.url = http://yourip:4440
</pre>

使用mysql做数据存储
```shell
vim $RUNDECK_HOME/server/config/rundeck-config.properties
```
修改前
<pre>
dataSource.url = jdbc:h2:file:/usr/local/rundeck/server/data/grailsdb;MVCC=true
</pre>
修改后
<pre>
#dataSource.url = jdbc:h2:file:/usr/local/rundeck/server/data/grailsdb;MVCC=true
dataSource.url=jdbc:mysql://localhost:3306/db_rundeck?autoReconnect=true&characterEncoding=utf-8
dataSource.username=username
dataSource.password=password
dataSource.driverClassName=com.mysql.jdbc.Driver
</pre>
修改默认的用户名密码
```shell
vim $RUNDECK_HOME/server/config/realm.properties
```
修改前
<pre>
admin:admin,user,admin
user:user,user
</pre>
修改后
<pre>
admin:yourpassword,user,admin
user:yourpassword,user
</pre>

## 守护进程启动Rundeck
```shell
cd /usr/local/rundeck
nohup java -jar rundeck-3.0.23-20190619.war &
```

## 使用Rundeck
http://yourip:4440
