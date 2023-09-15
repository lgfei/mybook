# Spring

## Bean加载过程
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

## spring-boot-autoconfigure
