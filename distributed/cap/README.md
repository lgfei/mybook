# CAP定理

## 定义
```text
Consistency 一致性
Availability 可用性
Partition tolerance 分区容忍性
```
在分布式系统中，以上三个特性无法同时满足。
![img](./images/cap.jpg) 

## 为什么Consistency和Availability难以同时存在
一般来说，分布式系统肯定是多节点或者多副本的，必然存在数据分区的情况，所以 Partition tolerance 是必须要满足的。那么根据CAP理论 Consistency 和 Availability 不可能同时存在，所以大部分分布式系统要么是 CP（例如：zookeeper，redis，etcd，apollo），要么是 AP（例如：kafka，minio）。<br/>
简单来说，原因如下：<br/>
如果要满足一致性，那么其中一个节点（一般是Leader）接收到客户端发来的写操作之后，必须保证所有节点都同步更新数据才能提交事务，在事务提交之前，客户端发过来的读请求是不可用的，这时就不满足可用性了。<br/>
同理，如果要满足可用性，那么就可能出现不同的节点返回的数据是不一样，这时就不满足一致性了。

## 一致性的强弱程度
从上至下强度依次减弱 **在CAP定理中的Consistency指的是强一致性，在AP模型的系统中可以使用一定的手段尽可能的降低数据差异带来影响**
- **强一致性（strong consistency）**：任何时刻，任何用户都能读取到最近一次成功更新的数据。
- **单调一致性（monotonic consistency）**：任何时刻，任何用户一旦读到某个数据在某次更新后的值，那么就不会再读到比这个值更旧的值。也就是说，可获取的数据顺序必是单调递增的。
- **会话一致性（session consistency）**：任何用户在某次会话中，一旦读到某个数据在某次更新后的值，那么在本次会话中就不会再读到比这值更旧的值，会话一致性是在单调一致性的基础上进一步放松约束，只保证单个用户单个会话内的单调性，在不同用户或同一用户不同会话间则没有保障。
- **最终一致性（eventual consistency）**：用户只能读到某次更新后的值，但系统保证数据将最终达到完全一致的状态，只是所需时间不能保障。
- **弱一致性（weak consistency）**：用户无法在确定时间内读到最新更新的值。