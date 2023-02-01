---
title: 音视频通话

categories:
- SIP

tag:
- IMS
---
## 1.主要流程
![下载 (3).png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627470940752-974ccafb-9a9f-4493-b685-fc011492c598.png#clientId=u483e4c72-e2ee-4&from=drop&id=uae785ddf&margin=%5Bobject%20Object%5D&name=%E4%B8%8B%E8%BD%BD%20%283%29.png&originHeight=1215&originWidth=1277&originalType=binary&ratio=1&size=133973&status=done&style=none&taskId=ua18dae18-1f40-42d0-8acd-04779ad4c05)
![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627471023385-85c0acc3-4b59-45fc-bca4-abf99963f673.png#clientId=u483e4c72-e2ee-4&from=paste&height=250&id=u01d42343&margin=%5Bobject%20Object%5D&name=image.png&originHeight=250&originWidth=1286&originalType=binary&ratio=1&size=234005&status=done&style=none&taskId=ue1c25eb8-003d-44f7-ac45-24f1c730440&width=1286)
## 2.音频通话
### 2.1 INVITE 
```
INVITE tel:+8616500000062 SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
To: "8616500000062"<tel:+8616500000062>
P-Preferred-Identity: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>
Contact: <sip:+8616500000061@222.222.2.27:5060>;+sip.instance="<urn:gsma:imei:86354104-407800-0>";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting;+g.3gpp.ps2cs-srvcc-orig-pre-alerting
Accept-Contact: *;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
P-Preferred-Service: urn:urn-7:3gpp-service.ims.icsi.mmtel
P-Early-Media: supported
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Accept: application/sdp,application/3gpp-ims+xml
Session-Expires: 1800
Min-SE: 90
Route: <sip:172.16.106.38:5060;lr>
Require: sec-agree
Proxy-Require: sec-agree
Call-ID: quecbSk9i@222.222.2.27
CSeq: 1 INVITE
Max-Forwards: 70
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKswecbCEJ7GcqBMwaay6Y;rport
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Type: application/sdp
Content-Length: 772

v=0
o=rue 3211 3211 IN IP4 222.222.2.27
s=-
c=IN IP4 222.222.2.27
b=AS:41
b=RR:1537
b=RS:512
t=0 0
m=audio 31022 RTP/AVP 107 106 105 104 101 102
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:106 AMR-WB/16000/1
a=fmtp:106 octet-align=1;mode-change-capability=2;max-red=0
a=rtpmap:105 AMR/8000/1
a=fmtp:105 mode-change-capability=2;max-red=0
a=rtpmap:104 AMR/8000/1
a=fmtp:104 octet-align=1;mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=rtpmap:102 telephone-event/8000
a=fmtp:102 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local none
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos optional remote sendrecv
```
### 2.2 Trying 
```
SIP/2.0 100 Trying
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKswecbCEJ7GcqBMwaay6Y;rport=5060
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
CSeq: 1 INVITE
Server: IM-Sever/OMA5.1
Content-Length: 0
```
### 2.3 183 Session Progress
```
SIP/2.0 183 Session Progress
P-Preferred-Identity: <sip:+8616500000062@ims.mnc000.mcc000.3gppnetwork.org>
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Require: 100rel,precondition
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Type: application/sdp
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKswecbCEJ7GcqBMwaay6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
CSeq: 1 INVITE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Session-Expires: 1800
RSeq: 1
Content-Length: 487

v=0
o=rue 3219 3219 IN IP4 172.16.106.38
s=-
c=IN IP4 172.16.106.38
b=AS:41
b=RR:1537
b=RS:512
t=0 0
m=audio 30052 RTP/AVP 107 101
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local none
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
a=conf:qos remote sendrecv
```
### 2.4 PRACK 
```
PRACK sip:+8616500000062@172.16.106.38:5060;transport=udp SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
To: "8616500000062"<tel:+8616500000062>;tag=464889803917
Call-ID: quecbSk9i@222.222.2.27
CSeq: 2 PRACK
Max-Forwards: 70
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKtxecbCEJ7GcqBMwaaq6Y;rport
RAck: 1 1 INVITE
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Length: 0
```
### 2.5 200 OK
```
SIP/2.0 200 OK
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKtxecbCEJ7GcqBMwaaq6Y;rport=5060
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
CSeq: 2 PRACK
Server: IM-Sever/OMA5.1
Content-Length: 0
```

### 2.6 UPDATE
```
UPDATE sip:+8616500000062@172.16.106.38:5060;transport=udp SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
To: "8616500000062"<tel:+8616500000062>;tag=464889803917
Contact: <sip:+8616500000061@222.222.2.27:5060>;+sip.instance="<urn:gsma:imei:86354104-407800-0>";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting;+g.3gpp.ps2cs-srvcc-orig-pre-alerting
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Require: precondition,sec-agree
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Proxy-Require: sec-agree
Call-ID: quecbSk9i@222.222.2.27
CSeq: 3 UPDATE
Max-Forwards: 70
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKqyecbCEJ7GcqBMwaaW6Y;rport
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Type: application/sdp
Content-Length: 461

v=0
o=rue 3211 3212 IN IP4 222.222.2.27
s=-
c=IN IP4 222.222.2.27
b=AS:41
b=RR:1537
b=RS:512
t=0 0
m=audio 31022 RTP/AVP 107 101
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local sendrecv
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
```
### 2.7 200 OK
```
SIP/2.0 200 OK
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Min-SE: 90
Require: precondition,timer
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Session-Expires: 1800;refresher=uas
Content-Type: application/sdp
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKqyecbCEJ7GcqBMwaaW6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
CSeq: 3 UPDATE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Content-Length: 467

v=0
o=rue 3219 3220 IN IP4 172.16.106.38
s=-
c=IN IP4 172.16.106.38
b=AS:41
b=RR:1537
b=RS:512
t=0 0
m=audio 30052 RTP/AVP 107 101
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local sendrecv
a=curr:qos remote sendrecv
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
SIP/2.0 180 Ringing
P-Preferred-Identity: <sip:+8616500000062@ims.mnc000.mcc000.3gppnetwork.org>
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKswecbCEJ7GcqBMwaay6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
CSeq: 1 INVITE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Session-Expires: 1800
Content-Length: 0
```
### 2.8 200 OK
```
SIP/2.0 200 OK
P-Preferred-Identity: <sip:+8616500000062@ims.mnc000.mcc000.3gppnetwork.org>
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Min-SE: 90
Require: timer
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Session-Expires: 1800;refresher=uas
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKswecbCEJ7GcqBMwaay6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
CSeq: 1 INVITE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Content-Length: 0
```
### 2.9 ACK
```
ACK sip:+8616500000062@172.16.106.38:5060;transport=udp SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
To: "8616500000062"<tel:+8616500000062>;tag=464889803917
Contact: <sip:+8616500000061@222.222.2.27:5060>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Require: sec-agree
Proxy-Require: sec-agree
Call-ID: quecbSk9i@222.222.2.27
CSeq: 1 ACK
Max-Forwards: 70
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKrzecbCEJ7GcqBMwaaCcs;rport
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Length: 0
```
### 2.10 200 OK

```

SIP/2.0 200 OK
Server: IM-Sever/OMA5.1
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKrzecbCEJ7GcqBMwaaCcs;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=464889803917
CSeq: 1 ACK
Max-Forwards: 70
Content-Length: 0
```
### 2.11 BYE
```
BYE sip:+8616500000061@222.222.2.27:5060 SIP/2.0
Reason: SIP;cause=200;text="User term the call."
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Require: sec-agree
Proxy-Require: sec-agree
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Max-Forwards: 68
CSeq: 1 BYE
Call-ID: quecbSk9i@222.222.2.27
From: "8616500000062" <tel:+8616500000062>;tag=464889803917
To: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Via: SIP/2.0/UDP 172.16.106.38:5060;branch=z9hG4bK948fb923faf4;rport=54872
Via: SIP/2.0/TCP 172.16.106.38:6060;branch=z9hG4bKe104ab646147;rport=59226
Via: SIP/2.0/TCP 222.222.2.29:6070;branch=z9hG4bKIQecbQDRYGizsRqaayaZ;rport=41222;received=172.16.106.38
Record-Route: <sip:172.16.106.38:6060;transport=tcp;lr>
Record-Route: <sip:172.16.106.38:6060;transport=tcp;lr>
Content-Length: 0
```
### 2.12 200 OK
```
SIP/2.0 200 OK
From: "8616500000062"<tel:+8616500000062>;tag=464889803917
To: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=rvecbSk
Call-ID: quecbSk9i@222.222.2.27
CSeq: 1 BYE
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Via: SIP/2.0/UDP 172.16.106.38:5060;branch=z9hG4bK948fb923faf4;rport=5060
Via: SIP/2.0/TCP 172.16.106.38:6060;branch=z9hG4bKe104ab646147;rport=59226
Via: SIP/2.0/TCP 222.222.2.29:6070;branch=z9hG4bKIQecbQDRYGizsRqaayaZ;rport=41222;received=172.16.106.38
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Length: 0
```
## 3.视频通话

### 3.1 INVITE
```
INVITE tel:+8616500000062 SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
To: "8616500000062"<tel:+8616500000062>
P-Preferred-Identity: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>
Contact: <sip:+8616500000061@222.222.2.27:5060>;+sip.instance="<urn:gsma:imei:86354104-407800-0>";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting;+g.3gpp.ps2cs-srvcc-orig-pre-alerting
Accept-Contact: *;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";video
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
P-Preferred-Service: urn:urn-7:3gpp-service.ims.icsi.mmtel
P-Early-Media: supported
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Accept: application/sdp,application/3gpp-ims+xml
Session-Expires: 1800
Min-SE: 90
Route: <sip:172.16.106.38:5060;lr>
Require: sec-agree
Proxy-Require: sec-agree
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 1 INVITE
Max-Forwards: 70
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKckecbmOloqn5UNvaay6Y;rport
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Type: application/sdp
Content-Length: 1596

v=0
o=rue 3209 3209 IN IP4 222.222.2.27
s=-
c=IN IP4 222.222.2.27
b=AS:1001
b=RR:7537
b=RS:8512
t=0 0
m=audio 31018 RTP/AVP 107 106 105 104 101 102
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:106 AMR-WB/16000/1
a=fmtp:106 octet-align=1;mode-change-capability=2;max-red=0
a=rtpmap:105 AMR/8000/1
a=fmtp:105 mode-change-capability=2;max-red=0
a=rtpmap:104 AMR/8000/1
a=fmtp:104 octet-align=1;mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=rtpmap:102 telephone-event/8000
a=fmtp:102 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local none
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos optional remote sendrecv
m=video 37058 RTP/AVP 120 123
b=AS:960
b=RR:6000
b=RS:8000
a=tcap:1 RTP/AVPF
a=pcfg:1 t=1
a=rtpmap:120 H265/90000
a=fmtp:120 profile-id=1; level-id=93; max-br=1340
a=imageattr:120 send [x=480,y=640] [x=360,y=480] [x=240,y=320] recv [x=480,y=640] [x=360,y=480] [x=240,y=320]
a=rtpmap:123 H264/90000
a=fmtp:123 profile-level-id=42C01F; packetization-mode=1; max-br=974; sprop-parameter-sets=Z0LAHtoHgUSAeEAhUA==,aM48gA==
a=imageattr:123 send [x=480,y=640] [x=360,y=480] [x=240,y=320] recv [x=480,y=640] [x=360,y=480] [x=240,y=320]
a=rtcp-fb:* trr-int 5000
a=rtcp-fb:* nack
a=rtcp-fb:* nack pli
a=rtcp-fb:* ccm fir
a=rtcp-fb:* ccm tmmbr
a=sendrecv
a=extmap:7 urn:3gpp:video-orientation
a=curr:qos local none
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos optional remote sendrecv
```
### 3.2 100 Trying
```
SIP/2.0 100 Trying
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKckecbmOloqn5UNvaay6Y;rport=5060
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 1 INVITE
Server: IM-Sever/OMA5.1
Content-Length: 0
```
### 3.3 183 Session Progress
```
SIP/2.0 183 Session Progress
P-Preferred-Identity: <sip:+8616500000062@ims.mnc000.mcc000.3gppnetwork.org>
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Require: 100rel,precondition
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Type: application/sdp
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKckecbmOloqn5UNvaay6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
CSeq: 1 INVITE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Session-Expires: 1800
RSeq: 1
Content-Length: 1059

v=0
o=rue 3217 3217 IN IP4 172.16.106.38
s=-
c=IN IP4 172.16.106.38
b=AS:1001
b=RR:7537
b=RS:8512
t=0 0
m=audio 30016 RTP/AVP 107 101
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local none
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
a=conf:qos remote sendrecv
m=video 30018 RTP/AVPF 120
b=AS:960
b=RR:6000
b=RS:8000
a=acfg:1 t=1
a=rtpmap:120 H265/90000
a=fmtp:120 profile-id=1; level-id=93; max-br=974
a=imageattr:120 send [x=480,y=640] [x=360,y=480] [x=240,y=320] recv [x=480,y=640] [x=360,y=480] [x=240,y=320]
a=rtcp-fb:* trr-int 5000
a=rtcp-fb:* nack
a=rtcp-fb:* nack pli
a=rtcp-fb:* ccm fir
a=rtcp-fb:* ccm tmmbr
a=sendrecv
a=extmap:7 urn:3gpp:video-orientation
a=curr:qos local none
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
a=conf:qos remote sendrecv
```
### 3.4 PRACK
```
PRACK sip:+8616500000062@172.16.106.38:5060;transport=udp SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
To: "8616500000062"<tel:+8616500000062>;tag=635653312983
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 2 PRACK
Max-Forwards: 70
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKdlecbSk9iWVQOxwaaq6Y;rport
RAck: 1 1 INVITE
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Length: 0
```
### 3.5 200 OK
```
SIP/2.0 200 OK
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKdlecbSk9iWVQOxwaaq6Y;rport=5060
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 2 PRACK
Server: IM-Sever/OMA5.1
Content-Length: 0
```
### 3.6 UPDATE
```
UPDATE sip:+8616500000062@172.16.106.38:5060;transport=udp SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
To: "8616500000062"<tel:+8616500000062>;tag=635653312983
Contact: <sip:+8616500000061@222.222.2.27:5060>;+sip.instance="<urn:gsma:imei:86354104-407800-0>";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting;+g.3gpp.ps2cs-srvcc-orig-pre-alerting
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Require: precondition,sec-agree
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Proxy-Require: sec-agree
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 3 UPDATE
Max-Forwards: 70
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKamecbSk9iWVQOxwaaW6Y;rport
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Type: application/sdp
Content-Length: 995

v=0
o=rue 3209 3210 IN IP4 222.222.2.27
s=-
c=IN IP4 222.222.2.27
b=AS:1001
b=RR:7537
b=RS:8512
t=0 0
m=audio 31018 RTP/AVP 107 101
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local sendrecv
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
m=video 37058 RTP/AVPF 120
b=AS:960
b=RR:6000
b=RS:8000
a=rtpmap:120 H265/90000
a=fmtp:120 profile-id=1; level-id=93; max-br=974
a=imageattr:120 send [x=480,y=640] [x=360,y=480] [x=240,y=320] recv [x=480,y=640] [x=360,y=480] [x=240,y=320]
a=rtcp-fb:* trr-int 5000
a=rtcp-fb:* nack
a=rtcp-fb:* nack pli
a=rtcp-fb:* ccm fir
a=rtcp-fb:* ccm tmmbr
a=sendrecv
a=extmap:7 urn:3gpp:video-orientation
a=curr:qos local sendrecv
a=curr:qos remote none
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
```
### 3.7 200 OK
```
SIP/2.0 200 OK
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Min-SE: 90
Require: precondition,timer
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Session-Expires: 1800;refresher=uas
Content-Type: application/sdp
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKamecbSk9iWVQOxwaaW6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
CSeq: 3 UPDATE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Content-Length: 1005

v=0
o=rue 3217 3218 IN IP4 172.16.106.38
s=-
c=IN IP4 172.16.106.38
b=AS:1001
b=RR:7537
b=RS:8512
t=0 0
m=audio 30016 RTP/AVP 107 101
b=AS:41
b=RR:1537
b=RS:512
a=rtpmap:107 AMR-WB/16000/1
a=fmtp:107 mode-change-capability=2;max-red=0
a=rtpmap:101 telephone-event/16000
a=fmtp:101 0-15
a=ptime:20
a=maxptime:240
a=sendrecv
a=curr:qos local sendrecv
a=curr:qos remote sendrecv
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
m=video 30018 RTP/AVPF 120
b=AS:960
b=RR:6000
b=RS:8000
a=rtpmap:120 H265/90000
a=fmtp:120 profile-id=1; level-id=93; max-br=974
a=imageattr:120 send [x=480,y=640] [x=360,y=480] [x=240,y=320] recv [x=480,y=640] [x=360,y=480] [x=240,y=320]
a=rtcp-fb:* trr-int 5000
a=rtcp-fb:* nack
a=rtcp-fb:* nack pli
a=rtcp-fb:* ccm fir
a=rtcp-fb:* ccm tmmbr
a=sendrecv
a=extmap:7 urn:3gpp:video-orientation
a=curr:qos local sendrecv
a=curr:qos remote sendrecv
a=des:qos mandatory local sendrecv
a=des:qos mandatory remote sendrecv
SIP/2.0 180 Ringing
P-Preferred-Identity: <sip:+8616500000062@ims.mnc000.mcc000.3gppnetwork.org>
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKckecbmOloqn5UNvaay6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
CSeq: 1 INVITE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Session-Expires: 1800
Content-Length: 0
```
### 3.8 200 OK
```
SIP/2.0 200 OK
P-Preferred-Identity: <sip:+8616500000062@ims.mnc000.mcc000.3gppnetwork.org>
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
Allow: INVITE,ACK,OPTIONS,BYE,CANCEL,UPDATE,INFO,PRACK,NOTIFY,MESSAGE,REFER
Min-SE: 90
Require: timer
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Session-Expires: 1800;refresher=uas
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKckecbmOloqn5UNvaay6Y;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
CSeq: 1 INVITE
Max-Forwards: 70
Contact: <sip:+8616500000062@172.16.106.38:5060;transport=udp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";audio;video;+g.3gpp.mid-call;+g.3gpp.srvcc-alerting
Content-Length: 0
```
### 3.9 ACK

```
ACK sip:+8616500000062@172.16.106.38:5060;transport=udp SIP/2.0
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
To: "8616500000062"<tel:+8616500000062>;tag=635653312983
Contact: <sip:+8616500000061@222.222.2.27:5060>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Require: sec-agree
Proxy-Require: sec-agree
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 1 ACK
Max-Forwards: 70
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKbnecbSk9iWVQOxwaaCcs;rport
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Length: 0
```

### 3.10 200 OK

```
SIP/2.0 200 OK
Server: IM-Sever/OMA5.1
Via: SIP/2.0/UDP 222.222.2.27:5060;branch=z9hG4bKbnecbSk9iWVQOxwaaCcs;rport=5060
From: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
To: "8616500000062" <tel:+8616500000062>;tag=635653312983
CSeq: 1 ACK
Max-Forwards: 70
Content-Length: 0
```

### 3.11 BYE

```
BYE sip:+8616500000061@222.222.2.27:5060 SIP/2.0
Reason: SIP;cause=200;text="User term the call."
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer,sec-agree
Require: sec-agree
Proxy-Require: sec-agree
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Max-Forwards: 68
CSeq: 1 BYE
Call-ID: aiecbmOlo@222.222.2.27
From: "8616500000062" <tel:+8616500000062>;tag=635653312983
To: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Via: SIP/2.0/UDP 172.16.106.38:5060;branch=z9hG4bK8390bf49a6da;rport=54872
Via: SIP/2.0/TCP 172.16.106.38:6060;branch=z9hG4bK0e2a771d7b17;rport=59226
Via: SIP/2.0/TCP 222.222.2.29:6070;branch=z9hG4bKIMecbQDRYGizsRqaayaZ;rport=41222;received=172.16.106.38
Record-Route: <sip:172.16.106.38:6060;transport=tcp;lr>
Record-Route: <sip:172.16.106.38:6060;transport=tcp;lr>
Content-Length: 0
```
### 3.12 200 OK

```
SIP/2.0 200 OK
From: "8616500000062"<tel:+8616500000062>;tag=635653312983
To: <sip:+8616500000061@ims.mnc000.mcc000.3gppnetwork.org>;tag=bjecbmO
Call-ID: aiecbmOlo@222.222.2.27
CSeq: 1 BYE
Supported: 100rel,histinfo,join,norefersub,precondition,replaces,timer
P-Access-Network-Info: 3GPP-NR-TDD;utran-cell-id-3gpp=4600000112207A123000
Via: SIP/2.0/UDP 172.16.106.38:5060;branch=z9hG4bK8390bf49a6da;rport=5060
Via: SIP/2.0/TCP 172.16.106.38:6060;branch=z9hG4bK0e2a771d7b17;rport=59226
Via: SIP/2.0/TCP 222.222.2.29:6070;branch=z9hG4bKIMecbQDRYGizsRqaayaZ;rport=41222;received=172.16.106.38
User-Agent: IM-client/OMA1.0 HW-Rto/V1.0
Content-Length: 0

```