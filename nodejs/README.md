# NodeJS

## Windows 环境准备

### [下载地址](https://nodejs.org/en/download) 

### 验证
```shell
node -v
npm -v
```

### 配置全局安装的模块路径和缓存路径
配置路径
```shell
npm config set prefix "nodejs安装路径\node_global"
npm config set cache "nodejs路径\node_cache"
```

### 配置环境变量
NODE_PATH=你的路径\node_modules <br/>
在Path中添加
```text
你的路径\node_global\
```

### 配置默认仓库地址
```shell
npm config set registry https://registry.npm.taobao.org
```
或者
```
npm config set registry https://registry.npmmirror.com
```

### 查看配置是否生效
```shell
npm config list
```

### 安装cnpm
由于npm的服务器在海外，所以访问速度比较慢，访问不稳定 ，cnpm的服务器是由淘宝团队提供，服务器在国内，cnpm是npm镜像，一般会同步更新，相差在10分钟，所以cnpm在安装一些软件时候会比较有优势。但是cnpm一般只用于模块安装，在项目创建与卸载等相关操作时仍使用npm。
```shell
npm install -g cnpm --registry=https://registry.npmmirror.com
```

### 安装yarn
```shell
npm install yarn -g
```
如果执行yarn命令出现如下异常：
```text
yarn : 无法加载文件 D:\Programs\nodejs\node_global\yarn.ps1，因为在此系统上禁止运行脚本。有关详细信息，请参阅 https:/go.microsoft.com/fwlink/?LinkID=135170 中的 about_Execution_P
olicies。
```
解决方案：修改windows的执行策略 <br/>
1. 打开PowerShell控制台（以管理员身份运行）。
2. 查看当前策略
```shell
get-ExecutionPolicy
```
3. 默认情况下，执行策略的值为 Restricted ,表示禁止执行所有脚本。要允许执行所有脚本，可以运行以下命令：
```shell
set-ExecutionPolicy Unrestricted
```
4. 运行上述命令后，将提示你是否要更改策略。输入 Y 并按下Enter确认更改。


## nvm-windows
对于window用户来说，不能同时安装多个版本的node环境，要么用高版本覆盖低版本，要么卸载重装。nvm可以实现多版本node环境管理。

### 下载[nvm-setup.zip](https://github.com/coreybutler/nvm-windows/releases/download/1.1.11/nvm-setup.zip)
Github地址
```text
https://github.com/coreybutler/nvm-windows
```

### 安装
安装前首先要卸载已安装的任何版本的 NodeJS，安装过程需要设置 NVM 的安装路径和 NodeJS 的快捷方式路径，可以选择任意路径(指定安装目录和当前所使用的nodejs的目录,这两个路径中不要带有特殊的字符以及空格，否则会在nvm use xxx的时候出错，无法正确解析指定的nodejs的版本的地址)。<br/>
在安装的时候，自动会把nvm和nodejs的目录添加到系统环境变量中(环境变量 NVM_HOME 和 NVM_SYMLINK)，所以安装后可以直接测试安装是否成功。

### nvm 命令使用
```text
Running version 1.1.11.

Usage:

  nvm arch                     : Show if node is running in 32 or 64 bit mode.
  nvm current                  : Display active version.
  nvm debug                    : Check the NVM4W process for known problems (troubleshooter).
  nvm install <version> [arch] : The version can be a specific version, "latest" for the latest current version, or "lts" for the
                                 most recent LTS version. Optionally specify whether to install the 32 or 64 bit version (defaults
                                 to system arch). Set [arch] to "all" to install 32 AND 64 bit versions.
                                 Add --insecure to the end of this command to bypass SSL validation of the remote download server.
  nvm list [available]         : List the node.js installations. Type "available" at the end to see what can be installed. Aliased as ls.
  nvm on                       : Enable node.js version management.
  nvm off                      : Disable node.js version management.
  nvm proxy [url]              : Set a proxy to use for downloads. Leave [url] blank to see the current proxy.
                                 Set [url] to "none" to remove the proxy.
  nvm node_mirror [url]        : Set the node mirror. Defaults to https://nodejs.org/dist/. Leave [url] blank to use default url.
  nvm npm_mirror [url]         : Set the npm mirror. Defaults to https://github.com/npm/cli/archive/. Leave [url] blank to default url.
  nvm uninstall <version>      : The version must be a specific version.
  nvm use [version] [arch]     : Switch to use the specified version. Optionally use "latest", "lts", or "newest".
                                 "newest" is the latest installed version. Optionally specify 32/64bit architecture.
                                 nvm use <arch> will continue using the selected version, but switch to 32/64 bit mode.
  nvm root [path]              : Set the directory where nvm should store different versions of node.js.
                                 If <path> is not set, the current root will be displayed.
  nvm [--]version              : Displays the current running version of nvm for Windows. Aliased as v.
```

