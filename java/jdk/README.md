# JDK
- [Oracle Java](https://www.oracle.com/java/technologies/downloads/)
- [OpenJDK](https://openjdk.org/)

## 查看是否有安装jdk
```shell
rpm -qa | grep jdk
```

## 卸载已安装jdk
```shell
rpm -qa | grep java | xargs rpm -e --nodeps
```

## 输入以下命令，查看可用的jdk软件包列表
```shell
yum search java | grep -i --color JDK
```

## 选择一个版本安装，下面以java-1.8.0-openjdk-devel.x86_64 为例
```shell
yum install java-1.8.0-openjdk-devel.x86_64
```

## 配置全局使用让系统上的所有用户使用java(openjdk)
```shell
vim /etc/profile
```
<pre>
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64  
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar  
export PATH=$PATH:$JAVA_HOME/bin
</pre>
```shell
source /etc/profile
```

## 检查全局变量是否生效
```shell
echo $JAVA_HOME  
echo $CLASSPATH  
echo $PATH
``` 

## 切换用户检查jdk版本
```shell
java -version
```
