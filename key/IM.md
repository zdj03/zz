1、[iOS即时通讯详解](https://www.jianshu.com/p/8d7fcb790df9)

2、[iOS即时通讯，从入门到“放弃”](http://www.jianshu.com/p/2dbb360886a8)

3、[移动端IM/推送系统的协议选型](https://link.jianshu.com/?t=http://www.52im.net/thread-33-1-1.html)

4、[从问题看本质，socket到底是什么？](https://link.jianshu.com/?t=http://blog.csdn.net/yeyuangen/article/details/6799575)

5、[单台服务器并发TCP连接数到底可以有多少](https://link.jianshu.com/?t=http://www.52im.net/thread-561-1-1.html)

6、[为什么说基于TCP的移动端IM仍然需要心跳保活？](https://link.jianshu.com/?t=http://www.52im.net/thread-281-1-1.html)

7、[微信的智能心跳实现方式](https://link.jianshu.com/?t=http://www.52im.net/thread-120-1-1.html)

8、[移动端IM实践：WhatsApp、Line、微信的心跳策略分析](http://www.52im.net/thread-121-1-1.html)

9、[移动端IM实践：谷歌消息推送服务(GCM)研究（来自微信团队）](http://www.52im.net/thread-122-1-1.html)

10、[iOS即时通讯之CocoaAsyncSocket源码解析一](https://www.cnblogs.com/francisblogs/p/6825312.html)

```
1、初始化：
	- 代理、代理queue
	- 本机socket初始化
	- 生成socketQueue（串行）
	- 创建读写队列（数组）
	- 创建全局数据缓冲区
	- 初始化交替延时变量
2、客户端：connect服务器，服务端：bind端口，accept
  - 在一个block（包裹在自动释放迟）里前置的错误检查：interface、IPv4\IPv6（服务端地址）、代理、代理queue、当前不是非连接状态、是否支持IPv4\IPv6
  - 本机地址绑定，结构体：IPv4地址sockaddr_in、IPv6地址sockaddr_in6、获取本机IP参数ifaddrs
3、设置flag标记为kSocketStarted
4、调用全局queue，异步调用连接
  - 拿到服务端server的地址数组：host分localhost和loopback，不是本机地址，根据host和port创建地址
  - 做错误判断，赋值地址，在socketqueue异步调用方法发起连接
5、开始连接
  - 错误判断：
  - 创建socket：给socket绑定本机地址
6、建立连接
7、连接成功后的初始化
8、创建读写stream
9、读写回调的注册
10、将读写stream加到当前线程的runloop（线程保活）
11、打开stream
12、初始化读写source（监听数据可读、可写）
  
服务端accept流程：
1、创建本机地址、创建socket、绑定端口、监听端口
2、创建gcd source来监听socket读source，这样连接事件一发生、就会触发我们的事件句柄。接着调用doAccept:方法循环去接受所有的连接
  
	
```



11、[iOS即时通讯之CocoaAsyncSocket源码解析二](http://www.cnblogs.com/francisblogs/p/6829722.html)

```
IM中的数据粘包、断包处理，以及客户端、服务端demo实例
```

12、[iOS即时通讯之CocoaAsyncSocket源码解析三](https://www.cnblogs.com/francisblogs/archive/2004/01/13/6857169.html)

```
如何利用缓冲区对数据进行读取、以及各种情况下的数据包处理，其中还包括普通的、和基于TLS的不同读取操作等等
```

13、[iOS即时通讯之CocoaAsyncSocket源码解析四](https://www.cnblogs.com/francisblogs/p/6860326.html)

14、[iOS即时通讯之CocoaAsyncSocket源码解析五](https://www.cnblogs.com/francisblogs/archive/2004/01/13/6860347.html)

15、[从0到1：全面理解RPC远程调用](https://juejin.im/post/6844903874562785294)

16、[ProtocolBuffer for Objective-C 运行环境配置及使用](https://www.jianshu.com/p/8c6c009bc500)

17、[iOS之ProtocolBuffer搭建和示例demo](https://link.jianshu.com/?t=http://www.qingpingshan.com/rjbc/ios/181571.html)

18、[IM 即时通讯技术在多应用场景下的技术实现，以及性能调优（ iOS 视角）（附 PPT 与 2 个半小时视频）](https://www.jianshu.com/p/8cd908148f9e)

19、[基于HTTP2的全新APNs协议](https://github.com/ChenYilong/iOS9AdaptationTips/blob/master/基于HTTP2的全新APNs协议/基于HTTP2的全新APNs协议.md)

20、[实时通信服务总览-权限和认证](https://leancloud.cn/docs/realtime_v2.html#权限和认证)

21、[防 DNS 污染方案](https://github.com/ChenYilong/iOSBlog/blob/master/Tips/基于Websocket的IM即时通讯技术/防%20DNS%20污染方案.md)

22、[微信,QQ这类IM app怎么做——谈谈Websocket](https://www.jianshu.com/p/bcefda55bce4)

23、[新手入门一篇就够：从零开发移动端IM](http://www.52im.net/thread-464-1-1.html)

24、[社交场景开发的开源组件：ChatKit-OC](https://github.com/leancloud/ChatKit-OC)

25、[直播集成 IM 的开源直播 DemoLiveKit-iOS](https://github.com/leancloud/LeanCloudLiveKit-iOS)

26、[如约而至：微信自用的移动端IM网络层跨平台组件库Mars已正式开源](http://www.52im.net/thread-684-1-1.html)

27、[让互联网更快：新一代QUIC协议在腾讯的技术实践分享](http://www.52im.net/thread-1407-1-1.html)

28、[HTTP/2 头部压缩技术介绍](https://imququ.com/post/header-compression-in-http2.html)

29、[微信新一代通信安全解决方案：基于TLS1.3的MMTLS详解](http://www.52im.net/thread-310-1-1.html)

30、