# Nginx

## 安装epel仓库
Nginx包可在EPEL存储库中找到，如果您没有安装EPEL存储库，可以运行以下命令
```shell
yum install epel-release
```

## 安装
```shell
yum install nginx
```

## 启用，禁用Nginx服务
```shell
systemctl enable nginx  
systemctl disable nginx 
``` 

## 启动，停止，重启，重新加载配置，查看状态
```shell
systemctl start nginx  
systemctl stop nginx  
systemctl restart nginx  
systemctl reload nginx   
systemctl status nginx 
```

## 检查Nginx版本
```shell
nginx -v
```

## 如果您正在运行防火墙，则还需要打开端口80和443
```shell
firewall-cmd --permanent --zone=public --add-service=http  
firewall-cmd --permanent --zone=public --add-service=https  
firewall-cmd --reload 
```

## location proxy_pass 后面的url 加与不加/的区别
在nginx中配置proxy_pass时，当在后面的url加上了/，相当于是绝对根路径，则nginx不会把location中匹配的路径部分代理走;如果没有/，则会把匹配的路径部分也给代理走。 
<hr/> 
下面四种情况分别用http://192.168.1.4/proxy/test.html 进行访问。  

* 第一种
    ```nginx
    location  /proxy/ {
        proxy_pass http://127.0.0.1:81/;
    }
    ```
    结论：会被代理到http://127.0.0.1:81/test.html 这个url

* 第二种(相对于第一种，最后少一个 /)
    ```nginx
    location  /proxy/ {
        proxy_pass http://127.0.0.1:81;
    }
    ```
    结论：会被代理到http://127.0.0.1:81/proxy/test.html 这个url

* 第三种
    ```nginx
    location  /proxy/ {
        proxy_pass http://127.0.0.1:81/ftlynx/;
    }
    ```
    结论：会被代理到http://127.0.0.1:81/ftlynx/test.html 这个url。

* 第四种(相对于第三种，最后少一个 / )：
    ```nginx
    location  /proxy/ {
        proxy_pass http://127.0.0.1:81/ftlynx;
    }
    ```
    结论：会被代理到http://127.0.0.1:81/ftlynxtest.html 这个url
- [参考1](https://yq.aliyun.com/articles/506996?spm=5176.10695662.1996646101.searchclickresult.411f490dl0ZSc0)  

## 开启文件预览模式
如果放一个自定义后缀的文件在nginx目录下（例如，my.hosts），然后在浏览器访问这个文件，默认是会把源文件下载到本地，如果不想下载，而想想打开txt文件那样浏览文件内容的话，需要对 conf/mime.types 做如下修改
```nginx
types {
    text/html                                        html htm shtml;
    text/css                                         css;
    text/xml                                         xml;
    image/gif                                        gif;
    image/jpeg                                       jpeg jpg;
    application/javascript                           js;
    application/atom+xml                             atom;
    application/rss+xml                              rss;

    text/mathml                                      mml;
    text/plain                                       txt hosts; #此处默认只有txt 
    text/vnd.sun.j2me.app-descriptor                 jad;
    text/vnd.wap.wml                                 wml;
    text/x-component                                 htc;
    ...
}
```

## 开启目录浏览模式
如果将nginx作为一个文件下载中心。组需要开启目录浏览功能。如下所示：
```nginx
        location /dl/ {
            root html;
            #开启目录浏览
            autoindex on;
            #以html风格将目录展示在浏览器中
            autoindex_format html;
            #切换为 off 后，以可读的方式显示文件大小，单位为 KB、MB 或者 GB
            autoindex_exact_size off;
            #以服务器的文件时间作为显示的时间
            autoindex_localtime on;
            #展示中文文件名
            charset utf-8,gbk;
        }
```

## 禁用浏览器缓存
对于一些纯静态网页，请求不带版本号或者随机数，如果用户想获取最新的内容需要手动刷新缓存，此时可以配置禁用浏览器缓存以达到每次请求都从服务器拿最新的文件。
```nginx
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        #设置禁止浏览器缓存，每次都从服务器请求
        add_header Cache-Control no-cache;
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
```

## upstream 配置的后端服务正常，用 proxy_pass 反向代理的时候一直报 502
错误日志：
```text
*1 connect() to ip:port failed (13: Permission denied) while connecting to upstream
```
解决方案：
- 方法1: 将 nginx 的启动用户改为和当前用户一致，例如将 nginx.conf 的 user nginx; 改为 user root;
- 方法2：禁用 SELinux
- 方法3：禁用防火墙

## 新版本的 tomcat 不支持 upstream 中带下划线
错误日志：
```text
2024-02-22T01:20:48.368Z  INFO 1277396 --- [io-8888-exec-10] o.apache.coyote.http11.Http11Processor   : The host [xxx_server] is not valid
 Note: further occurrences of request parsing errors will be logged at DEBUG level.

java.lang.IllegalArgumentException: The character [_] is never valid in a domain name.
	at org.apache.tomcat.util.http.parser.HttpParser$DomainParseState.next(HttpParser.java:1045) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.http.parser.HttpParser.readHostDomainName(HttpParser.java:931) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.http.parser.Host.parse(Host.java:67) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.http.parser.Host.parse(Host.java:43) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.coyote.AbstractProcessor.parseHost(AbstractProcessor.java:298) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.coyote.http11.Http11Processor.prepareRequest(Http11Processor.java:785) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:368) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:63) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:896) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1744) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:52) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1191) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:659) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) ~[tomcat-embed-core-10.1.18.jar!/:na]
	at java.base/java.lang.Thread.run(Thread.java:833) ~[na:na]
```
解决方案：把 upstream xxx_server 改成 upstream xxx-server

## https
[OHTTPS-免费HTTPS证书](https://ohttps.com/)<br>
配置示例
```nginx
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    server {
        listen              443 ssl;
        server_name         www.example.com;
        ssl_certificate     /etc/nginx/certificates/${你的证书ID}/fullchain.cer;
        ssl_certificate_key /etc/nginx/certificates/${你的证书ID}/cert.key;

        include /etc/nginx/default.d/*.conf;

        location / {
            root   /usr/share/nginx/html;
            index  index.html;
        }
    }
}
```
