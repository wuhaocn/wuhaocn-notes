
---
title: IMS-入网注册

categories:
- SIP

tag:
- IMS
---
## 1.概要

![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627393585310-6f9ba81e-d9fb-4245-80cf-c83aa7588bc3.png#clientId=ue276c832-69f5-4&from=paste&height=698&id=R2dku&margin=%5Bobject%20Object%5D&name=image.png&originHeight=698&originWidth=1145&originalType=binary&ratio=1&size=97410&status=done&style=none&taskId=ua3fd77d1-9e57-466e-a4f7-f3d3286a9ab&width=1145)
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627487350302-314d17cd-fd39-4330-ba7e-eced2c55f0db.png#clientId=u591ad28a-e8ae-4&from=paste&height=79&id=u9eea8836&margin=%5Bobject%20Object%5D&name=image.png&originHeight=158&originWidth=2706&originalType=binary&ratio=1&size=91621&status=done&style=none&taskId=ua89d6db6-03e6-400f-9f25-a6f88a2d590&width=1353)
## 发送
MESSAGE tel:+8615068458834 SIP/2.0
Max-Forwards: 70
Via: SIP/2.0/TCP 10.235.162.57:56808;branch=z9hG4bK-EKbwawmA
User-Agent: CPM-client/OMA2.2 RCS-client/UP_2.4 term-Xiaomi/MI 6-8.0.0 client-MF/1.1.0 OS-Android/8.0.0 Channel-terminal-000001 Channel-client-731184
Call-ID: a989baac-4e10-4e10-a64b-4ec7e161d645
Contribution-ID: 94d850fb-ed40-437e-9609-de9ea0e393d9
Conversation-ID: 4f93f0fe-86d6-462c-9ba2-e4bc3d1cafcc
From: <tel:+8615053065637>;tag=p0Xq8Mny
To: <tel:+8615068458834>
CSeq: 1 MESSAGE
P-Preferred-Identity: tel:+8615053065637
P-Preferred-Service: urn:urn-7:3gpp-service.ims.icsi.oma.cpm.msg
Content-Type: message/cpim
Content-Length: 350

From: <tel:+8615053065637>
To: <tel:+8615068458834>
DateTime: 2020-09-27T04:02:25.941Z
NS: cpm <http://www.openmobilealliance.org/cpm/>
cpm.Payload-Type: text/plain
NS: imdn <urn:ietf:params:imdn>
imdn.Message-ID: 0a76cec9-c5f4-4f1d-a502-8518a57bf8be

Content-Type: text/plain
Content-Transfer-Encoding: base64
Content-Length: 8

5Z6D5Zy+
## 应答
SIP/2.0 202 Accepted
Server: IM-Sever/OMA5.1 
Record-Route: <sip:orig@10.10.208.199:6060;transport=tcp;lr;i=2;s=0>
Via: SIP/2.0/TCP 10.235.162.57:56808;branch=z9hG4bK-EKbwawmA;received=124.64.18.253;rport=50095
From: <tel:+8615053065637>;tag=p0Xq8Mny
Call-ID: a989baac-4e10-4e10-a64b-4ec7e161d645
To: <tel:+8615068458834>;tag=644677907844
CSeq: 1 MESSAGE
Max-Forwards: 70
Conversation-ID: 4f93f0fe-86d6-462c-9ba2-e4bc3d1cafcc
Contribution-ID: 94d850fb-ed40-437e-9609-de9ea0e393d9
Content-Length: 0

