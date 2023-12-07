# gitlab
官网下载地址: https://packages.gitlab.com/app/gitlab/gitlab-ce/search?q=11.1.4

## 安装
```shell
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
yum install -y gitlab-ce-11.1.4-ce.0.el7.x86_64
gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-ctl status
```

## 访问GitLab的PostgreSQL数据库
登陆gitlab的安装服务查看配置文件
```shell
cat /var/opt/gitlab/gitlab-rails/etc/database.yml
```
查看/etc/passwd文件里边gitlab对应的系统用户
```shell
cat /etc/passwd
```
根据上面的配置信息登陆postgresql数据库
```shell
su - gitlab-psql
psql -h /var/opt/gitlab/postgresql -d gitlabhq_production
```
接下来出现数据库操作界面
<pre>
psql (9.2.18)
Type "help" for help.
gitlabhq_production=#
# 常用的命令
\h  //帮助
\l  //查看数据库
\dt //查看表
\d [表名]  //查看单表结构
\di //查看索引
\q  //退出
</pre>

## gitlab-runner安装与使用
https://gitlab.com/gitlab-org/gitlab-runner

* 添加yum源
```shell
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
```
* 安装
```shell
yum install gitlab-runner
```
* 使用
```shell
gitlab-runner -h
```
```text
NAME:
   gitlab-runner - a GitLab Runner
USAGE:
   gitlab-runner [global options] command [command options] [arguments...]
VERSION:
   14.1.0 (8925d9a0)
AUTHOR:
   GitLab Inc. <support@gitlab.com>
COMMANDS:
     exec                  execute a build locally
     list                  List all configured runners
     run                   run multi runner service
     register              register a new runner
     install               install service
     uninstall             uninstall service
     start                 start service
     stop                  stop service
     restart               restart service
     status                get status of a service
     run-single            start single runner
     unregister            unregister specific runner
     verify                verify all registered runners
     artifacts-downloader  download and extract build artifacts (internal)
     artifacts-uploader    create and upload build artifacts (internal)
     cache-archiver        create and upload cache artifacts (internal)
     cache-extractor       download and extract cache artifacts (internal)
     cache-init            changed permissions for cache paths (internal)
     health-check          check health for a specific address
     read-logs             reads job logs from a file, used by kubernetes executor (internal)
     help, h               Shows a list of commands or help for one command
GLOBAL OPTIONS:
   --cpuprofile value           write cpu profile to file [$CPU_PROFILE]
   --debug                      debug mode [$DEBUG]
   --log-format value           Choose log format (options: runner, text, json) [$LOG_FORMAT]
   --log-level value, -l value  Log level (options: debug, info, warn, error, fatal, panic) [$LOG_LEVEL]
   --help, -h                   show help
   --version, -v                print the version
```

* 启动runner
默认的用户是gitlab-runner, 默认的工作空间是 /home/gitlab-runner
```shell
gitlab-runner install --user root --working-directory /data/gitlab-runner --config /etc/gitlab-runner/config.toml --service gitlab-runner
gitlab-runner start
gitlab-runner register
gitlab-runner restart
gitlab-runner list
```