# Apache 软件基金会
[Apache 软件基金会](https://www.apache.org/)，全称：Apache Software Foundation，简称：ASF，成立于 1999 年 7 月，是目前世界上最大的最受欢迎的开源软件基金会，也是一个专门为支持开源项目而生的非盈利性组织。
![img](./apache.png)

## httpd
[httpd](http://httpd.apache.org/)，是 Apache 软件基金会的一个开源 HTTP 服务器，能够运行于 UNIX 和 Windows 上的安全、高效和可扩展服务器。

Apache 估计也是最早的开源项目了，1995 年就推出来了，自从 1996 年 4 月开始就一直是互联网上最流行的 web 服务器了，2020 年 2 月，它度过了它的 25 岁生日。

Apache 适合做HTML、图片等静态资源服务，可以用来部署静态网站，类似于 Nginx，不过 Nginx 要更强大，现在用 Nginx 的比较多。

## Tomcat
[Tomcat](http://tomcat.apache.org/)，是一个 Apache 开源的 Web 应用服务器，是 Java 界最主流的应用服务器。支持 Java Servlet, JavaServer Pages, Java Expression Language 和 Java WebSocket 技术，其实就是为 Java 而生。

## Commons
[Commons](http://commons.apache.org/)，是包含一系列 Java 公共组件的项目，可以理解为 Java 开发工具包、公共类库。例如
```xml
<dependency>
  <groupId>org.apache.commons</groupId>
  <artifactId>commons-lang3</artifactId>
</dependency>
```
- **commons-io**：这是一个有效开发 IO 功能的实用类库，很多 Java IO 处理都不能自己封装；
- **commons-codec**：这个类库提供了常用的编码器和解码器，比如：Base64、十六进制、语音和 url 的编码解码等；
- **commons-collections**：这个类库是专门处理集合的，很多集合处理也不用自己写了；
- **commons-fileupload**：这个类库提供了非常容易的、健壮的、高性能的文件上传功能；

更多请参考上方的项目主页链接，其实 Apache Commons 提供了许多这些公用类库，我们真的没有必要重复造轮子，直接拿来用就好了。

## POI
[POI](http://poi.apache.org/)， 提供了一系列的 Java API 对 Microsoft Office 格式档案读写处理，如：Excel、Word、PowerPoint 等文件的读写，非常强大。

## Ant
[Ant](http://ant.apache.org/)，是一个比较老的 Java 项目编译和构建工具，现在已经用的比较少了，已经被 Maven/ Gradle 替代了。

## Maven
[Maven](http://maven.apache.org/)，是 Apache Ant 的终结者，是现在最主流的软件项目管理工具之一，提供项目自动编译、单元测试、打包、发布等一系列生命周期的管理。

## FreeMarker
[FreeMarker](https://freemarker.apache.org/)，是一个基于模板和数据生成文本输出 HTML 页面、电子邮件、配置文件、源代码等的一个 Java 模板引擎库。

用的最多的就是利用 FreeMarker 模板来生成静态页面，FreeMarker 也是 Spring Boot 支持自动配置的四大模板引擎之一。
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-freemarker</artifactId>
    <version>2.3.1.RELEASE</version>
</dependency>
```

## Velocity
[Velocity](http://velocity.apache.org/)，是一个基于 Java 语言的模板引擎，它允许任何人使用简单而强大的模板语言来引用 Java 代码中定义的对象。

但是，由于 Velocity 长期未更新，所以 Spring Boot 1.5.x 之后不再支持 Velocity，建议大家使用其他模板引擎。

## Shiro
[Shiro](http://shiro.apache.org/)，是一个功能强大且易于使用的 Java 安全框架，可用于身份验证、授权、加密和会话管理等。

另外，通过 Apache Shiro 易于理解的API、细致化的权限控制，我们可以快速、轻松地开发和保护企业应用程序。

## Dubbo
[Dubbo](http://dubbo.apache.org/)，最初是由阿里巴巴开源的分布式服务框架（RPC），一段时间停止维护后，后来又重启维护并捐献给了 Apache 软件基金会。

即使现在 Spring Cloud 微服务的兴起，Dubbo 现在在很多企业也还是在大量运用的，随着 Dubbo 的重启维护并且捐献给 Apache 软件基金会，它的明天会越来越好。

## Thrift
[Thrift](http://thrift.apache.org/)，是一款优秀的、非常轻量级的 RPC 框架，也是大名鼎鼎，最初由 Facebook 进行开发，后来捐献给了 Apache 软件基金会。

Apache Thrift 支持可扩展的跨语言服务化开发，支持多种语言，如 C++, Java, Python, PHP, Ruby, Erlang, Perl, Haskell, C#, Cocoa, JavaScript, Node.js, Smalltalk, OCaml, Delphi 等，十分强大。

## Zookeeper
[Zookeeper](http://zookeeper.apache.org/)，是一个分布式中间件神器，是 Google Chubby 的一个开源实现，可用于做配置中心、分布式锁等，最主要一点是它可以用来支持高度可靠的分布式服务协调中间件。

现在市面上的一些主流的开源项目都有 Zookeeper 的身影，如：Hadoop、Dubbo、Kafka、ElasticJob 等。

## Curator
[Curator](http://curator.apache.org/)， 是 ZooKeeper 的 Java 客户端，它包括一系列高级 API 和工具，简化了使用 ZooKeeper 的操作，可以更容易、可靠地使用 ZooKeeper。

## SkyWalking
[SkyWalking](http://skywalking.apache.org/)，是一个可观测性分析平台和应用性能管理系统，提供分布式跟踪、指标监控、性能诊断、度量汇总和可视化一体化的解决方案。

Apache SkyWalking 支持 Java，net Core, PHP, NodeJS, Golang, LUA 的代理，还支持 Istio + Envoy Service Mesh，特别为微服务、云本机和基于容器（如：Docker, K8s, Mesos）架构设计的。

## ShardingSphere
[ShardingSphere](http://shardingsphere.apache.org/)，是由一组分布式数据库中间件解决方案组成的开源生态系统，包括 3 个独立的产品：JDBC, Proxy & Sidecar (计划中)。它们都提供了数据分片、分布式事务和数据库编排功能，适用于 Java 同构、异构语言和云原生等多种场景。

## ActiveMQ
[ActiveMQ](http://activemq.apache.org/)，是一款灵活、强大的多协议开源消息中间件，支持 JMS 1.1 & 2.0，也是目前最流行的基于 Java 的消息中间件之一。

它支持行业标准协议，所以用户可以跨广泛的语言和平台选择最合适的客户端，如 C、c++、Python、. net 等更多其他语言。

## RocketMQ
[RocketMQ](http://rocketmq.apache.org/)，是一款重量级、极具竞争力的消息队列产品，是由阿里巴巴 2012 年开源的分布式消息中间件，也是一款轻量级的数据处理平台，2016 年捐赠给了 Apache 软件基金会，2017 年正式毕业。

## Kafka
[Kafka](http://kafka.apache.org/)，是一款重量级开源项目，最初由 Linkedin 公司进行开发，后来捐献给了 Apache 软件基金会。

Apache Kafka 它是一种分布式、高吞吐量的发布订阅消息系统（MQ），它的最大的特性就是，可以实时好处理大量数据以满足各种需求和业务场景。

## Flink
[Flink](https://flink.apache.org/)，是一个分布式处理引擎框架，用于无边界和有边界数据流上的有状态计算。Flink 被设计用于在所有常见的集群环境中运行，以内存速度和任何规模执行计算。

## Groovy
[Groovy](http://groovy.apache.org/)，是一个功能十分强大的基于 JVM 平台的动态编程语言，语法与 Java 十分相似，并且兼容 Java，但 Groovy 要更简洁、优美，更易于学习，开发效率也非常高。