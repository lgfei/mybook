# 基于ELRepo升级CentOS内核版本
升级内核，不能卸载当前正在运行的内核，要先切换的其他版本

## 与 Red Hat 不同，CentOS 允许使用 ELRepo，在 CentOS 7 上启用 ELRepo 仓库
```shell
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
```
## 列出可用的安装包
```shell
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
```
## 安装最新的主线稳定版本
```shell
yum --enablerepo=elrepo-kernel install kernel-ml
```
## 安装指定版本
```shell
yum install kernel-lt-4.4.103-1.el7.elrepo.x86_64.rpm -y
```
## 查看系统上的所有可用内核
```shell
awk '$1=="menuentry" {print $2,$3,$4,$5,$6}' /etc/grub2.cfg
```
## 查看默认启动的内核版本
```shell
grub2-editenv list
```
## 设置默认启动版本
```shell
grub2-set-default 'xxx'
```
## 重新创建内核配置
```shell
grub2-mkconfig -o /boot/grub2/grub.cfg
```