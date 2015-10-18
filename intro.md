# 系统简介 #

## 简介 ##
本程序为一个使用erlang + flash编写的象棋系统,可以实现人-人下棋,人-机下棋等功能.

## snapshot ##

![http://erl-chess.googlecode.com/svn/wiki/1.jpg](http://erl-chess.googlecode.com/svn/wiki/1.jpg)
![http://erl-chess.googlecode.com/svn/wiki/2.jpg](http://erl-chess.googlecode.com/svn/wiki/2.jpg)
![http://erl-chess.googlecode.com/svn/wiki/3.jpg](http://erl-chess.googlecode.com/svn/wiki/3.jpg)

## 系统架构 ##
### 象棋游戏系统 ###
象棋游戏系统架构如下图所示.客户端(flash)通过套接字与裁判服务器连接.裁判服务器负责游戏规则的管理,与客户端连接的管理.
裁判服务器使用棋盘服务器管理当前各棋局的状态.
![http://erl-chess.googlecode.com/svn/wiki/chess1.png](http://erl-chess.googlecode.com/svn/wiki/chess1.png)
### 机器AI系统 ###
机器AI系统负责人-机下棋时的机器AI.其架构如下图所示.http server负责http协议的使用接口,处理网络请求,并生成计算任务,计算任务传递给一组P2P的计算节点,并由节点计算得到结果,通过httpserver返回调用者.
![http://erl-chess.googlecode.com/svn/wiki/chess2.png](http://erl-chess.googlecode.com/svn/wiki/chess2.png)
### 结合 ###
制作一个简单的象棋游戏系统的客户端与游戏系统连接,底层调用AI系统计算并得到行棋方式,便可以使用这个客户端与人类下棋了.