1、概述

​		XMPP（可扩展消息处理现场协议）是基于扩展标记语言（XML）的协议，它用于即时消息（IM）以及在线现场探测。它在促进server之间的准即时操作。

​		协议定义了三个角色：客户端、服务端和网关

2、优势

可扩展性：基于XML，具有良好的扩展性

开源：

安全：在client-to-server和server-to-server通信中都是要TLS协议作为通信通道的加密方法

分布式：xmpp没有中央服务器，任何企业都可以拥有自己的xmpp服务器，并且服务器之间以及不同服务器的用户可以相互通信。举例：如现在的qq用户是不可能和FaceBook用户通信的，但是若干年后(XMPP已经作为网络标准)，可能出现一种情况，qq用户可以添加并且和fb用户聊天。

3、缺点

负载过重，没有二进制数据传输

4、网关（gateway）

网关的作用就是实现xmpp和其他系统之间的协议转换，使其可以互换信息

5、通信原理

![xmpp通信原理](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/xmpp通信原理.png)

1、客户端1通过socket向服务端通过三次握手建立TCP长连接（c1向服务器发送登录等信息进行认证）

2、服务端对c1进行认证成功，服务器将c1的联系人列表返回

3、c1通过服务端向其好友发送状态（presence）消息（在线/隐身）





xmpp client

一个client必须支持的功能：

1、通过TCP套接字与xmpp server进行通信

2、解析组织好的XML信息包

3、理解消息数据类型

xmpp将复杂性从client转移到server端，这使得client编写变得容易，更新系统功能也变得容易。xmpp client与server通过XML在TCP套接字的5222 port进行通信，而不需要client之间直接进行通信



xmpp server

遵循两个主要法则：

1、监听client连接，并直接与client应用程序通信

2、与其他xmpp server通信

xmpp开源server一般被设计成模块化，由各个不同的代码包构成，这些代码包分别处理session管理、用户和server之间的通信、server之间的通信、DNS（domain name system）转换、存储用户的个人信息和朋友名单、保留用户在下线时收到的信息、用户注册、用户的身份和权限认证、依据用户的要求过滤信息和系统记录等。另外，server能够通过附加服务来进行扩展，如完整的安全策略，同意server组件的连接或client选择，通向其他消息系统的网关



xmpp网关

XMPP 突出的特点是能够和其它即时通信系统交换信息和用户在线状况。因为协议不同，XMPP 和其它系统交换信息必须通过协议的转换来实现，眼下几种主流即时通信协议都没有公开，所以XMPP server本身并没有实现和其它协议的转换，但它的架构同意转换的实现。实现这个特殊功能的服务端在XMPP 架构里叫做网关(gateway)。眼下，XMPP 实现了和AIM、ICQ、IRC、MSN Massager、RSS0.9 和Yahoo Massager 的协议转换。因为网关的存在，XMPP 架构其实兼容全部其它即时通信网络，这无疑大大提高了XMPP 的灵活性和可扩展性。



基于xmpp协议框架：XMPPFramework

框架使用参考：https://www.cnblogs.com/ludashi/p/4000801.html

#####1、服务器连接

​	1、搭建服务器

​	2、设置服务器地址和端口,设置JID

​	3、连接connect

​	4、断开连接disconnet	

```
user = [NSString stringWithFormat:@"%@@%@",user,_xmppStream.hostName];
[[self xmppStream] setMyJID:[XMPPJID jidWithString:user  resource:@"ios"]];
[_xmppStream connectWithTimeout:10 error:&error];

/*-------------回调----------*/
///连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender;
///连接失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error;

/*------------断开---------------*/
[_xmppStream disconnect];
```



##### 用户注册

```
-(BOOL)registerUser:(NSString*)user withpassword:(NSString*)pwd;

[_xmppStream registerWithPassword:pwd error:&err]

/*------------回调------------*/
///注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender;
///注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
```



##### 用户认证

##### 用户上线

##### 多账户登录冲突实现

##### 添加好友

#####接收发送消息

