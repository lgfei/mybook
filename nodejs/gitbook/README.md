# gitbook 安装使用

## 安装
```shell
npm install gitbook-cli -g
```

## 常用命令

### 初始化
```shell
gitbook init
```
gitbook init 之后本地会生成两个文件 README.md 和 SUMMARY.md ，这两个文件都是必须的，一个为介绍，一个为目录结构。

## 编译
```shell
gitbook build
gitbook build ./ --log=debug --debug
```
当电子书内容制作好之后，可以使用如下命令来生成 HTML 静态网页版电子书。该命令会在当前文件夹中生成 _book 文件夹，这个文件夹中的内容就是静态网页版电子书。
<br/>
使用 --log=debug --debug 可以用来调试，会打印出 stack trace。

## 本地预览
```shell
gitbook serve
gitbook serve ./{book_name}
```
gitbook serve 命令实际会先调用 gitbook build 编译书籍，完成后打开 web 服务器，默认监听本地 4000 端口，在浏览器打开 http://localhost:4000 即可浏览电子书。

## 常见问题

### cb.apply is not a function
```text
TypeError: cb.apply is not a function
    at nodejs安装路径\node_global\node_modules\gitbook-cli\node_modules\npm\node_modules\graceful-fs\polyfills.js:287:18
    at FSReqCallback.oncomplete (node:fs:203:5)
```
解决方案
- 方法1：切换到 nodejs 10 以下
- 方法2：屏蔽问题代码<br/>
  编辑 nodejs安装路径\node_global\node_modules\gitbook-cli\node_modules\npm\node_modules\graceful-fs\polyfills.js ,将 65~67行屏蔽
  ```
    fs.stat = statFix(fs.stat)
    fs.fstat = statFix(fs.fstat)
    fs.lstat = statFix(fs.lstat)
  ```
