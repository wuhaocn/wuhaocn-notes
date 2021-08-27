---
title: CMPP短信客户端

categories:
- 短信

tag:
- cmpp
---

最近公司有需求采用cmpp发送短信调研了一下相关工具，发现如下测试工具挺好用分享一下。
​


- 工具类

      [https://www.cnblogs.com/tuyile006/p/12051168.html](https://www.cnblogs.com/tuyile006/p/12051168.html)

- 开源源码

     [https://github.com/Lihuanghe/SMSGate](https://github.com/Lihuanghe/SMSGate)
## 1.介绍
CMPP2.0/CMPP3.0服务端，带数据库，可以接收第三方CMPP客户端的短信，并存入数据库，结合我的cmpp客户端服务程序，将可以实现接收第三方SP的短信并转发到网关实现发送，并将状态报告、上行短信转发给第三方SP，实现了透明网关的作用。
程序界面如下：
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1630054353122-2535722c-af7a-4052-b547-14708cb98cd9.png#clientId=u482c2e30-bdf3-4&from=paste&id=u05bf13d4&margin=%5Bobject%20Object%5D&originHeight=622&originWidth=978&originalType=url&ratio=1&status=done&style=none&taskId=u8fd28d46-d868-445f-9849-342dd132027)
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1630054353291-c7e8756a-7c25-479a-b3b1-a31f96c1f33a.png#clientId=u482c2e30-bdf3-4&from=paste&id=ud8081f22&margin=%5Bobject%20Object%5D&originHeight=670&originWidth=703&originalType=url&ratio=1&status=done&style=none&taskId=ubc236dfd-0b99-4c1d-959f-aec5968cd34)
源码截图如下：
![](https://cdn.nlark.com/yuque/0/2021/png/804884/1630054353170-58a66bb5-05b3-4683-8c66-60e69c884929.png#clientId=u482c2e30-bdf3-4&from=paste&id=u29b16441&margin=%5Bobject%20Object%5D&originHeight=772&originWidth=1315&originalType=url&ratio=1&status=done&style=none&taskId=uff5e83d6-7a43-4c9a-b38c-804d7cf592a)
如界面所示，可以直接给下游SP发MO短信。本程序已经在多个项目中使用，支持长短信，可以实现多个客户端并发连接。
提供试用版[DEMO下载](https://files.cnblogs.com/files/tuyile006/CMPP2.0Server.rar)    注意360会提示木马，请不用理会。
目前程序已经升级到V5.0版本，性能更加强大稳定。V5.0版演示如下：
![](https://cdn.nlark.com/yuque/0/2021/gif/804884/1630054352691-638347f8-e28d-4e27-9df9-03b52619a8e1.gif#clientId=u482c2e30-bdf3-4&from=paste&id=udddf4c32&margin=%5Bobject%20Object%5D&originHeight=751&originWidth=1358&originalType=url&ratio=1&status=done&style=none&taskId=ue546fc3d-e993-49cc-ac38-6b90c2a22cb)
## 2.下载


下载 ：   [客户端V5.0版Demo](https://files.cnblogs.com/files/tuyile006/SMSClient.UI.zip)     [服务端V5.0版Demo](https://files.cnblogs.com/files/tuyile006/SMSServer.UI.zip)
相关源码是作者的劳动成果，如有需要，请联系作者购买。
## ​

## 3.参考
[https://www.cnblogs.com/tuyile006/p/12051168.html](https://www.cnblogs.com/tuyile006/p/12051168.html)
​

