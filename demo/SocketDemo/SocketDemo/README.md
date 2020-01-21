####BSD socket API简介

API接口                                                                                                          
```
int socket(int addressFamily, int type, int protocol)
int close(int socketFileDescriptor)
```
**socket创建并初始化socket，返回该socket的文件描述符，如果描述符为-1表示创建失败。
通常参数addressFamily是IPv4(AF_INET)或IPv6(AF_INET6)。type表示socket的类型，通常是流stream(SOCK_STREAM)或数据报文datagram(SOCK_DGRAM)。protocol参数通常设置为0，以便让系统自动选择我们合适的协议，对于stream socket来说会是TCP协议(IPPROTO_TCP)，而对于datagram来说会是UDP协议(IPPROTO_UDP)。close关闭socket**


```
int bind(int socketFileDescriptor, sockaddr *addressToBind, int addressStructLength)
```
**
将socket与特定主机地址与端口号绑定，成功返回0，失败返回-1.
成功绑定之后，根据协议（TCP/UDP）的不同，我们可以对socket进行不同的操作：
UDP：因为UDP是无连接的，绑定之后就可以利用UDP socket传送数据了。
TCP：而TCP是需要建立端到端的连接的，为了建立TCP连接服务器必须调用listen(int socketFileDescriptor, int backlogSize)来设置服务器的缓冲区队列以接收客户端的连接请求，backlogSize表示客户端连接请求缓冲区队列的大小。当调用listen设置之后，服务器等待客户端请求，然后调用下面的accept来接收客户端的连接请求
**

```
int accept(int socketFileDescriptor, sockaddr *clientAddress, int clientAddressStructLength)
```
**
接收客户端连接请求并将客户端的网络地址信息保存到clientAddress中。
当客户端连接请求被服务器接受之后，客户端和服务器之间的链路就建立好了，二者就能通信
**


```
int connect(int socketFileDescriptor, sockaddr *serverAddress, int serverAddressLength)
```
**
客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回-1
当服务器建立好之后，客户端通过调用接口向服务器发起连接请求。对于UDP来说，该接口是可选的，如果调用了该接口，表明设置了该UDP socket默认的网络地址。对于TCP socket来说这就是传说中的三次握手建立连接发生的地方。
注意：该接口调用会阻塞当前线程，直到服务器返回
**

```
hostent *gethostbyname(char *hostname)
```
***
使用DNS查找特定主机名字对应的IP地址。如果找不到则返回NULL
***

```
int send(int socketFileDescriptor, char *buffer, int bufferLength, int flags)
```
***
通过socket发送数据，发送成功返回字节数，失败返回-1.
一旦连接建立好之后，就可以通过send/receive接口发送或接收数据。注意调用connect设置了默认网络地址的UDP socket也可以调用该接口来接收数据
***

```
int reveive(int socketFileDescriptor, char *buffer, int bufferLength, int flags)
```
***
从socket中读取数据，读取成功返回字节数，失败返回-1
一旦连接建立好之后，就可以通过send/receive接口发送或接收数据。注意调用connect设置了默认网络地址的UDP socket也可以调用该接口来接收数据
***

```
int sendto(int socketFileDescriptor, char *buffer, int bufferLength, int flags, sockaddr *destinationAddress, int destinationAddressLength)
```
***
通过UDP socket发送数据到特定的网络地址，发送成功返回字节数，失败返回-1
由于UDP可以向多个网络地址发送数据，所以可以指定特定网络地址，以向其发送数据
***

```
int recvfrom(int socketFileDescriptor, char *buffer, int bufferLength, int flags, sockaddr *fromAddress, int *fromAddressLength)
```
***
从UDP socket中读取数据，并保存发送者的网络地址信息，读取成功返回字节数，失败返回-1
由于UDP可以接收来自多个网络地址的数据，所以需要提供额外的参数，以保存该数据的发送者身份
***



####服务器工作流程
- 1、服务器调用socket()创建socket
- 2、服务器调用listen()设置缓冲区
- 3、服务器通过accept()接受客户端请求建立连接
- 4、服务器与客户端建立好连接之后，就可以 通过send()/receive()向客户端发送或从客户端接收数据
- 5、服务器调用close()关闭socket

#####客户端工作流程
- 1、客户端调用socket()创建csocket
- 2、客户端调用connect()向服务器发起连接请求以建立连接
- 3、客户端与服务器建立连接之后，就可以通过send()/receive()向服务端发送或从服务端接收数据
- 4、客户端调用close关闭socket
