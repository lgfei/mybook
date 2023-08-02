# mysql-schema-sync
[mysql-schema-sync](https://github.com/hidu/mysql-schema-sync) 是
GO语言实现的MySql表结构自动同步工具, 能增量同步新增的表、字段、索引, 能同步删除字段和索引，不能同步删除表。<br>
需要在GO语言环境中运行，安装命令如下：
```shell
go install github.com/hidu/mysql-schema-sync@master
```
示例：<br>
配置文件: mysql-schema-sync_test.json
```json
{
  "source": "test:test@(127.0.0.1:3306)/test_0",
  "dest": "test:test@(127.0.0.1:3306)/test_1",
  "alter_ignore": {
    "tb1*": {
      "column": [
        "aaa",
        "a*"
      ],
      "index": [
        "aa"
      ],
      "foreign": [
        
      ]
    }
  },
  "tables": [
    
  ],
  "tables_ignore": [
    
  ],
  "email": {
    "send_mail": false,
    "smtp_host": "smtp.163.com:25",
    "from": "xxx@163.com",
    "password": "xxx",
    "to": "xxx@163.com"
  }
}
```
添加定时任务
```shell
crontab -e
```
```txt
*/1 * * * * /root/gopath/bin/mysql-schema-sync -conf /root/conf/mysql-schema-sync_test.json -sync -drop >> /var/log/mysql-schema-sync/test.log 2>&1
```