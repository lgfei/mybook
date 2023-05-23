# MySQL
从最新版本的linux系统开始，默认的是Mariadb而不是mysql!!！

## 安装5.7，需进行如下操作
```shell
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mysql-server
```

## 启动
```shell
service mysqld start
```

## 查看是否启动
```shell
service mysqld status
```

## 默认没有密码，重置root密码
先无密码登录
```shell
mysql -u root
```
再修改密码
```sql
use mysql;  
update user set password=password('yourpassword') where user='root' and host='localhost';  
flush privileges;  
```

## 授权root用户远程登录
```sql
grant all privileges on *.* to 'root'@'%' identified by 'yourpassword' with grant option;  
flush privileges;
```

## 创建用户并授权
```sql
CREATE USER 'username'@'%' IDENTIFIED BY 'password';
GRANT ALL ON dbname.* TO 'username'@'%';
FLUSH PRIVILEGES;
```
