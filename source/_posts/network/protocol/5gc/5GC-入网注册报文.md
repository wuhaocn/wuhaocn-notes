---
title: 5GC-入网注册报文

categories:
- 5G

tag:
- 5G
---
### 1.总体流程

业务流程

![image.png](https://cdn.nlark.com/yuque/0/2021/png/804884/1627391117254-6a03844b-4b03-48cf-9627-b467ca6564fa.png#clientId=u3633912e-e1d8-4&from=paste&height=826&id=u3d62431a&margin=%5Bobject%20Object%5D&name=image.png&originHeight=826&originWidth=841&originalType=binary&ratio=1&size=228847&status=done&style=none&taskId=u2addc2dd-1a6b-4d56-81eb-4ef03b62ca3&width=841)

### 2.流程报文

#### 2.1 Registration request

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-InitialUEMessage (15)
        criticality: ignore (1)
        value
            InitialUEMessage
                protocolIEs: 5 items
                    Item 0: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 1: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: reject (0)
                            value
                                NAS-PDU: 7e004179000d0164f000f0ff000001400224022e02f0f0
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: Registration request (0x41)
                                            5GS registration type
                                                .... 1... = Follow-On Request bit (FOR): Follow-on request pending
                                                .... .001 = 5GS registration type: initial registration (1)
                                            NAS key set identifier
                                                0... .... = Type of security context flag (TSC): Native security context (for KSIAMF)
                                                .111 .... = NAS key set identifier: 7
                                            5GS mobile identity
                                                Length: 13
                                                0... .... = Spare: 0
                                                .000 .... = SUPI format: IMSI (0)
                                                .... 0... = Spare: 0
                                                .... .001 = Type of identity: SUCI (1)
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                                Routing indicator: 0
                                                .... 0000 = Protection scheme Id: NULL scheme (0)
                                                Home network public key identifier: 0
                                                Scheme output: 1004204220
                                            UE security capability
                                                Element ID: 0x2e
                                                Length: 2
                                                1... .... = 5G-EA0: Supported
                                                .1.. .... = 128-5G-EA1: Supported
                                                ..1. .... = 128-5G-EA2: Supported
                                                ...1 .... = 128-5G-EA3: Supported
                                                .... 0... = 5G-EA4: Not supported
                                                .... .0.. = 5G-EA5: Not supported
                                                .... ..0. = 5G-EA6: Not supported
                                                .... ...0 = 5G-EA7: Not supported
                                                1... .... = 5G-IA0: Supported
                                                .1.. .... = 128-5G-IA1: Supported
                                                ..1. .... = 128-5G-IA2: Supported
                                                ...1 .... = 128-5G-IA3: Supported
                                                .... 0... = 5G-IA4: Not supported
                                                .... .0.. = 5G-IA5: Not supported
                                                .... ..0. = 5G-IA6: Not supported
                                                .... ...0 = 5G-IA7: Not supported
                    Item 2: id-UserLocationInformation
                        ProtocolIE-Field
                            id: id-UserLocationInformation (121)
                            criticality: reject (0)
                            value
                                UserLocationInformation: userLocationInformationNR (1)
                                    userLocationInformationNR
                                        nR-CGI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            nRCellIdentity: 0x00044880f0
                                        tAI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            tAC: 4388 (0x001124)
                    Item 3: id-RRCEstablishmentCause
                        ProtocolIE-Field
                            id: id-RRCEstablishmentCause (90)
                            criticality: ignore (1)
                            value
                                RRCEstablishmentCause: mo-Signalling (3)
                    Item 4: id-UEContextRequest
                        ProtocolIE-Field
                            id: id-UEContextRequest (112)
                            criticality: ignore (1)
                            value
                                UEContextRequest: requested (0)
```

#### 2.2 Authentication request

```
initiatingMessage
    procedureCode: id-DownlinkNASTransport (4)
    criticality: ignore (1)
    value
        DownlinkNASTransport
            protocolIEs: 3 items
                Item 0: id-AMF-UE-NGAP-ID
                    ProtocolIE-Field
                        id: id-AMF-UE-NGAP-ID (10)
                        criticality: reject (0)
                        value
                            AMF-UE-NGAP-ID: 2155872278
                Item 1: id-RAN-UE-NGAP-ID
                    ProtocolIE-Field
                        id: id-RAN-UE-NGAP-ID (85)
                        criticality: reject (0)
                        value
                            RAN-UE-NGAP-ID: 4194571
                Item 2: id-NAS-PDU
                    ProtocolIE-Field
                        id: id-NAS-PDU (38)
                        criticality: reject (0)
                        value
                            NAS-PDU: 7e0056000200002125e821e3a8691f4997ac4956ac6569a8…
                                Non-Access-Stratum 5GS (NAS)PDU
                                    Plain NAS 5GS Message
                                        Extended protocol discriminator: 5G mobility management messages (126)
                                        0000 .... = Spare Half Octet: 0
                                        .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                        Message type: Authentication request (0x56)
                                        0000 .... = Spare Half Octet: 0
                                        NAS key set identifier - ngKSI
                                            .... 0... = Type of security context flag (TSC): Native security context (for KSIAMF)
                                            .... .000 = NAS key set identifier: 0
                                        ABBA
                                            Length: 2
                                            ABBA Contents: 0x0000
                                        Authentication Parameter RAND - 5G authentication challenge
                                            Element ID: 0x21
                                            RAND value: 25e821e3a8691f4997ac4956ac6569a8
                                        Authentication Parameter AUTN (UMTS and EPS authentication challenge) - 5G authentication challenge
                                            Element ID: 0x20
                                            Length: 16
                                            AUTN value: 00c6123fefd980001404cf321750dc4c
                                                SQN xor AK: 00c6123fefd9
                                                AMF: 8000
                                                MAC: 1404cf321750dc4c
```

#### 2.3 Authentication response

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-UplinkNASTransport (46)
        criticality: ignore (1)
        value
            UplinkNASTransport
                protocolIEs: 4 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: reject (0)
                            value
                                NAS-PDU: 7e00572d10481e2e467f57406efa0caf1e985956ab
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: Authentication response (0x57)
                                            Authentication response parameter
                                                Element ID: 0x2d
                                                Length: 16
                                                RES: 481e2e467f57406efa0caf1e985956ab
                    Item 3: id-UserLocationInformation
                        ProtocolIE-Field
                            id: id-UserLocationInformation (121)
                            criticality: ignore (1)
                            value
                                UserLocationInformation: userLocationInformationNR (1)
                                    userLocationInformationNR
                                        nR-CGI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            nRCellIdentity: 0x00044880f0
                                        tAI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            tAC: 4388 (0x001124)
```

#### 2.4 Security mode command

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-DownlinkNASTransport (4)
        criticality: ignore (1)
        value
            DownlinkNASTransport
                protocolIEs: 3 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: reject (0)
                            value
                                NAS-PDU: 7e039b1e5653007e005d030002f0f057033601021904f0f0…
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Security protected NAS 5GS message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0011 = Security header type: Integrity protected with new 5GS security context (3)
                                            Message authentication code: 0x9b1e5653
                                            Sequence number: 0
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: Security mode command (0x5d)
                                            NAS security algorithms
                                                0000 .... = Type of ciphering algorithm: 5G-EA0 (null ciphering algorithm) (0)
                                                .... 0011 = Type of integrity protection algorithm: 128-5G-IA3 (3)
                                            0000 .... = Spare Half Octet: 0
                                            NAS key set identifier - ngKSI
                                                .... 0... = Type of security context flag (TSC): Native security context (for KSIAMF)
                                                .... .000 = NAS key set identifier: 0
                                            UE security capability - Replayed UE security capabilities
                                                Length: 2
                                                1... .... = 5G-EA0: Supported
                                                .1.. .... = 128-5G-EA1: Supported
                                                ..1. .... = 128-5G-EA2: Supported
                                                ...1 .... = 128-5G-EA3: Supported
                                                .... 0... = 5G-EA4: Not supported
                                                .... .0.. = 5G-EA5: Not supported
                                                .... ..0. = 5G-EA6: Not supported
                                                .... ...0 = 5G-EA7: Not supported
                                                1... .... = 5G-IA0: Supported
                                                .1.. .... = 128-5G-IA1: Supported
                                                ..1. .... = 128-5G-IA2: Supported
                                                ...1 .... = 128-5G-IA3: Supported
                                                .... 0... = 5G-IA4: Not supported
                                                .... .0.. = 5G-IA5: Not supported
                                                .... ..0. = 5G-IA6: Not supported
                                                .... ...0 = 5G-IA7: Not supported
                                            NAS security algorithms - Selected EPS NAS security algorithms
                                                Element ID: 0x57
                                                0... .... = Spare bit(s): 0x00
                                                .000 .... = Type of ciphering algorithm: EPS encryption algorithm EEA0 (null ciphering algorithm) (0)
                                                .... 0... = Spare bit(s): 0x00
                                                .... .011 = Type of integrity protection algorithm: EPS integrity algorithm 128-EIA3 (3)
                                            Additional 5G security information
                                                Element ID: 0x36
                                                Length: 1
                                                .... 0... = Spare: 0
                                                .... .0.. = Spare: 0
                                                .... ..1. = Retransmission of initial NAS message request(RINMR): Requested
                                                .... ...0 = Horizontal derivation parameter (HDP): Not required
                                            UE security capability - Replayed S1 UE security capabilities
                                                Element ID: 0x19
                                                Length: 4
                                                1... .... = EEA0: Supported
                                                .1.. .... = 128-EEA1: Supported
                                                ..1. .... = 128-EEA2: Supported
                                                ...1 .... = 128-EEA3: Supported
                                                .... 0... = EEA4: Not supported
                                                .... .0.. = EEA5: Not supported
                                                .... ..0. = EEA6: Not supported
                                                .... ...0 = EEA7: Not supported
                                                1... .... = EIA0: Supported
                                                .1.. .... = 128-EIA1: Supported
                                                ..1. .... = 128-EIA2: Supported
                                                ...1 .... = 128-EIA3: Supported
                                                .... 0... = EIA4: Not supported
                                                .... .0.. = EIA5: Not supported
                                                .... ..0. = EIA6: Not supported
                                                .... ...0 = EIA7: Not supported
                                                1... .... = UEA0: Supported
                                                .1.. .... = UEA1: Supported
                                                ..0. .... = UEA2: Not supported
                                                ...0 .... = UEA3: Not supported
                                                .... 0... = UEA4: Not supported
                                                .... .0.. = UEA5: Not supported
                                                .... ..0. = UEA6: Not supported
                                                .... ...0 = UEA7: Not supported
                                                1... .... = Spare bit(s): 0x1
                                                .1.. .... = UMTS integrity algorithm UIA1: Supported
                                                ..0. .... = UMTS integrity algorithm UIA2: Not supported
                                                ...0 .... = UMTS integrity algorithm UIA3: Not supported
                                                .... 0... = UMTS integrity algorithm UIA4: Not supported
                                                .... .0.. = UMTS integrity algorithm UIA5: Not supported
                                                .... ..0. = UMTS integrity algorithm UIA6: Not supported
                                                .... ...0 = UMTS integrity algorithm UIA7: Not supported
```

#### 2.5 Security mode complete Registration request

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-UplinkNASTransport (46)
        criticality: ignore (1)
        value
            UplinkNASTransport
                protocolIEs: 4 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: reject (0)
                            value
                                NAS-PDU: 7e04504ffe7e007e005e7100307e004179000d0164f000f0…
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Security protected NAS 5GS message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0100 = Security header type: Integrity protected and ciphered with new 5GS security context (4)
                                            Message authentication code: 0x504ffe7e
                                            Sequence number: 0
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: Security mode complete (0x5e)
                                            NAS message container
                                                Element ID: 0x71
                                                Length: 48
                                                Non-Access-Stratum 5GS (NAS)PDU
                                                    Plain NAS 5GS Message
                                                        Extended protocol discriminator: 5G mobility management messages (126)
                                                        0000 .... = Spare Half Octet: 0
                                                        .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                                        Message type: Registration request (0x41)
                                                        5GS registration type
                                                            .... 1... = Follow-On Request bit (FOR): Follow-on request pending
                                                            .... .001 = 5GS registration type: initial registration (1)
                                                        NAS key set identifier
                                                            0... .... = Type of security context flag (TSC): Native security context (for KSIAMF)
                                                            .111 .... = NAS key set identifier: 7
                                                        5GS mobile identity
                                                            Length: 13
                                                            0... .... = Spare: 0
                                                            .000 .... = SUPI format: IMSI (0)
                                                            .... 0... = Spare: 0
                                                            .... .001 = Type of identity: SUCI (1)
                                                            Mobile Country Code (MCC): China (000)
                                                            Mobile Network Code (MNC): China Mobile (00)
                                                            Routing indicator: 0
                                                            .... 0000 = Protection scheme Id: NULL scheme (0)
                                                            Home network public key identifier: 0
                                                            Scheme output: 1004204220
                                                        5GMM capability
                                                            Element ID: 0x10
                                                            Length: 1
                                                            0... .... = Spare: 0
                                                            .0.. .... = Spare: 0
                                                            ..0. .... = Spare: 0
                                                            ...0 .... = Spare: 0
                                                            .... 0... = Spare: 0
                                                            .... .0.. = LTE Positioning Protocol (LPP) capability: Not Requested
                                                            .... ..1. = HO attach: Supported
                                                            .... ...1 = S1 mode: Requested
                                                        UE security capability
                                                            Element ID: 0x2e
                                                            Length: 2
                                                            1... .... = 5G-EA0: Supported
                                                            .1.. .... = 128-5G-EA1: Supported
                                                            ..1. .... = 128-5G-EA2: Supported
                                                            ...1 .... = 128-5G-EA3: Supported
                                                            .... 0... = 5G-EA4: Not supported
                                                            .... .0.. = 5G-EA5: Not supported
                                                            .... ..0. = 5G-EA6: Not supported
                                                            .... ...0 = 5G-EA7: Not supported
                                                            1... .... = 5G-IA0: Supported
                                                            .1.. .... = 128-5G-IA1: Supported
                                                            ..1. .... = 128-5G-IA2: Supported
                                                            ...1 .... = 128-5G-IA3: Supported
                                                            .... 0... = 5G-IA4: Not supported
                                                            .... .0.. = 5G-IA5: Not supported
                                                            .... ..0. = 5G-IA6: Not supported
                                                            .... ...0 = 5G-IA7: Not supported
                                                        NSSAI - Requested NSSAI
                                                            Element ID: 0x2f
                                                            Length: 5
                                                            S-NSSAI 1
                                                                Length: 4
                                                                Slice/service type (SST): 1
                                                                Slice differentiator (SD): 1
                                                        UE network capability
                                                            Element ID: 0x17
                                                            Length: 7
                                                            1... .... = EEA0: Supported
                                                            .1.. .... = 128-EEA1: Supported
                                                            ..1. .... = 128-EEA2: Supported
                                                            ...1 .... = 128-EEA3: Supported
                                                            .... 0... = EEA4: Not supported
                                                            .... .0.. = EEA5: Not supported
                                                            .... ..0. = EEA6: Not supported
                                                            .... ...0 = EEA7: Not supported
                                                            1... .... = EIA0: Supported
                                                            .1.. .... = 128-EIA1: Supported
                                                            ..1. .... = 128-EIA2: Supported
                                                            ...1 .... = 128-EIA3: Supported
                                                            .... 0... = EIA4: Not supported
                                                            .... .0.. = EIA5: Not supported
                                                            .... ..0. = EIA6: Not supported
                                                            .... ...0 = EIA7: Not supported
                                                            1... .... = UEA0: Supported
                                                            .1.. .... = UEA1: Supported
                                                            ..0. .... = UEA2: Not supported
                                                            ...0 .... = UEA3: Not supported
                                                            .... 0... = UEA4: Not supported
                                                            .... .0.. = UEA5: Not supported
                                                            .... ..0. = UEA6: Not supported
                                                            .... ...0 = UEA7: Not supported
                                                            1... .... = UCS2 support (UCS2): The UE has no preference between the use of the default alphabet and the use of UCS2
                                                            .1.. .... = UMTS integrity algorithm UIA1: Supported
                                                            ..0. .... = UMTS integrity algorithm UIA2: Not supported
                                                            ...0 .... = UMTS integrity algorithm UIA3: Not supported
                                                            .... 0... = UMTS integrity algorithm UIA4: Not supported
                                                            .... .0.. = UMTS integrity algorithm UIA5: Not supported
                                                            .... ..0. = UMTS integrity algorithm UIA6: Not supported
                                                            .... ...0 = UMTS integrity algorithm UIA7: Not supported
                                                            0... .... = ProSe direct discovery: Not supported
                                                            .0.. .... = ProSe: Not supported
                                                            ..0. .... = H.245 After SRVCC Handover: Not supported
                                                            ...0 .... = Access class control for CSFB: Not supported
                                                            .... 0... = LTE Positioning Protocol: Not supported
                                                            .... .0.. = Location services (LCS) notification mechanisms: Not supported
                                                            .... ..0. = SRVCC from E-UTRAN to cdma2000 1xCS: Not supported
                                                            .... ...1 = Notification procedure: Supported
                                                            1... .... = Extended protocol configuration options: Supported
                                                            .0.. .... = Header compression for control plane CIoT EPS optimization: Not supported
                                                            ..0. .... = EMM-REGISTERED w/o PDN connectivity: Not supported
                                                            ...0 .... = S1-U data transfer: Not supported
                                                            .... 0... = User plane CIoT EPS optimization: Not supported
                                                            .... .0.. = Control plane CIoT EPS optimization: Not supported
                                                            .... ..0. = ProSe UE-to-network relay: Not supported
                                                            .... ...0 = ProSe direct communication: Not supported
                                                            0... .... = Spare bit(s): 0x00
                                                            0... .... = Signalling for a maximum number of 15 EPS bearer contexts: Not supported
                                                            .0.. .... = Service gap control: Not supported
                                                            ..1. .... = N1 mode: Supported
                                                            ...1 .... = Dual connectivity with NR: Supported
                                                            .... 0... = Control plane data backoff: Not supported
                                                            .... .0.. = Restriction on use of enhanced coverage: Not supported
                                                            .... ..0. = V2X communication over PC5: Not supported
                                                            .... ...0 = Multiple DRB: Not supported
                                                        UE's usage setting
                                                            Element ID: 0x18
                                                            Length: 1
                                                            .... 0... = Spare: 0
                                                            .... .0.. = Spare: 0
                                                            .... ..0. = Spare: 0
                                                            .... ...0 = UE's usage setting: Voice centric
                                                        5GS update type
                                                            Element ID: 0x53
                                                            Length: 1
                                                            .... 0... = Spare: 0
                                                            .... .0.. = Spare: 0
                                                            .... ..0. = NG-RAN Radio Capability Update (NG-RAN-RCU): Not Needed
                                                            .... ...1 = SMS requested: SMS over NAS supported
                    Item 3: id-UserLocationInformation
                        ProtocolIE-Field
                            id: id-UserLocationInformation (121)
                            criticality: ignore (1)
                            value
                                UserLocationInformation: userLocationInformationNR (1)
                                    userLocationInformationNR
                                        nR-CGI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            nRCellIdentity: 0x00044880f0
                                        tAI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            tAC: 4388 (0x001124)
```

#### 2.6 InitialContextSetupRequest Registration Accept

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-InitialContextSetup (14)
        criticality: reject (0)
        value
            InitialContextSetupRequest
                protocolIEs: 11 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-UEAggregateMaximumBitRate
                        ProtocolIE-Field
                            id: id-UEAggregateMaximumBitRate (110)
                            criticality: reject (0)
                            value
                                UEAggregateMaximumBitRate
                                    uEAggregateMaximumBitRateDL: 1024bits/s
                                    uEAggregateMaximumBitRateUL: 256bits/s
                    Item 3: id-CoreNetworkAssistanceInformationForInactive
                        ProtocolIE-Field
                            id: id-CoreNetworkAssistanceInformationForInactive (18)
                            criticality: ignore (1)
                            value
                                CoreNetworkAssistanceInformationForInactive
                                    uEIdentityIndexValue: indexLength10 (0)
                                        indexLength10: 7200 [bit length 10, 6 LSB pad bits, 0111 0010  00.. .... decimal value 456]
                                    periodicRegistrationUpdateTimer: 0 sec (96)
                                    tAIListForInactive: 1 item
                                        Item 0
                                            TAIListForInactiveItem
                                                tAI
                                                    pLMNIdentity: 64f000
                                                        Mobile Country Code (MCC): China (000)
                                                        Mobile Network Code (MNC): China Mobile (00)
                                                    tAC: 4388 (0x001124)
                    Item 4: id-GUAMI
                        ProtocolIE-Field
                            id: id-GUAMI (28)
                            criticality: reject (0)
                            value
                                GUAMI
                                    pLMNIdentity: 64f000
                                        Mobile Country Code (MCC): China (000)
                                        Mobile Network Code (MNC): China Mobile (00)
                                    aMFRegionID: 02 [bit length 8, 0000 0010 decimal value 2]
                                    aMFSetID: 0080 [bit length 10, 6 LSB pad bits, 0000 0000  10.. .... decimal value 2]
                                    aMFPointer: 20 [bit length 6, 2 LSB pad bits, 0010 00.. decimal value 8]
                    Item 5: id-AllowedNSSAI
                        ProtocolIE-Field
                            id: id-AllowedNSSAI (0)
                            criticality: reject (0)
                            value
                                AllowedNSSAI: 1 item
                                    Item 0
                                        AllowedNSSAI-Item
                                            s-NSSAI
                                                sST: 01
                                                sD: 000001
                    Item 6: id-UESecurityCapabilities
                        ProtocolIE-Field
                            id: id-UESecurityCapabilities (119)
                            criticality: reject (0)
                            value
                                UESecurityCapabilities
                                    nRencryptionAlgorithms: e000 [bit length 16, 1110 0000  0000 0000 decimal value 57344]
                                        1... .... .... .... = 128-NEA1: Supported
                                        .1.. .... .... .... = 128-NEA2: Supported
                                        ..1. .... .... .... = 128-NEA3: Supported
                                        ...0 0000 0000 0000 = Reserved: 0x0000
                                    nRintegrityProtectionAlgorithms: e000 [bit length 16, 1110 0000  0000 0000 decimal value 57344]
                                        1... .... .... .... = 128-NIA1: Supported
                                        .1.. .... .... .... = 128-NIA2: Supported
                                        ..1. .... .... .... = 128-NIA3: Supported
                                        ...0 0000 0000 0000 = Reserved: 0x0000
                                    eUTRAencryptionAlgorithms: 0000 [bit length 16, 0000 0000  0000 0000 decimal value 0]
                                        0... .... .... .... = 128-EEA1: Not supported
                                        .0.. .... .... .... = 128-EEA2: Not supported
                                        ..0. .... .... .... = 128-EEA3: Not supported
                                        ...0 0000 0000 0000 = Reserved: 0x0000
                                    eUTRAintegrityProtectionAlgorithms: 0000 [bit length 16, 0000 0000  0000 0000 decimal value 0]
                                        0... .... .... .... = 128-EIA1: Not supported
                                        .0.. .... .... .... = 128-EIA2: Not supported
                                        ..0. .... .... .... = 128-EIA3: Not supported
                                        ...0 0000 0000 0000 = Reserved: 0x0000
                    Item 7: id-SecurityKey
                        ProtocolIE-Field
                            id: id-SecurityKey (94)
                            criticality: reject (0)
                            value
                                SecurityKey: f712ad9fc4f3cbd91bdf25d72e9a18643be1ae6ee397e209… [bit length 256]
                    Item 8: id-MobilityRestrictionList
                        ProtocolIE-Field
                            id: id-MobilityRestrictionList (36)
                            criticality: ignore (1)
                            value
                                MobilityRestrictionList
                                    servingPLMN: 64f000
                                        Mobile Country Code (MCC): China (000)
                                        Mobile Network Code (MNC): China Mobile (00)
                                    rATRestrictions: 1 item
                                        Item 0
                                            RATRestrictions-Item
                                                pLMNIdentity: 64f000
                                                    Mobile Country Code (MCC): China (000)
                                                    Mobile Network Code (MNC): China Mobile (00)
                                                rATRestrictionInformation: 00 [bit length 8, 0000 0000 decimal value 0]
                                                    0... .... = e-UTRA: Not restricted
                                                    .0.. .... = nR: Not restricted
                                                    ..00 0000 = reserved: 0x00
                                    serviceAreaInformation: 1 item
                                        Item 0
                                            ServiceAreaInformation-Item
                                                pLMNIdentity: 64f000
                                                    Mobile Country Code (MCC): China (000)
                                                    Mobile Network Code (MNC): China Mobile (00)
                                                allowedTACs: 2 items
                                                    Item 0
                                                        TAC: 4386 (0x001122)
                                                    Item 1
                                                        TAC: 4388 (0x001124)
                                    iE-Extensions: 1 item
                                        Item 0
                                            ProtocolExtensionField
                                                id: id-CNTypeRestrictionsForServing (161)
                                                criticality: ignore (1)
                                                extensionValue
                                                    CNTypeRestrictionsForServing: epc-forbidden (0)
                    Item 9: id-IndexToRFSP
                        ProtocolIE-Field
                            id: id-IndexToRFSP (31)
                            criticality: ignore (1)
                            value
                                IndexToRFSP: 8
                    Item 10: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: ignore (1)
                            value
                                NAS-PDU: 7e02af04712c017e0042010177000bf264f0000200880040…
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Security protected NAS 5GS message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0010 = Security header type: Integrity protected and ciphered (2)
                                            Message authentication code: 0xaf04712c
                                            Sequence number: 1
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: Registration accept (0x42)
                                            5GS registration result
                                                Length: 1
                                                ...0 .... = NSSAA Performed: False
                                                .... 0... = SMS over NAS: Not Allowed
                                                .... .001 = 5GS registration result: 3GPP access (1)
                                            5GS mobile identity - 5G-GUTI
                                                Element ID: 0x77
                                                Length: 11
                                                .... 0... = Odd/even indication: Even number of identity digits
                                                .... .010 = Type of identity: 5G-GUTI (2)
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                                AMF Region ID: 2
                                                0000 0000 10.. .... = AMF Set ID: 2
                                                ..00 1000 = AMF Pointer: 8
                                                5G-TMSI: 0x004001c8
                                            5GS tracking area identity list
                                                Element ID: 0x54
                                                Length: 7
                                                Partial tracking area list  1
                                                    .01. .... = Type of list: list of TACs belonging to one PLMN, with consecutive TAC values (1)
                                                    ...0 0000 = Number of elements: 1 element (0)
                                                    Mobile Country Code (MCC): China (000)
                                                    Mobile Network Code (MNC): China Mobile (00)
                                                    TAC: 4388
                                            NSSAI - Allowed NSSAI
                                                Element ID: 0x15
                                                Length: 5
                                                S-NSSAI 1
                                                    Length: 4
                                                    Slice/service type (SST): 1
                                                    Slice differentiator (SD): 1
                                            5GS network feature support
                                                Element ID: 0x21
                                                Length: 2
                                                0... .... = MPS indicator (MPSI): Access identity 1 not valid in RPLMN or equivalent PLMN
                                                .0.. .... = Interworking without N26: Not supported
                                                ..00 .... = Emergency service fallback indicator (EMF): Emergency services fallback not supported (0)
                                                .... 00.. = Emergency service support indicator (EMC): Emergency services not supported (0)
                                                .... ..0. = IMS voice over PS session over non-3GPP access indicator (IMS-VoPS-N3GPP): Not supported
                                                .... ...1 = IMS voice over PS session indicator (IMS VoPS): Supported
                                                0... .... = Spare: 0
                                                .0.. .... = Spare: 0
                                                ..0. .... = Spare: 0
                                                ...0 .... = Spare: 0
                                                .... 0... = Spare: 0
                                                .... .0.. = Spare: 0
                                                .... ..0. = MCS indicator (MCSI): Not supported
                                                .... ...0 = Emergency services over non-3GPP access (EMCN3): Not supported
                                            LADN information
                                                Element ID: 0x79
                                                Length: 36
                                                LADN 1
                                                    Length: 6
                                                    DNN: cmnet
                                                    Length: 28
                                                    Partial tracking area list  1
                                                        .00. .... = Type of list: list of TACs belonging to one PLMN, with non-consecutive TAC values (0)
                                                        ...0 0111 = Number of elements: 8 elements (7)
                                                        Mobile Country Code (MCC): China (000)
                                                        Mobile Network Code (MNC): China Mobile (00)
                                                        TAC: 4386
                                                        TAC: 4388
                                                        TAC: 4387
                                                        TAC: 4384
                                                        TAC: 4385
                                                        TAC: 4381
                                                        TAC: 4382
                                                        TAC: 4383
                                            Service area list
                                            GPRS Timer 3 - T3512 value
                                                Element ID: 0x5e
                                                Length: 1
                                                GPRS Timer: 0 sec
                                                    011. .... = Unit: value is incremented in multiples of 2 seconds (3)
                                                    ...0 0000 = Timer value: 0
```

#### 2.7 InitialContextSetupResponse

```
NG Application Protocol
    NGAP-PDU: successfulOutcome (1)
        successfulOutcome
            procedureCode: id-InitialContextSetup (14)
            criticality: reject (0)
            value
                InitialContextSetupResponse
                    protocolIEs: 2 items
                        Item 0: id-AMF-UE-NGAP-ID
                            ProtocolIE-Field
                                id: id-AMF-UE-NGAP-ID (10)
                                criticality: ignore (1)
                                value
                                    AMF-UE-NGAP-ID: 9
                        Item 1: id-RAN-UE-NGAP-ID
                            ProtocolIE-Field
                                id: id-RAN-UE-NGAP-ID (85)
                                criticality: ignore (1)
                                value
                                    RAN-UE-NGAP-ID: 13
```

#### 2.8 UERadioAccessCapabilityInformation

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-UERadioCapabilityInfoIndication (44)
        criticality: ignore (1)
        value
            UERadioCapabilityInfoIndication
                protocolIEs: 3 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-UERadioCapability
                        ProtocolIE-Field
                            id: id-UERadioCapability (117)
                            criticality: ignore (1)
                            value
                                UERadioCapability: 040b5888168e1a0000007465a031e000380a03c1260c0000…
                                    UERadioAccessCapabilityInformation
                                        criticalExtensions: c1 (0)
                                            c1: ueRadioAccessCapabilityInformation (0)
                                                ueRadioAccessCapabilityInformation
                                                    ue-RadioAccessCapabilityInfo: 1102d1c34000000e8cb4063c000701407824c1800010f010…
                                                        UE-CapabilityRAT-ContainerList: 1 item
                                                            Item 0
                                                                UE-CapabilityRAT-Container
                                                                    rat-Type: nr (0)
                                                                    ue-CapabilityRAT-Container: e1a0000007465a031e000380a03c1260c000087808188068…
                                                                        UE-NR-Capability
                                                                            accessStratumRelease: rel15 (0)
                                                                            pdcp-Parameters
                                                                                supportedROHC-Profiles
                                                                                    .... ..0. profile0x0000: False
                                                                                    .... ...0 profile0x0001: False
                                                                                    0... .... profile0x0002: False
                                                                                    .0.. .... profile0x0003: False
                                                                                    ..0. .... profile0x0004: False
                                                                                    ...0 .... profile0x0006: False
                                                                                    .... 0... profile0x0101: False
                                                                                    .... .0.. profile0x0102: False
                                                                                    .... ..0. profile0x0103: False
                                                                                    .... ...0 profile0x0104: False
                                                                                maxNumberROHC-ContextSessions: cs2 (0)
                                                                            rlc-Parameters
                                                                                am-WithShortSN: supported (0)
                                                                                um-WithShortSN: supported (0)
                                                                                um-WithLongSN: supported (0)
                                                                            mac-Parameters
                                                                                mac-ParametersXDD-Diff
                                                                                    longDRX-Cycle: supported (0)
                                                                                    shortDRX-Cycle: supported (0)
                                                                            phy-Parameters
                                                                                phy-ParametersCommon
                                                                                    dynamicHARQ-ACK-Codebook: supported (0)
                                                                                    semiStaticHARQ-ACK-Codebook: supported (0)
                                                                                    ra-Type0-PUSCH: supported (0)
                                                                                    dynamicSwitchRA-Type0-1-PDSCH: supported (0)
                                                                                    dynamicSwitchRA-Type0-1-PUSCH: supported (0)
                                                                                    pdsch-MappingTypeA: supported (0)
                                                                                    rateMatchingResrcSetSemi-Static: supported (0)
                                                                                    rateMatchingResrcSetDynamic: supported (0)
                                                                                    bwp-SwitchingDelay: type1 (0)
                                                                                    maxNumberSearchSpaces: n10 (0)
                                                                                    rateMatchingCtrlResrcSetDynamic: supported (0)
                                                                                    maxLayersMIMO-Indication: supported (0)
                                                                                phy-ParametersFRX-Diff
                                                                                    twoFL-DMRS: c0 [bit length 2, 6 LSB pad bits, 11.. .... decimal value 3]
                                                                                    supportedDMRS-TypeDL: type1And2 (1)
                                                                                    supportedDMRS-TypeUL: type1And2 (1)
                                                                                    pucch-F2-WithFH: supported (0)
                                                                                    pucch-F3-WithFH: supported (0)
                                                                                    almostContiguousCP-OFDM-UL: supported (0)
                                                                                    mux-SR-HARQ-ACK-CSI-PUCCH-OncePerSlot
                                                                                        sameSymbol: supported (0)
                                                                                    oneFL-DMRS-TwoAdditionalDMRS-UL: supported (0)
                                                                                    twoFL-DMRS-TwoAdditionalDMRS-UL: supported (0)
                                                                                phy-ParametersFR1
                                                                                    pdsch-256QAM-FR1: supported (0)
                                                                                    pdsch-RE-MappingFR1-PerSymbol: n10 (0)
                                                                                    pdsch-RE-MappingFR1-PerSlot: n16 (0)
                                                                            rf-Parameters
                                                                                supportedBandListNR: 7 items
                                                                                    Item 0
                                                                                        BandNR
                                                                                            bandNR: 1
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-30kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-30kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                    Item 1
                                                                                        BandNR
                                                                                            bandNR: 3
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: f000 [bit length 10, 6 LSB pad bits, 1111 0000  00.. .... decimal value 960]
                                                                                                    scs-30kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: f000 [bit length 10, 6 LSB pad bits, 1111 0000  00.. .... decimal value 960]
                                                                                                    scs-30kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                    Item 2
                                                                                        BandNR
                                                                                            bandNR: 28
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-30kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-30kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                    Item 3
                                                                                        BandNR
                                                                                            bandNR: 41
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamReportTiming
                                                                                                    scs-30kHz: sym28 (3)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            ue-PowerClass: pc2 (1)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-30kHz: 13c0 [bit length 10, 6 LSB pad bits, 0001 0011  11.. .... decimal value 79]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-30kHz: 13c0 [bit length 10, 6 LSB pad bits, 0001 0011  11.. .... decimal value 79]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                    Item 4
                                                                                        BandNR
                                                                                            bandNR: 77
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamReportTiming
                                                                                                    scs-30kHz: sym28 (3)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            ue-PowerClass: pc2 (1)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-30kHz: 13c0 [bit length 10, 6 LSB pad bits, 0001 0011  11.. .... decimal value 79]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-30kHz: 13c0 [bit length 10, 6 LSB pad bits, 0001 0011  11.. .... decimal value 79]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                    Item 5
                                                                                        BandNR
                                                                                            bandNR: 78
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamReportTiming
                                                                                                    scs-30kHz: sym28 (3)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            ue-PowerClass: pc2 (1)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-30kHz: 13c0 [bit length 10, 6 LSB pad bits, 0001 0011  11.. .... decimal value 79]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-30kHz: 13c0 [bit length 10, 6 LSB pad bits, 0001 0011  11.. .... decimal value 79]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                    Item 6
                                                                                        BandNR
                                                                                            bandNR: 79
                                                                                            mimo-ParametersPerBand
                                                                                                tci-StatePDSCH
                                                                                                    maxNumberConfiguredTCIstatesPerCC: n16 (2)
                                                                                                    maxNumberActiveTCI-PerBWP: n1 (0)
                                                                                                pusch-TransCoherence: nonCoherent (0)
                                                                                                periodicBeamReport: supported (0)
                                                                                                aperiodicBeamReport: supported (0)
                                                                                                maxNumberNonGroupBeamReporting: n1 (0)
                                                                                                dummy5
                                                                                                    maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                    maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                    maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                    maxNumberSRS-Ports-PerResource: n1 (0)
                                                                                                beamReportTiming
                                                                                                    scs-30kHz: sym28 (3)
                                                                                                beamManagementSSB-CSI-RS
                                                                                                    maxNumberSSB-CSI-RS-ResourceOneTx: n8 (1)
                                                                                                    maxNumberCSI-RS-Resource: n0 (0)
                                                                                                    maxNumberCSI-RS-ResourceTwoTx: n0 (0)
                                                                                                    maxNumberAperiodicCSI-RS-Resource: n4 (2)
                                                                                                codebookParameters
                                                                                                    type1
                                                                                                        singlePanel
                                                                                                            supportedCSI-RS-ResourceList: 1 item
                                                                                                                Item 0
                                                                                                                    SupportedCSI-RS-Resource
                                                                                                                        maxNumberTxPortsPerResource: p16 (4)
                                                                                                                        maxNumberResourcesPerBand: 8
                                                                                                                        totalNumberTxPortsPerBand: 16
                                                                                                            modes: mode1andMode2 (1)
                                                                                                            maxNumberCSI-RS-PerResourceSet: 8
                                                                                                csi-RS-IM-ReceptionForFeedback
                                                                                                    maxConfigNumberNZP-CSI-RS-PerCC: 8
                                                                                                    maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC: 16
                                                                                                    maxConfigNumberCSI-IM-PerCC: n4 (2)
                                                                                                    maxNumberSimultaneousNZP-CSI-RS-PerCC: 4
                                                                                                    totalNumberPortsSimultaneousNZP-CSI-RS-PerCC: 16
                                                                                                csi-ReportFramework
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForCSI-Report: 1
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForCSI-Report: 0
                                                                                                    maxNumberPeriodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-PerBWP-ForBeamReport: 1
                                                                                                    maxNumberAperiodicCSI-triggeringStatePerCC: n15 (2)
                                                                                                    maxNumberSemiPersistentCSI-PerBWP-ForBeamReport: 0
                                                                                                    simultaneousCSI-ReportsPerCC: 2
                                                                                                csi-RS-ForTracking
                                                                                                    maxBurstLength: 2
                                                                                                    maxSimultaneousResourceSetsPerCC: 2
                                                                                                    maxConfiguredResourceSetsPerCC: 16
                                                                                                    maxConfiguredResourceSetsAllCC: 32
                                                                                            multipleTCI: supported (0)
                                                                                            bwp-SameNumerology: upto4 (1)
                                                                                            pusch-256QAM: supported (0)
                                                                                            ue-PowerClass: pc2 (1)
                                                                                            channelBWs-DL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                            channelBWs-UL-v1530: fr1 (0)
                                                                                                fr1
                                                                                                    scs-15kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                                    scs-60kHz: 0000 [bit length 10, 6 LSB pad bits, 0000 0000  00.. .... decimal value 0]
                                                                                supportedBandCombinationList: 1 item
                                                                                    Item 0
                                                                                        BandCombination
                                                                                            bandList: 1 item
                                                                                                Item 0
                                                                                                    BandParameters: nr (1)
                                                                                                        nr
                                                                                                            bandNR: 41
                                                                                                            ca-BandwidthClassDL-NR: a (0)
                                                                                                            ca-BandwidthClassUL-NR: a (0)
                                                                                            featureSetCombination: 0
                                                                                            powerClass-v1530: pc2 (0)
                                                                                appliedFreqBandListFilter: 1 item
                                                                                    Item 0
                                                                                        FreqBandInformation: bandInformationNR (1)
                                                                                            bandInformationNR
                                                                                                bandNR: 41
                                                                                supportedBandCombinationList-v1540: 1 item
                                                                                    Item 0
                                                                                        BandCombination-v1540
                                                                                            bandList-v1540: 1 item
                                                                                                Item 0
                                                                                                    BandParameters-v1540
                                                                                                        srs-TxSwitch
                                                                                                            supportedSRS-TxPortSwitch: t2r4 (2)
                                                                            measAndMobParameters
                                                                                measAndMobParametersCommon
                                                                                    ssb-RLM: supported (0)
                                                                                    eventB-MeasAndReport: supported (0)
                                                                                    handoverFDD-TDD: supported (0)
                                                                                    eutra-CGI-Reporting: supported (0)
                                                                                    nr-CGI-Reporting: supported (0)
                                                                                    periodicEUTRA-MeasAndReport: supported (0)
                                                                                measAndMobParametersXDD-Diff
                                                                                    intraAndInterF-MeasAndReport: supported (0)
                                                                                    eventA-MeasAndReport: supported (0)
                                                                                    handoverInterF: supported (0)
                                                                                    handoverLTE-EPC: supported (0)
                                                                                measAndMobParametersFRX-Diff
                                                                                    ss-SINR-Meas: supported (0)
                                                                                    handoverInterF: supported (0)
                                                                                    handoverLTE-EPC: supported (0)
                                                                            featureSets
                                                                                featureSetsDownlink: 1 item
                                                                                    Item 0
                                                                                        FeatureSetDownlink
                                                                                            featureSetListPerDownlinkCC: 1 item
                                                                                                Item 0
                                                                                                    FeatureSetDownlinkPerCC-Id: 1
                                                                                featureSetsDownlinkPerCC: 1 item
                                                                                    Item 0
                                                                                        FeatureSetDownlinkPerCC
                                                                                            supportedSubcarrierSpacingDL: kHz30 (1)
                                                                                            supportedBandwidthDL: fr1 (0)
                                                                                                fr1: mhz100 (10)
                                                                                            channelBW-90mhz: supported (0)
                                                                                            maxNumberMIMO-LayersPDSCH: fourLayers (1)
                                                                                            supportedModulationOrderDL: qam256 (5)
                                                                                featureSetsUplink: 1 item
                                                                                    Item 0
                                                                                        FeatureSetUplink
                                                                                            featureSetListPerUplinkCC: 1 item
                                                                                                Item 0
                                                                                                    FeatureSetUplinkPerCC-Id: 1
                                                                                            supportedSRS-Resources
                                                                                                maxNumberAperiodicSRS-PerBWP: n16 (4)
                                                                                                maxNumberAperiodicSRS-PerBWP-PerSlot: 6
                                                                                                maxNumberPeriodicSRS-PerBWP: n16 (4)
                                                                                                maxNumberPeriodicSRS-PerBWP-PerSlot: 6
                                                                                                maxNumberSemiPersistentSRS-PerBWP: n16 (4)
                                                                                                maxNumberSemiPersistentSRS-PerBWP-PerSlot: 6
                                                                                                maxNumberSRS-Ports-PerResource: n2 (1)
                                                                                featureSetsUplinkPerCC: 1 item
                                                                                    Item 0
                                                                                        FeatureSetUplinkPerCC
                                                                                            supportedSubcarrierSpacingUL: kHz30 (1)
                                                                                            supportedBandwidthUL: fr1 (0)
                                                                                                fr1: mhz100 (10)
                                                                                            channelBW-90mhz: supported (0)
                                                                                            mimo-CB-PUSCH
                                                                                                maxNumberMIMO-LayersCB-PUSCH: twoLayers (1)
                                                                                                maxNumberSRS-ResourcePerSet: 1
                                                                                            supportedModulationOrderUL: qam256 (5)
                                                                                featureSetsDownlink-v1540: 1 item
                                                                                    Item 0
                                                                                        FeatureSetDownlink-v1540
                                                                                            oneFL-DMRS-TwoAdditionalDMRS-DL: supported (0)
                                                                                            twoFL-DMRS-TwoAdditionalDMRS-DL: supported (0)
                                                                                            oneFL-DMRS-ThreeAdditionalDMRS-DL: supported (0)
                                                                            featureSetCombinations: 1 item
                                                                                Item 0
                                                                                    FeatureSetCombination: 1 item
                                                                                        Item 0
                                                                                            FeatureSetsPerBand: 1 item
                                                                                                Item 0
                                                                                                    FeatureSet: nr (1)
                                                                                                        nr
                                                                                                            downlinkSetNR: 1
                                                                                                            uplinkSetNR: 1
                                                                            nonCriticalExtension
                                                                                interRAT-Parameters
                                                                                    eutra
                                                                                        supportedBandListEUTRA: 21 items
                                                                                            Item 0
                                                                                                FreqBandIndicatorEUTRA: 1
                                                                                            Item 1
                                                                                                FreqBandIndicatorEUTRA: 2
                                                                                            Item 2
                                                                                                FreqBandIndicatorEUTRA: 3
                                                                                            Item 3
                                                                                                FreqBandIndicatorEUTRA: 4
                                                                                            Item 4
                                                                                                FreqBandIndicatorEUTRA: 5
                                                                                            Item 5
                                                                                                FreqBandIndicatorEUTRA: 6
                                                                                            Item 6
                                                                                                FreqBandIndicatorEUTRA: 7
                                                                                            Item 7
                                                                                                FreqBandIndicatorEUTRA: 8
                                                                                            Item 8
                                                                                                FreqBandIndicatorEUTRA: 9
                                                                                            Item 9
                                                                                                FreqBandIndicatorEUTRA: 12
                                                                                            Item 10
                                                                                                FreqBandIndicatorEUTRA: 17
                                                                                            Item 11
                                                                                                FreqBandIndicatorEUTRA: 18
                                                                                            Item 12
                                                                                                FreqBandIndicatorEUTRA: 19
                                                                                            Item 13
                                                                                                FreqBandIndicatorEUTRA: 20
                                                                                            Item 14
                                                                                                FreqBandIndicatorEUTRA: 26
                                                                                            Item 15
                                                                                                FreqBandIndicatorEUTRA: 28
                                                                                            Item 16
                                                                                                FreqBandIndicatorEUTRA: 34
                                                                                            Item 17
                                                                                                FreqBandIndicatorEUTRA: 38
                                                                                            Item 18
                                                                                                FreqBandIndicatorEUTRA: 39
                                                                                            Item 19
                                                                                                FreqBandIndicatorEUTRA: 40
                                                                                            Item 20
                                                                                                FreqBandIndicatorEUTRA: 41
                                                                                        eutra-ParametersCommon
                                                                                            mfbi-EUTRA: supported (0)
                                                                                            rs-SINR-MeasEUTRA: supported (0)
                                                                                        eutra-ParametersXDD-Diff
                                                                                            rsrqMeasWidebandEUTRA: supported (0)
                                                                                inactiveState: supported (0)
```

```
NGAP-PDU: successfulOutcome (1)
    successfulOutcome
        procedureCode: id-InitialContextSetup (14)
        criticality: reject (0)
        value
            InitialContextSetupResponse
                protocolIEs: 2 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: ignore (1)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: ignore (1)
                            value
                                RAN-UE-NGAP-ID: 4194571
```

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-UplinkNASTransport (46)
        criticality: ignore (1)
        value
            UplinkNASTransport
                protocolIEs: 4 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: reject (0)
                            value
                                NAS-PDU: 7e026e3a64f8017e0043
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Security protected NAS 5GS message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0010 = Security header type: Integrity protected and ciphered (2)
                                            Message authentication code: 0x6e3a64f8
                                            Sequence number: 1
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: Registration complete (0x43)
                    Item 3: id-UserLocationInformation
                        ProtocolIE-Field
                            id: id-UserLocationInformation (121)
                            criticality: ignore (1)
                            value
                                UserLocationInformation: userLocationInformationNR (1)
                                    userLocationInformationNR
                                        nR-CGI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            nRCellIdentity: 0x00044880f0
                                        tAI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            tAC: 4388 (0x001124)
```

#### 2.9 PDU session establishment request

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-UplinkNASTransport (46)
        criticality: ignore (1)
        value
            UplinkNASTransport
                protocolIEs: 4 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-NAS-PDU
                        ProtocolIE-Field
                            id: id-NAS-PDU (38)
                            criticality: reject (0)
                            value
                                NAS-PDU: 7e02dbf0810f027e006701001e2e050fc1ffff93a17b0013…
                                    Non-Access-Stratum 5GS (NAS)PDU
                                        Security protected NAS 5GS message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0010 = Security header type: Integrity protected and ciphered (2)
                                            Message authentication code: 0xdbf0810f
                                            Sequence number: 2
                                        Plain NAS 5GS Message
                                            Extended protocol discriminator: 5G mobility management messages (126)
                                            0000 .... = Spare Half Octet: 0
                                            .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                            Message type: UL NAS transport (0x67)
                                            0000 .... = Spare Half Octet: 0
                                            Payload container type
                                                .... 0001 = Payload container type: N1 SM information (1)
                                            Payload container
                                                Length: 30
                                                Plain NAS 5GS Message
                                                    Extended protocol discriminator: 5G session management messages (46)
                                                    PDU session identity: PDU session identity value 5 (5)
                                                    Procedure transaction identity: 15
                                                    Message type: PDU session establishment request (0xc1)
                                                    Integrity protection maximum data rate
                                                        Integrity protection maximum data rate for uplink: Full data rate (255)
                                                        Integrity protection maximum data rate for downlink: Full data rate (255)
                                                    PDU session type
                                                        1001 .... = Element ID: 0x9-
                                                        .... 0011 = PDU session type: Ipv4v6 (3)
                                                    SSC mode
                                                        1010 .... = Element ID: 0xa-
                                                        .... 0001 = SSC mode: SSC mode 1 (1)
                                                    Extended protocol configuration options
                                                        Element ID: 0x7b
                                                        Length: 19
                                                        [Link direction: MS to network (0)]
                                                        1... .... = Extension: True
                                                        .... .000 = Configuration Protocol: PPP for use with IP PDP type or IP PDN type (0)
                                                        Protocol or Container ID: IP address allocation via NAS signalling (0x000a)
                                                            Length: 0x00 (0)
                                                        Protocol or Container ID: IM CN Subsystem Signaling Flag (0x0002)
                                                            Length: 0x00 (0)
                                                        Protocol or Container ID: P-CSCF IPv6 Address Request (0x0001)
                                                            Length: 0x00 (0)
                                                        Protocol or Container ID: P-CSCF IPv4 Address Request (0x000c)
                                                            Length: 0x00 (0)
                                                        Protocol or Container ID: DNS Server IPv6 Address Request (0x0003)
                                                            Length: 0x00 (0)
                                                        Protocol or Container ID: DNS Server IPv4 Address Request (0x000d)
                                                            Length: 0x00 (0)
                                            PDU session identity 2 - PDU session ID
                                                Element ID: 0x12
                                                PDU session identity: PDU session identity value 5 (5)
                                            Request type
                                                1000 .... = Element ID: 0x8-
                                                .... 0001 = Request type: Initial request (1)
                                            DNN
                                                Element ID: 0x25
                                                Length: 4
                                                DNN: ims
                    Item 3: id-UserLocationInformation
                        ProtocolIE-Field
                            id: id-UserLocationInformation (121)
                            criticality: ignore (1)
                            value
                                UserLocationInformation: userLocationInformationNR (1)
                                    userLocationInformationNR
                                        nR-CGI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            nRCellIdentity: 0x00044880f0
                                        tAI
                                            pLMNIdentity: 64f000
                                                Mobile Country Code (MCC): China (000)
                                                Mobile Network Code (MNC): China Mobile (00)
                                            tAC: 4388 (0x001124)
```

#### 2.10 PDUSessionResourceSetupRequest PDU session establishment accept

```
NGAP-PDU: initiatingMessage (0)
    initiatingMessage
        procedureCode: id-PDUSessionResourceSetup (29)
        criticality: reject (0)
        value
            PDUSessionResourceSetupRequest
                protocolIEs: 4 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: reject (0)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: reject (0)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-PDUSessionResourceSetupListSUReq
                        ProtocolIE-Field
                            id: id-PDUSessionResourceSetupListSUReq (74)
                            criticality: reject (0)
                            value
                                PDUSessionResourceSetupListSUReq: 1 item
                                    Item 0
                                        PDUSessionResourceSetupItemSUReq
                                            pDUSessionID: 5
                                            pDUSessionNAS-PDU: 7e02663fcf8d027e00680100742e050fc211000901000631…
                                                Non-Access-Stratum 5GS (NAS)PDU
                                                    Security protected NAS 5GS message
                                                        Extended protocol discriminator: 5G mobility management messages (126)
                                                        0000 .... = Spare Half Octet: 0
                                                        .... 0010 = Security header type: Integrity protected and ciphered (2)
                                                        Message authentication code: 0x663fcf8d
                                                        Sequence number: 2
                                                    Plain NAS 5GS Message
                                                        Extended protocol discriminator: 5G mobility management messages (126)
                                                        0000 .... = Spare Half Octet: 0
                                                        .... 0000 = Security header type: Plain NAS message, not security protected (0)
                                                        Message type: DL NAS transport (0x68)
                                                        0000 .... = Spare Half Octet: 0
                                                        Payload container type
                                                            .... 0001 = Payload container type: N1 SM information (1)
                                                        Payload container
                                                            Length: 116
                                                            Plain NAS 5GS Message
                                                                Extended protocol discriminator: 5G session management messages (46)
                                                                PDU session identity: PDU session identity value 5 (5)
                                                                Procedure transaction identity: 15
                                                                Message type: PDU session establishment accept (0xc2)
                                                                0001 .... = Selected SSC mode: SSC mode 1 (1)
                                                                PDU session type - Selected PDU session type
                                                                    .... 0001 = PDU session type: IPv4 (1)
                                                                QoS rules - Authorized QoS rules
                                                                    Length: 9
                                                                    QoS rule 1
                                                                        QoS rule identifier: 1
                                                                        Length: 6
                                                                        001. .... = Rule operation code: Create new QoS rule (1)
                                                                        ...1 .... = DQR: The QoS rule is the default QoS rule
                                                                        .... 0001 = Number of packet filters: 1
                                                                        Packet filter 1
                                                                            ..11 .... = Packet filter direction: Bidirectional (3)
                                                                            .... 0000 = Packet filter identifier: 0
                                                                            Length: 1
                                                                            Packet filter component 1
                                                                                Packet filter component type: Match-all type (1)
                                                                        QoS rule precedence: 254
                                                                        0... .... = Spare: 0
                                                                        .0.. .... = Spare: 0
                                                                        ..00 0001 = Qos flow identifier: 1
                                                                Session-AMBR
                                                                    Length: 6
                                                                    Unit for Session-AMBR for downlink: value is incremented in multiples of 1 Mbps (6)
                                                                    Session-AMBR for downlink: 2001 Mbps (2001)
                                                                    Unit for Session-AMBR for uplink: value is incremented in multiples of 1 Mbps (6)
                                                                    Session-AMBR for uplink: 2000 Mbps (2000)
                                                                PDU address
                                                                    Element ID: 0x29
                                                                    Length: 5
                                                                    .... 0001 = PDU session type: IPv4 (1)
                                                                    PDU address information: 222.222.1.231
                                                                S-NSSAI
                                                                    Element ID: 0x22
                                                                    Length: 4
                                                                    Slice/service type (SST): 1
                                                                    Slice differentiator (SD): 1
                                                                Mapped EPS bearer contexts
                                                                    Element ID: 0x75
                                                                    Length: 27
                                                                    Mapped EPS bearer context 1
                                                                        0101 .... = EPS bearer identity: 5
                                                                        Length: 24
                                                                        01.. .... = Operation code: Create new EPS bearer (1)
                                                                        ..0. .... = Spare: 0
                                                                        ...1 .... = E bit: parameters list is included (1)
                                                                        .... 0010 = Number of EPS parameters: 2
                                                                        EPS parameter 1 - Mapped EPS QoS parameters
                                                                        EPS parameter 2 - APN-AMBR
                                                                QoS flow descriptions - Authorized
                                                                Extended protocol configuration options
                                                                    Element ID: 0x7b
                                                                    Length: 27
                                                                    [Link direction: Network to MS (1)]
                                                                    1... .... = Extension: True
                                                                    .... .000 = Configuration Protocol: PPP for use with IP PDP type or IP PDN type (0)
                                                                    Protocol or Container ID: P-CSCF IPv6 Address (0x0001)
                                                                        Length: 0x10 (16)
                                                                        IPv6: ::
                                                                    Protocol or Container ID: P-CSCF IPv4 Address (0x000c)
                                                                        Length: 0x04 (4)
                                                                        IPv4: 16.16.16.220
                                                                DNN
                                                                    Element ID: 0x25
                                                                    Length: 6
                                                                    DNN: cmnet
                                                        PDU session identity 2 - PDU session ID
                                                            Element ID: 0x12
                                                            PDU session identity: PDU session identity value 5 (5)
                                            s-NSSAI
                                                sST: 01
                                                sD: 000001
                                            pDUSessionResourceSetupRequestTransfer: 0000050082000a0c7744d6403077359400008b000a01f010…
                                                PDUSessionResourceSetupRequestTransfer
                                                    protocolIEs: 5 items
                                                        Item 0: id-PDUSessionAggregateMaximumBitRate
                                                            ProtocolIE-Field
                                                                id: id-PDUSessionAggregateMaximumBitRate (130)
                                                                criticality: reject (0)
                                                                value
                                                                    PDUSessionAggregateMaximumBitRate
                                                                        pDUSessionAggregateMaximumBitRateDL: 2001000000bits/s
                                                                        pDUSessionAggregateMaximumBitRateUL: 2000000000bits/s
                                                        Item 1: id-UL-NGU-UP-TNLInformation
                                                            ProtocolIE-Field
                                                                id: id-UL-NGU-UP-TNLInformation (139)
                                                                criticality: reject (0)
                                                                value
                                                                    UPTransportLayerInformation: gTPTunnel (0)
                                                                        gTPTunnel
                                                                            transportLayerAddress: 10100d71 [bit length 32, 0001 0000  0001 0000  0000 1101  0111 0001 decimal value 269487473]
                                                                                TransportLayerAddress (IPv4): 16.16.13.113
                                                                            gTP-TEID: 00c00178
                                                        Item 2: id-PDUSessionType
                                                            ProtocolIE-Field
                                                                id: id-PDUSessionType (134)
                                                                criticality: reject (0)
                                                                value
                                                                    PDUSessionType: ipv4 (0)
                                                        Item 3: id-SecurityIndication
                                                            ProtocolIE-Field
                                                                id: id-SecurityIndication (138)
                                                                criticality: reject (0)
                                                                value
                                                                    SecurityIndication
                                                                        integrityProtectionIndication: required (0)
                                                                        confidentialityProtectionIndication: required (0)
                                                                        maximumIntegrityProtectedDataRate-UL: maximum-UE-rate (1)
                                                        Item 4: id-QosFlowSetupRequestList
                                                            ProtocolIE-Field
                                                                id: id-QosFlowSetupRequestList (136)
                                                                criticality: reject (0)
                                                                value
                                                                    QosFlowSetupRequestList: 1 item
                                                                        Item 0
                                                                            QosFlowSetupRequestItem
                                                                                qosFlowIdentifier: 1
                                                                                qosFlowLevelQosParameters
                                                                                    qosCharacteristics: nonDynamic5QI (0)
                                                                                        nonDynamic5QI
                                                                                            fiveQI: 9
                                                                                    allocationAndRetentionPriority
                                                                                        priorityLevelARP: 10
                                                                                        pre-emptionCapability: may-trigger-pre-emption (1)
                                                                                        pre-emptionVulnerability: not-pre-emptable (0)
                                                                                e-RAB-ID: 5
                    Item 3: id-UEAggregateMaximumBitRate
                        ProtocolIE-Field
                            id: id-UEAggregateMaximumBitRate (110)
                            criticality: ignore (1)
                            value
                                UEAggregateMaximumBitRate
                                    uEAggregateMaximumBitRateDL: 256bits/s
                                    uEAggregateMaximumBitRateUL: 1024bits/s
```

#### 2.11 PDUSessionResourceSetupResponse

```
NGAP-PDU: successfulOutcome (1)
    successfulOutcome
        procedureCode: id-PDUSessionResourceSetup (29)
        criticality: reject (0)
        value
            PDUSessionResourceSetupResponse
                protocolIEs: 3 items
                    Item 0: id-AMF-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-AMF-UE-NGAP-ID (10)
                            criticality: ignore (1)
                            value
                                AMF-UE-NGAP-ID: 2155872278
                    Item 1: id-RAN-UE-NGAP-ID
                        ProtocolIE-Field
                            id: id-RAN-UE-NGAP-ID (85)
                            criticality: ignore (1)
                            value
                                RAN-UE-NGAP-ID: 4194571
                    Item 2: id-PDUSessionResourceSetupListSURes
                        ProtocolIE-Field
                            id: id-PDUSessionResourceSetupListSURes (75)
                            criticality: ignore (1)
                            value
                                PDUSessionResourceSetupListSURes: 1 item
                                    Item 0
                                        PDUSessionResourceSetupItemSURes
                                            pDUSessionID: 5
                                            pDUSessionResourceSetupResponseTransfer: 0003e00a0a0ac8800c01240001
                                                PDUSessionResourceSetupResponseTransfer
                                                    dLQosFlowPerTNLInformation
                                                        uPTransportLayerInformation: gTPTunnel (0)
                                                            gTPTunnel
                                                                transportLayerAddress: 0a0a0ac8 [bit length 32, 0000 1010  0000 1010  0000 1010  1100 1000 decimal value 168430280]
                                                                    TransportLayerAddress (IPv4): 10.10.10.200
                                                                gTP-TEID: 800c0124
                                                        associatedQosFlowList: 1 item
                                                            Item 0
                                                                AssociatedQosFlowItem
                                                                    qosFlowIdentifier: 1
```
