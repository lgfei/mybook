# linux 学习笔记

## 查看centos版本
```shell
cat /etc/redhat-*
uname -r
```

## 查看系统是多少位的(如果有x86_64就是64位的，没有就是32位的,后面是X686或X86_64则内核是64位的，i686或i386则内核是32位的)
```shell
uname -a
```

## 重启
```shell
reboot
```

## 查看服务日志
```shell
journalctl -xefu xxx
```

## 查看端口占用
```shell
netstat -lnp | grep 8080
```

## 查看磁盘占用
```shell
df -h
du -sh
du -h --max-depth=1
```

## windows系统编写的sh文件在linux执行不了，需要用dos2unix进行格式转化
```shell
yum install -y dos2unix
dos2unix xxx.sh
```

## 查看selinux配置
```shell
cat /etc/selinux/config
```

## 解压缩命令
```shell
tar -zcvf 压缩文件名 .tar.gz 被压缩文件名
tar -zxvf 压缩文件名.tar.gz

```

## 修改ssh端口
```shell
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
service sshd restart
```

## 查看cpu
总核数 = 物理CPU个数 X 每颗物理CPU的核数 <br>
总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数 <br>
查看物理CPU个数
```shell
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
```
查看每个物理CPU中core的个数(即核数)
```shell
cat /proc/cpuinfo| grep "cpu cores"| uniq
```
查看逻辑CPU的个数
```shell
cat /proc/cpuinfo| grep "processor"| wc -l
```

## 查看是否虚拟机
```shell
dmidecode -s system-product-name
```

## 修改主机名
立即生效，重启后失效
```shell
hostname myhostname
```
永久生效，重启后生效
```shell
echo "HOSTNAME=myhostname" >> /etc/sysconfig/network
echo "192.168.0.1 myhostname" >> /etc/hosts
```

## 查看文件的指定行
查看第10行
```shell
sed -n 10p file
```
查看第10行和第20行
```shell
sed -n -e 10p -e 20p file
```
查看第10到第20行
```shell
sed -n 10,20p file
```

## 别名alias
查看所有别名
```shell
alias
```
查看单个别名
```shell
alias k
```
定义别名 alias <你的别名>=<别名对应的真实命令>，如果等号右边中有空格或tab，则一定要使用引号（单、双引号都行）括起来
```shell
alias k='kubectl'
```
取消别名
```shell
unalias k
```
如果想让别名永久有效的话，就需要把所有的别名设置方案加入到（$HOME）目录下的 .alias 文件中（如果系统中没有这个文件，你可以创建一个），然后在 .bashrc 文件中增加这样一段代码：
```shell
# Aliases
if [ -f ~/.alias ]; then
  . ~/.alias
fi
```

## SSH
假设有2台主机A(192.168.1.1)和B(192.168.1.2)，想通过A免密登录的B
- 第1步：在主机A生成公钥与私钥
```shell
ssh-genkey
```
- 第2步：将主机A ~/.ssh/id_rsa.pub 的内容复制到主机B ~/.ssh/authorized_keys
- 第3步：假设上面步骤都是用root操作，则在主机A使用如下命令即可以免密登录到B
```shell
ssh root@192.168.1.2
```
- 第4步：如果第3步没有生效，则在主机B执行如下命令
```shell
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## grep的高级用法
从/var/log/目录中所有.log文件中查找包含字符ERROR的位置
```shell
grep -rn 'ERROR' *.log
```