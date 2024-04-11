# Spring
- [spring-security](spring-security.md)

## Bean加载过程
关键的类: AbstractAutowireCapableBeanFactory
1. **实例化**：通过读取xml或者注解通过反射机制实例化class对象
2. **属性注入**：为添加了@Autowire或者构造方法里的成员变量赋值（通过三级缓存解决循环依赖的问题）
3. **初始化**：由自己实现，spring负责调用的方法
  - 方法1: 实现InitializingBean接口，重写afterPropertiesSet方法
    ```java
    import org.springframework.beans.factory.InitializingBean;

    public class XxxBean implements InitializingBean {
        @Override
        public void afterPropertiesSet() throws Exception {
            // 在这里编写初始化逻辑
        }
    }
    ```
  - 方法2：通过init-method属性指定
    ```xml
    <bean id="xxxBean" class="com.example.XxxBean" init-method="customInitMethod">
        <!-- 其他属性配置 -->
    </bean>
    ```
    ```java
    public class XxxBean {
        public void customInitMethod() {
            // 在这里编写初始化逻辑
        }
    }
    ```
  - 方法3：使用注解@PostConstruct
    ```java
    import javax.annotation.PostConstruct;

    public class XxxBean {
        @PostConstruct
        public void customInitMethod() {
            // 在这里编写初始化逻辑
        }
    }    
    ```
4. **生成AOP代理类**：如果配置了AOP切面，通过cglib生成代理对象，那放入单例池的bean不再是原来的bean而是生成的代理对象
5. **后置处理**：和初始化方法一样，由自己实现，spring负责调用。实现BeanPostProcessor接口，重写postProcessAfterInitialization方法
6. **放入单例池**：Map<beanName, 对应的实例对象>

## 属性注入，构造器注入，setter注入
- 为什么不建议用属性注入？
  - 可读性差：隐藏了Bean的依赖项
  - 可测试性差：要想测试Bean的某一个方法必须将所有 @Autowired 修饰的属性注入。如果用构造器或者setter注入，则可以通过手动new的方式选择性的注入，甚至可以脱离Spring容器进行小范围的测试
- 为了更清晰的描述Bean的结构，建议必须依赖的Bean用构造器注入，可选的依赖用setter注入
- @Autowired 和 @Resource 的区别
  - 来源不同
    > @Autowired 是Spring专有  
    > @Resource 是JDK自带（JSR-250）更具通用性
  - 作用域不同
    > @Resource 不能用在构造方法上
  - 获取bean的时候 byName 和 byType 顺序不同
    > @Autowired 先通过byType，找到多个再通过byName过滤
    > @Resource 先通过byName，找不到再通过byType寻找

## 三级缓存
- **singletonObjects**：一级缓存，存放的是已经初始化好的bean，即已经完成初始化好的注入对象的代理。最终getBean就是来源于singletonObjects
- **earlySingletonObjects**：二级缓存，存放的是还没有完全被初始化好的中间对象代理，即已经生成了bean但是这个bean还有部分成员对象还未被注入进来
- **singletonFactories**：三级缓存，存放的是还未初始化完的bean，而这些bean只是早起的简单对象，并不是代理对象

## @ComponebtScan(xxx) 是通过 ASM 去生成 BeanDefinition
- 为什么不用反射？
  > 如果要用反射就必须先把.class文件加载到jvm，那么就不存在懒加载机制了。
- 为什么要实现懒加载@Lazy？
  1. 加快启动速度
  2. 按需加载，节省资源
  3. 可以避免循环依赖

## spring-boot-autoconfigure & Spring Boot Starter
- spring.factories 文件的作用
  - 什么是SPI：提供方定义接口规范且提供默认实现，调用方选择一种实现或者自定义实现。相对于 API 来说，SPI 即定义了接口规范也提供扩展入口，具有较高灵活性，一般在框架开发中比较常见。
  - Java SPI：在 src/main/resources/META-INF/services 目录创建一个以接口全路径命名的文件（例如：xxx.IAnimal）, 内容为接口的实现类，示例如下：
    ```text
    xxx.impl.Cat
    xxx.impl.Dog
    ```
    然后通过 ServiceLoader 加载对应的实现类，示例代码如下
    ```java
    public class SPITest {
      public static void main(String[] args){
        ServiceLoader<xxx.IAnimal> animals = ServiceLoader.load(IAnimal.class);
        for (IAnimal animal : animals) {
          animal.doSomeThing();
        }
      }
    }
    ```
  - Spring SPI：src/main/resources/META-INF/spring.factories
- 条件注解 @Conditional
  ```
  @ConditionalOnBean
  @ConditionalOnClass
  @ConditionalOnProperty
  ...
  ```

## SpringApplication.run(Xxx.class) 做了哪些工作
1. 创建Spring容器：new ApplicationContext()
2. 启动Web服务(Tomcat, Jetty, Undertow, Netty), 默认内置Tomcat
