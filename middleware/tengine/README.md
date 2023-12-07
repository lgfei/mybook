# tengine
* [官网地址](http://tengine.taobao.org/)
* [下载地址](http://tengine.taobao.org/download_cn.html)

## 解压安装包
```shell
mkdir -p /opt/tengine
cd /opt/tengine
wget http://tengine.taobao.org/download/tengine-2.3.3.tar.gz
tar -zxvf tengine-2.3.3.tar.gz
```

## 配置检查
```shell
cd /opt/tengine/tengine-2.3.3
./configure --prefix=/usr/local/nginx
```

## 编译安装
```shell
yum install -y gcc openssl-devel pcre-devel zlib-devel
cd /opt/tengine/tengine-2.3.3
make && make install
```

## 启动
```shell
cd /usr/local/nginx/sbin
./nginx
cd /usr/local/bin
ln -s /usr/local/nginx/sbin/nginx nginx 
```

## 刷新配置
修改配置通过如下命令使其生效
```shell
nginx -s reload
```