# IDEA 学习笔记

## 快捷键
虽然可以直接沿用Eclipse的快捷键，但是因为界面布局差异较大，也并不是所有都兼容，用起来还是别扭，所有建议使用标准的快捷键模式，这里以Windows为例。如果快捷键不生效一般是与其他软件冲突了。<br>
***设置Keymap***
<pre>
File -> Settings -> Keymap
</pre>

***查找***

| **操作** | **描述** |
| :---: | :---: |
| Ctrl + Shift + F | 全局文件内容 |
| Ctrl + Shift + R | 全局文件内容 |
| Shift + Shift | 全局搜索类或者方法 |
| Ctrl + N | 查找class |
| Ctrl + Shift + N | 查找文件 |
| Ctrl + Shift + Alt + N | 查找方法 |

***编码***

| **操作** | **描述** |
| :---: | :---: |
| Ctrl + X | 删除当前行 |
| Ctrl + D | 复制当前行 |
| Ctrl + / | 行注释 |
| Ctrl + Shift + / | 块注释 |
| Ctrl + H | 展示类的层级关系 |
| Ctrl + F12 | 展示类结构（构造函数，成员变量，方法等） |
| Shift + F6 | 重构/重命名 (包、类、方法、变量、甚至注释等) |
| Alt + Enter | 导入包 |
| Ctrl + Alt + O | 删除无用的import |

***跳转***

| **操作** | **描述** |
| :---: | :---: |
| Alt + 上方向键 | 跳到当前类的上一个方法位置 |
| Alt + 下方向键 | 跳到当前类的下一个方法位置 |
| Ctrl + Alt + 左方向键 | 后退到上一次光标的位置 |
| Ctrl + Alt + 右方向键 | 前进到上一次光标的位置 |


## 导入maven项目
<pre>
File -> New -> Module from Existing Sources
</pre>

## UTF-8编码
* 版本：2022.1.2
<pre>
在D:\Program Files\JetBrains\IntelliJ IDEA 2022.1.2\bin\idea64.exe.vmoptions 添加启动参数 -Dfile.encoding=UTF-8
</pre>

## FAQ
### 创建接口时报错
<pre>
Unable to parse template "Interface" Error message: Selected class file name 'xxx.java' mapped to not java file type 'Files supported via TextMate bundles'
</pre>
* 解决过程
<pre>
第1步: 在idea.exe.vmoptions和idea64.exe.vmoptions添加启动参数-Djdk.util.zip.ensureTrailingSlash=false，然后重启
第2步: Settings->Editor->File Types->Text 找到xxx.java删掉
</pre>
* 问题总结 
<pre>
遇到错误提示，不要急于关掉，要尽力去理解提示内容
</pre>