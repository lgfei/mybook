# IDEA 学习笔记

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