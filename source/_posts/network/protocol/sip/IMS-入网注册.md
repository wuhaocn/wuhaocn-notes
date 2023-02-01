---
title: IMS-入网注册

categories:
- SIP

tag:
- IMS
---

## 1.概要
## ![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627393550010-ab490608-c0aa-415c-8aa2-35749258d676.png#clientId=ue276c832-69f5-4&from=paste&height=614&id=iOBZl&margin=%5Bobject%20Object%5D&name=image.png&originHeight=691&originWidth=704&originalType=binary&ratio=1&size=72864&status=done&style=none&taskId=ucd354c72-30eb-4676-b873-8e303c3f0cd&width=626)
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627487171816-e2da3602-ee5c-4e68-b644-12bb3e575d29.png#clientId=u591ad28a-e8ae-4&from=paste&height=103&id=u801e3236&margin=%5Bobject%20Object%5D&name=image.png&originHeight=206&originWidth=2832&originalType=binary&ratio=1&size=179904&status=done&style=none&taskId=u4579b25f-b3f9-4e2b-b287-cee9c146a5e&width=1416)
## 2.register
REGISTER sip:ims.mnc000.mcc000.3gppnetwork.org SIP/2.0
Contact: <sip:460003911000057@172.16.106.92>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";+g.3gpp.ics="principal"
Authorization: Digest username="8613911000057@ims.mnc000.mcc000.3gppnetwork.org",realm="ims.mnc000.mcc000.3gppnetwork.org",nonce="",uri="sip:ims.mnc000.mcc000.3gppnetwork.org",response="",integrity-protected="no"
Expires: 600000
Supported: sec-agree,path
CSeq: 1 REGISTER
Call-ID: 29906@172.16.106.92
From: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>;tag=3196215
To: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>
P-Visited-Network-ID: "sip:pcscf@172.16.106.81:6070"
Feature-Caps: *;+g.3gpp.atcf="<tel:+12340000000>";+g.3gpp.atcf-mgmt-uri="<sip:172.16.106.81:6070>";+g.3gpp.atcf-path="<sip:pcscf@172.16.106.81:6070;transport=udp;lr>";+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
P-Track-ID: c98ce46bbb951afc2305297a67
Route: <sip:proxy@172.16.106.94:5060;lr;transport=udp>
Service-Route: <sip:172.16.106.95:5060;transport=udp;lr>
Path: <sip:172.16.106.81:6070;transport=udp;lr;key=a02907193feadf0b3e14932b37>
P-UserAgent-Info: <sip:172.16.106.92:5060;transport=udp>;+sbc.address="<sip:172.16.106.81:5060;lr;transport=udp>"
Via: SIP/2.0/UDP 172.16.106.81:6070;branch=z9hG4bK19fae5599197
Via: SIP/2.0/UDP 172.16.106.92:5060;branch=z9hG4bK57ab028-c4e752e3
P-Access-Network-Info: 3GPP-NR-TDD; sip:172.16.106.81:5060;lr;transport=udp;ue-ip=172.16.106.92;ue-port=5060;raw-ip=172.16.106.92;raw-port=5060
Require: path
P-Charging-Vector: icid-value=2cd85e11b34b4fe68c4d8c698938d022;icid-generated-at=pcscf.visited.net;orig-ioi=visited.net
Max-Forwards: 69
Content-Length: 0

## 3.401 Unauthorized 

SIP/2.0 401 Unauthorized 
Via: SIP/2.0/UDP 172.16.106.81:6070;branch=z9hG4bK19fae5599197
Via: SIP/2.0/UDP 172.16.106.92:5060;branch=z9hG4bK57ab028-c4e752e3
From: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>;tag=3196215
To: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>;tag=228495176
Call-ID: 29906@172.16.106.92
CSeq: 1 REGISTER
Require: path
Content-Length: 0

## 4.register
REGISTER sip:ims.mnc000.mcc000.3gppnetwork.org SIP/2.0
Contact: <sip:460003911000057@172.16.106.92>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";+g.3gpp.ics="principal"
Authorization: Digest username="8613911000057@ims.mnc000.mcc000.3gppnetwork.org",realm="ims.mnc000.mcc000.3gppnetwork.org",nonce="89pxm4eQF/BAwKVAYTTZYQAAAAAAALm5/UxxNqNHseE=",uri="sip:ims.mnc000.mcc000.3gppnetwork.org",qop=auth,nc=00000001,cnonce="a1b2c3d4e5f6",response="2c8fd97ca4f530ad249af5e4662ddf4c",algorithm=AKAv1-MD5,integrity-protected="no"
Expires: 600000
Supported: sec-agree,path
CSeq: 2 REGISTER
Call-ID: 29906@172.16.106.92
From: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>;tag=243426378
To: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>
P-Visited-Network-ID: "sip:pcscf@172.16.106.81:6070"
Feature-Caps: *;+g.3gpp.atcf="<tel:+12340000000>";+g.3gpp.atcf-mgmt-uri="<sip:172.16.106.81:6070>";+g.3gpp.atcf-path="<sip:pcscf@172.16.106.81:6070;transport=udp;lr>";+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
P-Track-ID: 754087c87c51f31bcc99457db8
Route: <sip:proxy@172.16.106.94:5060;lr;transport=udp>
Path: <sip:172.16.106.81:6070;transport=udp;lr;key=0a04f65a2b9bdd01d9d7a4b866>
P-UserAgent-Info: <sip:172.16.106.92:5060;transport=udp>;+sbc.address="<sip:172.16.106.81:5060;lr;transport=udp>"
Via: SIP/2.0/UDP 172.16.106.81:6070;branch=z9hG4bKb2f5b1801e38
Via: SIP/2.0/UDP 172.16.106.92:5060;branch=z9hG4bK57ab028-c4e7c91f
P-Access-Network-Info: 3GPP-NR-TDD; sip:172.16.106.81:5060;lr;transport=udp;ue-ip=172.16.106.92;ue-port=5060;raw-ip=172.16.106.92;raw-port=5060
Require: path
P-Charging-Vector: icid-value=2d834d66ac1947be8d2c75938ce7038e;icid-generated-at=pcscf.visited.net;orig-ioi=visited.net
Max-Forwards: 69
Content-Length: 0

## 5.200 OK 
SIP/2.0 200 OK 
Via: SIP/2.0/UDP 172.16.106.81:6070;branch=z9hG4bKb2f5b1801e38
Via: SIP/2.0/UDP 172.16.106.92:5060;branch=z9hG4bK57ab028-c4e7c91f
From: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>;tag=243426378
To: <sip:460003911000057@ims.mnc000.mcc000.3gppnetwork.org>;tag=0-ac106a5f-210323031846-2112256181
Call-ID: 29906@172.16.106.92
CSeq: 2 REGISTER
Contact: <sip:460003911000057@172.16.106.94>;q=1.0;expires=600000
Require: path
Content-Length: 0
Service-Route: <sip:172.16.106.95:5060;transport=udp;lr>
Path: <sip:172.16.106.81:6070;transport=udp;lr;key=0a04f65a2b9bdd01d9d7a4b866>
P-Charging-Vector: 2d834d66ac1947be8d2c75938ce7038e;icid-generated-at=pcscf.visited.net;orig-ioi=visited.net;term-ioi=ims.mnc000.mcc000.3gppnetwork.org;access-network-charging-info=test

