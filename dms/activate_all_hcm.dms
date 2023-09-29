-- **************************************************************
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
-- **************************************************************
-- Rename PSFT_EP to the name of the fin node

-- 60 = Messages
-- 61 = Channels


-- Activate Transactions

update PSNODETRX SET EFF_STATUS = 'A'
where RQSTMSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60)
and MSGNODENAME in ('PSFT_EP');

update PSNODETRX SET EFF_STATUS = 'A' where RQSTMSGNAME = 'PERSON_BASIC_SYNC' and RQSTMSGVER = 'INTERNAL' AND MSGNODENAME = 'PSFT_EP';

-- Activate Messages

update PSMSGDEFN set MSGSTATUS = 1 
where MSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60);

-- Activate Subscription PPLCODE

update PSSUBDEFN 
        set SUBSTATUS = 1 
where MSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60);

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
from PSNODETRX 
where (MSGNODENAME = 'PSFT_EP' )
and EFF_STATUS = 'A'
and RQSTMSGNAME like '%FULLSYNC%'
and RQSTMSGNAME not in (select MSGNAME 
                        from PS_EO_MSGPUBDEFN
                        where PUBLISH_TYPE = 'F')
and RQSTMSGNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=60);


-- Start Channels
update PSCHNLDEFN set CHNLSTATUS = 1 where 
CHNLNAME in (select OBJECTVALUE1 from PSPROJECTITEM where PROJECTNAME ='FO_MESSAGES' and OBJECTID1=61);


-- Activate Relationships
update PSRELATIONTRX
set EFF_STATUS = 'A'
, SRCNODE = 'PSFT_EP'
, TGTNODE = 'PSFT_EP'
where RELATIONSHIPID in ('PDATA_SYNC_V1', 'COMPETENCY_SYNC','ACCOMP_SYNC', 'WORKFORCE_SYNC_V1');


