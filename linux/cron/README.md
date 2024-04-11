# 定时任务

## crond服务启动与关闭
```shell
service crond status
service crond start
service crond stop
service crond reload
```

## 全局配置文件
```shell
ls -l /etc/ | grep -w "cron"
```
- cron.daily：每天执行一次的job
- cron.weekly：每个星期执行一次的job
- cron.monthly：每月执行一次的job
- cron.hourly：每个小时执行一次的job
- cron.d：系统自动定期需要做的任务
- crontab：设定定时任务执行文件
- cron.deny：用于控制不让哪些用户使用Crontab的功能

## crontab命令
查看当前用户的定时任务
```shell
crontab -l
```
编辑当前用户的定时任务（保存后会写到/var/spool/cron/root，其中root是当前用户名）。第一次编辑的时候会让你选择一个编辑器，按照通常的习惯选择 2. /usr/bin/vim.basic
```text
Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny
  4. /bin/ed

Choose 1-4 [1]: 
```
如选择错了，可以通过 select-editor 切换
```shell
select-editor
```
```shell
crontab -e
```
删除当前用的所有任务
```shell
crontab -r
```
cron格式
```text
*        *        *    *       *         command
minute   hour    day   month   week      command
分       时      天    月      星期       命令

minute： 表示分钟，可以是从0到59之间的任何整数。
hour：表示小时，可以是从0到23之间的任何整数。
day：表示日期，可以是从1到31之间的任何整数。
month：表示月份，可以是从1到12之间的任何整数。
week：表示星期几，可以是从0到7之间的任何整数，这里的0或7代表星期日。
command：要执行的命令，可以是系统命令，也可以是自己编写的脚本文件。

星号（*）：代表每的意思，例如month字段如果是星号，则表示每月都执行该命令操作。
逗号（,）：表示分隔时段的意思，例如，“1,3,5,7,9”。
中杠（-）：表示一个时间范围，例如“2-6”表示“2,3,4,5,6”。
正斜线（/）：可以用正斜线指定时间的间隔频率，例如“0-23/2”表示每两小时执行一次。同时正斜线可以和星号一起使用，例如*/10，如果用在minute字段，表示每十分钟执行一次。
```

## 防止密码爆破攻击
将脚本文件 [autoDeny.sh](./docs/autoDeny.sh) 上传到服务器目录/opt/scripts/<br>
添加定时任务 
```
*/1 * * * * sh /opt/scripts/autoDeny.sh
```