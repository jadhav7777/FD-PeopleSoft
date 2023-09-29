-- ************************************************************  
--                                                               
--                                                               
-- This software and related documentation are provided under a  
-- license agreement containing restrictions on use and          
-- disclosure and are protected by intellectual property         
-- laws. Except as expressly permitted in your license agreement 
-- or allowed by law, you may not use, copy, reproduce,          
-- translate, broadcast, modify, license, transmit, distribute,  
-- exhibit, perform, publish or display any part, in any form or 
-- by any means. Reverse engineering, disassembly, or            
-- decompilation of this software, unless required by law for    
-- interoperability, is prohibited.                              
-- The information contained herein is subject to change without 
-- notice and is not warranted to be error-free. If you find any 
-- errors, please report them to us in writing.                  
--                                                               
-- Copyright (C) 1988, 2014, Oracle and/or its affiliates.       
-- All Rights Reserved.                                          
-- ************************************************************  
--Start Queues

update PSQUEUEDEFN set QUEUESTATUS = 1 where QUEUENAME in (select CHNLNAME from PSMSGDEFN
where MSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)
)

--Start Operations
update PSOPRVERDFN set ACTIVE_FLAG = 'A' where IB_OPERATIONNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)

--Start Handlers
update PSOPRHDLR set ACTIVE_FLAG = 'A' where IB_OPERATIONNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)

--Start Routings
UPDATE PSIBRTNGDEFN SET EFF_STATUS = 'A' where IB_OPERATIONNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)
AND SENDERNODENAME in ('PSFT_HR','PSFT_EP') and RECEIVERNODENAME in ('PSFT_HR','PSFT_EP')
AND PSIBRTNGDEFN.EFFDT = (SELECT MAX(A.EFFDT) FROM PSIBRTNGDEFN A WHERE A.ROUTINGDEFNNAME = PSIBRTNGDEFN.ROUTINGDEFNNAME AND A.EFFDT <=getdate())

--Stop  Routings in any other direction
UPDATE PSIBRTNGDEFN SET EFF_STATUS = 'I' where IB_OPERATIONNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)
AND SENDERNODENAME not in ('PSFT_HR','PSFT_EP') or RECEIVERNODENAME not in ('PSFT_HR','PSFT_EP')
AND PSIBRTNGDEFN.EFFDT = (SELECT MAX(A.EFFDT) FROM PSIBRTNGDEFN A WHERE A.ROUTINGDEFNNAME = PSIBRTNGDEFN.ROUTINGDEFNNAME AND A.EFFDT <=getdate())


-- Service Operation Security




-- Activate or create rules for FULLSYNCS
update PS_EO_MSGPUBDEFN 
        set EFF_STATUS = 'A', 
        CREATE_HDR_FLG = 'Y', 
        CREATE_TRL_FLG = 'Y',
        PUBLISH_LANG_FLG = 'N',
        PUBLISH_BASE_LANG = 'Y'
where PUBLISH_TYPE = 'F'
and MSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60);

insert into PS_EO_MSGPUBDEFN 
(MSGNAME
,PUBLISH_RULE_ID
,DESCR
,EFF_STATUS
,CREATE_HDR_FLG
,CREATE_TRL_FLG
,CHUNK_RULE_ID
,RECNAME_CHUNK
,PUBLISH_BASE_LANG
,CREATE_FILE_FLG
,CREATE_DELAY_FLG
,PUBLISH_TYPE
,PUBLISH_LANG_FLG)
SELECT distinct
 RQSTMSGNAME
,RQSTMSGNAME
,RQSTMSGNAME
,'A' 
,'Y'
,'Y'
,' '
,' '
,'Y'
,'N'
,'N'
,'F'
,'N'
from PSNODETRX B
where (MSGNODENAME = 'PSFT_HR' )
and EFF_STATUS = 'A'
and RQSTMSGNAME like '%FULLSYNC%'
and RQSTMSGNAME not in (select MSGNAME 
                        from PS_EO_MSGPUBDEFN
                        where PUBLISH_TYPE = 'F')
and RQSTMSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)
and not exists (select 'x' from PS_EO_MSGPUBDEFN X where X.MSGNAME = B.RQSTMSGNAME );

