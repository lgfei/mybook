# Go语言 学习笔记

## 安装go环境

### 方式一: 用yum安装
```shell
yum list golang --showduplicates | sort -r
yum install golang
```

### 方式二:使用二进制文件安装
标准官网：https://golang.org/ 需要墙 <br/>
镜像官网：https://golang.google.cn/dl/ 【国内推荐】<br/>

#### 1. 下载文件
```shell
wget https://golang.google.cn/dl/go1.17.linux-amd64.tar.gz
```
#### 2. 解压文件到 /usr/local
***如果之前已经安装过go的版本，先清空下go下面src，不然可能会报一些previous declaration at /usr/local/go/src/runtime/internal/atomic/atomic_amd64.go:16:24的错误***
```shell
rm -rf /usr/local/go
tar -zxf go1.17.linux-amd64.tar.gz -C /usr/local
```
#### 3. 环境配置
创建gopath文件夹
```shell
mkdir -p /data/gopath
```
配置环境变量
```shell
vim /etc/profile
```
内容如下
<pre>
export GOROOT=/usr/local/go 
export GOPATH=/data/gopath
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
</pre>
生效环境变量
```shell
source /etc/profile
```
查看安装的版本
```shell
go version
```
#### 4. 设置代理环境变量，再拉去golang.org的时候就不需要墙了
***注意:GO1.13及之后支持direct的写法***
```shell
go env -w GOPROXY=https://goproxy.cn,direct
```
查看golang环境变量
```shell
go env
```

## Hello World
切换到gopath目录
```shell
cd /data/gopath
```
创建hello.go
```
vim hello.go
```
```go
package main  
import "fmt"  
func main() {  
    fmt.Printf("Hello, world!\n")  
}
```
运行代码
```shell
go run hello.go
```

## FAQ
### 关于报错 missing go.sum entry; to add it的处理方式，有三种处理方式  
方式1. 加环境变量，本地开发推荐用这种方式，会自动拉引用和生成go.sum
```shell
go env -w "GOFLAGS"="-mod=mod"
```
方式2. 在go build的时候添加参数
```shell
go build -mod=mod
```
方式3. 在go.mod同一层级中执行
```shell
go mod tidy
```
