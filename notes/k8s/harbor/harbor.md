# 镜像仓库Harbor部署
存放docker镜像的仓库，也可以存放helm安装包。跟[Docker Hub](https://hub.docker.com)是一样的东西

## 环境准备
机器ip：192.168.2.101<br/>
预先安装docker，安装过程略
```shell
docker version
```

## Docker Compose安装
***通过docker-compose.yml修改端口***<br>
```shell
yum install -y docker-compose
docker-compose --version
```
如果使用http的方式配置harbor需要为所有Docker添加信任配置。"insecure-registries" : ["http://192.168.2.101"]
```shell
vim /etc/docker/daemon.json
```
```json
{
  "registry-mirrors": ["https://tdimi5q1.mirror.aliyuncs.com"],
  "insecure-registries" : ["http://192.168.2.101"]
}
```
```shell
systemctl restart docker
```

## 下载Harbor 
- [下载地址](https://github.com/vmware/harbor/releases)<br>
建议下载offline的压缩包，里面包含了harbor启动所用的所有docker镜像，可以快速的部署harbor<br>
```shell
mkdir -p /opt/harbor/src
cd /opt/harbor/src
wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.1.tgz
mkdir -p /opt/harbor/1.8.0
cp harbor-offline-installer-v1.8.1.tgz /opt/harbor/1.8.0
cd /opt/harbor/1.8.0
tar zxf harbor-offline-installer-v1.8.1.tgz
```

## 安装Harbor
***通过harbor.yml修改hostname***<br>
```shell
cd /opt/harbor/1.8.0
./install.sh
```
如果要支持上传helm Chart 则执行
```shell
./install.sh   --with-clair --with-chartmuseum
docker-compose ps
```

## 使用
<pre>
使用Harbor管理Registry 
web登录：http://192.168.2.101  默认用户名密码  admin/Harbor12345
后台登录：docker login http://192.168.2.101
</pre>
提交镜像到Registry
```shell
docker tag centos:latest 192.168.2.101/system/centos:latest
docker push 192.168.2.101/system/centos:latest
```

## 重置&重启
停止
```shell
cd /opt/harbor/1.8.0
docker-compose down
```
修改harbor.yml重新生成配置
```shell
./prepare
```
重启
```shell
docker-compose up –d
```
推倒重来
```shell
docker-compose down
rm -rf database registry
./install.sh
```

## 升级(v1.8.1 to v1.9.3)
备份（先确定是否有足够的磁盘空间）
```shell
cd /opt/harbor/1.8.x/harbor/
docker-compose down
mkdir /data/backup/harbor_1.8.1/harbor/
cp -r /opt/harbor/1.8.x/harbor/ /data/backup/harbor_1.8.1/harbor/
mkdir /data/backup/harbor_1.8.1/database/
cp -r /data/database/ /data/backup/harbor_1.8.1/database/
mkdir /data/backup/harbor_1.8.1/registry/
cp -r /data/registry/ /data/backup/harbor_1.8.1/registry/
```
准备更新
```shell
mkdir /opt/harbor/1.9.x/
cd /opt/harbor/1.9.x/
wget https://github.com/goharbor/harbor/releases/download/v1.9.3/harbor-offline-installer-v1.9.3.tgz
tar zxf harbor-offline-installer-v1.9.3.tgz
docker image load -i harbor/harbor.v1.9.3.tar.gz
```
拉取相应版本的迁移工具
```shell
docker pull goharbor/harbor-migrator:v1.9.3
```
更新配置文件
```shell
docker run -it --rm -v /data/backup/harbor_1.8.1/harbor.yml:/harbor-migration/harbor-cfg/harbor.yml goharbor/harbor-migrator:v1.9.3 --cfg up
```
更新
```shell
cd /opt/harbor/1.9.x/harbor/
./install.sh --with-chartmuseum
```
回滚（如果升级出现问题）<br>
停止当前版本
```shell
cd /opt/harbor/1.9.x/harbor/
docker-compose down
```
还原旧版本
```shell
cp -r /data/backup/harbor_1.8.1/harbor/ /opt/harbor/1.8.x/harbor/
cp -r /data/backup/harbor_1.8.1/database/ /data/database/
cp -r /data/backup/harbor_1.8.1/registry/ /data/registry/
cd /opt/harbor/1.8.x/harbor/
./install.sh --with-chartmuseum
```

## 参考文献
- [m.unixhot.com](http://m.unixhot.com/docker/registry.html)
