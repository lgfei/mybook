# Java

- [dubbo](./dubbo/README.md)
- [jdk](./jdk/README.md)
- [jvm](./jvm/README.md)
- [netty](./netty/README.md)
- [spring](./spring/README.md)

## 主要特性
- **跨平台**：java是解释型语言，先由前端编译器例如（javac）将.java翻译为.class，再由后端编译器（jvm）翻译为机器语言，实现一次编译到处运行。
- **面向对象**：继承、封装、多态三大基本特征，单一职责、依赖倒置、开放封闭、接口隔离、里氏替换五大基本原则。
- **自动垃圾回收**：标记清除，复制，分代收集 

## 多线程

### CompletableFuture
CompletableFuture 是 java 8 引入的新特性，它使得异步编程和多认为组合编排变得更容易。
- get 和 join 的区别
  > 相同点
    1. 都会阻塞线程等待 future 返回结果
    2. 如果计算被取消抛出异常：CancellationException
  
  > 不同点
    1. get 需要显示的处理异常
    2. get(long timeout, TimeUnit unit) 方法可设置任务阻塞超时时间
- allOf 和 anyOf
  - allOf：所有任务都完成后才返回，因为每个任务返回结果的类型可能不同，所以只能用 CompletableFuture<Void> 接收。
    > 那如何获取所有任务的返回值呢？
    ```
    CompletableFuture<Void> allFuture = CompletableFuture.allOf(futures.toArray(new CompletableFuture[futures.size()]));
    CompletableFuture<List<Object>> resultFutures = allFuture.thenApply(v -> {
      return futures.stream().map(f -> f.join()).collect(Colletors.toList());
    });
    ```
  - anyOf：任意一个任务完成后即返回（一般是执行最快的那个），其他则丢弃，并返回 CompletableFuture<Object>。
