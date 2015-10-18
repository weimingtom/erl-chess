# 如何尝试着运行系统? #

# 1.运行judgment(裁判服务器) #

## 进入编译目标目录( **.beam文件在此 ) ##**

如:cd("/home/hantuo/www/game/chess/servers/ebin").

## 启动flash套接字包装器 ##

如:socket\_wraper:start(8006, "127.0.0.1", 8005).

其中三个参数分别为:本地端口,远程服务器IP,远程服务器端口.这里的远程服务器为下面提到的裁判服务器.


## 启动裁判服务器 ##

judgment:start(8005).

参数为端口号.这个裁判服务器为通用套接字服务器.



## 至此,一个象棋系统便可以使用,运行客户端(.\client\client\chess.html),填写flash套接字包装器的IP与端口,并使用任意一key便可接入系统.开启另一客户端,使用相同key接入,可以观看人-人下棋的效果. ##

# 2.启动机器客户端(人-机下棋) #


如想完成人-机下棋的功能,需要启动机器客户端,方法如下:

## 启动计算节点 ##

启动一个或多个计算节点,这里以一个为例.

### 以sname参数启动erl shell ###

如

erl -sname t1

### 进入编译目标目录 ###

如

cd("/home/hantuo/www/game/chess/servers/ebin").

### 启动name server ###

ai\_serverlist:start\_link().

这个demo为了方便,把可用计算节点的信息写在代码里了,在启动name server前注意修改ai\_serverlist.erl中reload函数的返回列表(这个列表为可用计算节点列表,可以比实际启动的节点多,多出的部分认为是死节点,并且至少要有一个.).

### 启动权值查询服务 ###

为了日后AI功能的扩展,系统中所有的和权值相关的参数设计为动态变化与加载.故需启动权值查询服务.

如


wigth:start\_link().


### 启动ai http server ###

AI服务对外提供的接口为http,所以首先进入一个新的erlang shell,执行下面操作

inets:start().

httpd:start("httpd.conf").

上面操作启动了ai功能的http接口服务

### 至些,ai系统就运行起来了,但是还需要有人来使用它.见下:) ###

### 启动机器客户端 ###

机器客户端对外的行为与其它客户端一样,但它不需要人工干预,而是调用底层的ai servers来计算,并自动下棋.

首先调用下面命令开启erlang的http支持

inets:start().


运行ai客户户
ai\_adapter:start("fffaaa", "127.0.0.1", 8006, 1, "http://127.0.0.1:8007/chess/ai/get").
参数说明:

1.key:string


2.裁判服务器IP:string


3.端口port:int


4.模式:int(0 | 1),0为主机模式,1为从机模式.


5.ai server位置:string.


### 至此一个ai的client已经可以使用,如果使用主机模式,便可以使用一个flash客户端与之连接了.当然,也可以启动另外一个ai client,从而使电脑对电脑下棋 ###


# client #


http://192.168.48.235/game/chess/client/chess.html