## Linux 环境准备

### 下载
```shell
mkdir -p /opt/nodejs
cd /opt/nodejs
wget https://nodejs.org/dist/v14.17.4/node-v14.17.4-linux-x64.tar.xz
```
[更多版本下载](https://nodejs.org/en/download/)

### 解压安装
```shell
cd /opt/nodejs
tar xf node-v14.17.4-linux-x64.tar.xz
ln -s node-v14.17.4-linux-x64 node
```

### 设置环境变量
```shell
vim /etc/profile
```
添加如下内容
```text
export NODEJS_HOME=/opt/nodejs/node
export PATH=$NODEJS_HOME/bin:$PATH
```
生效配置
```shell
source /etc/profile
```

### 验证
```shell
node -v
npm -v
npm config list
```

### 安装 yarn 
```shell
npm install yarn -g
```

### 安装 n
```shell
npm i -g n
```
或者
```shell
yarn global add n
```

### 使用 n 管理多版本node
```shell
n -h
```
```text
Usage: n [options] [COMMAND] [args]

Commands:

  n                              Display downloaded Node.js versions and install selection
  n latest                       Install the latest Node.js release (downloading if necessary)
  n lts                          Install the latest LTS Node.js release (downloading if necessary)
  n <version>                    Install Node.js <version> (downloading if necessary)
  n install <version>            Install Node.js <version> (downloading if necessary)
  n run <version> [args ...]     Execute downloaded Node.js <version> with [args ...]
  n which <version>              Output path for downloaded node <version>
  n exec <vers> <cmd> [args...]  Execute command with modified PATH, so downloaded node <version> and npm first
  n rm <version ...>             Remove the given downloaded version(s)
  n prune                        Remove all downloaded versions except the installed version
  n --latest                     Output the latest Node.js version available
  n --lts                        Output the latest LTS Node.js version available
  n ls                           Output downloaded versions
  n ls-remote [version]          Output matching versions available for download
  n uninstall                    Remove the installed Node.js

Options:

  -V, --version         Output version of n
  -h, --help            Display help information
  -p, --preserve        Preserve npm and npx during install of Node.js
  -q, --quiet           Disable curl output. Disable log messages processing "auto" and "engine" labels.
  -d, --download        Download if necessary, and don't make active
  -a, --arch            Override system architecture
  --all                 ls-remote displays all matches instead of last 20
  --insecure            Turn off certificate checking for https requests (may be needed from behind a proxy server)
  --use-xz/--no-use-xz  Override automatic detection of xz support and enable/disable use of xz compressed node downloads.

Aliases:

  install: i
  latest: current
  ls: list
  lsr: ls-remote
  lts: stable
  rm: -
  run: use, as
  which: bin

Versions:

  Numeric version numbers can be complete or incomplete, with an optional leading 'v'.
  Versions can also be specified by label, or codename,
  and other downloadable releases by <remote-folder>/<version>

    4.9.1, 8, v6.1    Numeric versions
    lts               Newest Long Term Support official release
    latest, current   Newest official release
    auto              Read version from file: .n-node-version, .node-version, .nvmrc, or package.json
    engine            Read version from package.json
    boron, carbon     Codenames for release streams
    lts_latest        Node.js support aliases

    and nightly, rc/10 et al
```