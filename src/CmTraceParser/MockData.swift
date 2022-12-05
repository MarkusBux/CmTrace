//
//  MockData.swift
//  CmTraceParser
//
//  Created by Markus Bux on 01.12.22.
//

import Foundation
public class MockData {
    public static let Data1:String = """
<![LOG[Successfully]LOG]!><time="13:59:35.6721099" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="153" file="">
<![LOG[Successfully subscribed listener to registry key.]LOG]!><time="13:59:35.6721099" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="153" file="">
<![LOG[Waiting for CommonWorker to be ready...]LOG]!><time="13:59:35.6721099" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="153" file="">
<![LOG[GenericWorkerConfig initializing...]LOG]!><time="13:59:35.6721099" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="153" file="">
<![LOG[Starting worker GenericDownloadWorker_ANY...]LOG]!><time="13:59:35.6771034" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="137" file="">
<![LOG[[GenericDownloadWorker_ANY] Worker is "run-once" and no timers will be created.]LOG]!><time="13:59:35.6771034" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="137" file="">
<![LOG[Worker GenericDownloadWorker_ANY was triggered by timer.]LOG]!><time="13:59:35.6771034" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="137" file="">
<![LOG[Triggered GenericDownloadWorker_ANY::ExecuteAsync()]LOG]!><time="13:59:35.6771034" date="11-29-2022" component="SMS_SERVICE_CONNECTOR_GenericDownloadWorker" context="" type="1" thread="137" file="">
"""
    
    public static let Data2:String = """
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>set quoted_identifier on;set ansi_warnings on;set ansi_padding on;set ansi_nulls on;set concat_null_yields_null on;set arithabort on;set numeric_roundabort off;set DATEFORMAT mdy;  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>set quoted_identifier on;set ansi_warnings on;set ansi_padding on;set ansi_nulls on;set concat_null_yields_null on;set arithabort on;set numeric_roundabort off;set DATEFORMAT mdy;  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>select Name,LEFT(Value1, 16383),LEFT(Value2, 16383),Value3,ISNULL(DATALENGTH(Value1),0),ISNULL(DATALENGTH(Value2),0) from vSMS_SC_Component_Properties where ID = 72057594037927959  order by Name~  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
SQL>>>select PropertyListID,Name, ISNULL(Value, case when ValueIndex is null then NULL else N'' end) as Value  from vSMS_SC_Component_PropertyLists where ID = 72057594037927959  order by Name,ValueIndex~  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
Waiting for changes for 5 minutes  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
Wait timed out after 5 minutes while waiting for at least one trigger event.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:28.181-60><thread=4844 (0x12EC)>
PF: ***** Evaluation cycle starts *****  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.184-60><thread=4844 (0x12EC)>
PF: Triggered by WAIT_TIMEOUT  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.184-60><thread=4844 (0x12EC)>
PF: Incremental cycle triggered  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.184-60><thread=4844 (0x12EC)>
SQL>>>set quoted_identifier on;set ansi_warnings on;set ansi_padding on;set ansi_nulls on;set concat_null_yields_null on;set arithabort on;set numeric_roundabort off;set DATEFORMAT mdy;  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.194-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.194-60><thread=4844 (0x12EC)>
PF: Processing of file extensions starts  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:34.194-60><thread=4844 (0x12EC)>
"""
    
    public static let Data3:String = """
<![LOG[]LOG]!><time="00:00:13.4128412" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="12" file="">
<![LOG[IOCompletionCallback
System.ComponentModel.Win32Exception (0x80004005): The specified network name is no longer available]LOG]!><time="00:00:57.6942890" date="11-30-2022" component="Microsoft.Owin.Host.HttpListener.OwinHttpListener" context="" type="3" thread="14" file="">
<![LOG[Processing incoming request for resource [https://l1cm01.lab1.local/AdminService/v1.0/], method: [GET], User - [NT AUTHORITY\\SYSTEM]]LOG]!><time="00:08:51.8419434" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="14" file="">
<![LOG[IOCompletionCallback
System.ComponentModel.Win32Exception (0x80004005):
The specified network name is no longer available]LOG]!><time="00:10:53.1991144" date="11-30-2022" component="Microsoft.Owin.Host.HttpListener.OwinHttpListener" context="" type="3" thread="14" file=""><![LOG[Processing
incoming request for resource [https://l1cm01.lab1.local/AdminService/v1.0/], method: [GET], User - [NT AUTHORITY\\SYSTEM]]LOG]!><time="00:18:51.8559877" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="20" file="">
<![LOG[Header: [Authorization]=[**************]]LOG]!><time="00:18:51.8559877" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="20" file="">
"""
    
    public static let Data4:String = """
This is some dummy test]LOG]!><time="00:00:13.4128412" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="12" file="">
<![LOG[IOCompletionCallback
System.ComponentModel.Win32Exception (0x80004005): The specified network name is no longer available]LOG]!><time="00:00:57.6942890" date="11-30-2022" component="Microsoft.Owin.Host.HttpListener.OwinHttpListener" context="" type="3" thread="14" file="">
<![LOG[Processing incoming request for resource [https://l1cm01.lab1.local/AdminService/v1.0/], method: [GET], User - [NT AUTHORITY\\SYSTEM]]LOG]!><time="00:08:51.8419434" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="14" file="">
<![LOG[IOCompletionCallback
System.ComponentModel.Win32Exception (0x80004005):
The specified network name is no longer available]LOG]!><time="00:10:53.1991144" date="11-30-2022" component="Microsoft.Owin.Host.HttpListener.OwinHttpListener" context="" type="3" thread="14" file=""><![LOG[Processing
incoming request for resource [https://l1cm01.lab1.local/AdminService/v1.0/], method: [GET], User - [NT AUTHORITY\\SYSTEM]]LOG]!><time="00:18:51.8559877" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="20" file="">
<![LOG[Header: [Authorization]=[**************]
"""
    
    public static let Data5:String = """
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>set quoted_identifier on;set ansi_warnings on;set ansi_padding on;set ansi_nulls on;set concat_null_yields_null on;set arithabort on;set numeric_roundabort off;set DATEFORMAT mdy;  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>set quoted_identifier on;set ansi_warnings on;set ansi_padding on;set ansi_nulls on;set concat_null_yields_null on;set arithabort on;set numeric_roundabort off;set DATEFORMAT mdy;  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.174-60><thread=4844 (0x12EC)>
SQL>>>select Name,LEFT(Value1, 16383),LEFT(Value2, 16383),Value3,ISNULL(DATALENGTH(Value1),0),ISNULL(DATALENGTH(Value2),0) from vSMS_SC_Component_Properties where ID = 72057594037927959  order by Name~  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
SQL>>>select PropertyListID,Name, ISNULL(Value, case when ValueIndex is null then NULL else N'' end) as Value  from vSMS_SC_Component_PropertyLists where ID = 72057594037927959  order by Name,ValueIndex~  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
Waiting for changes for 5 minutes  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:03:34.179-60><thread=4844 (0x12EC)>
Wait timed out after 5 minutes while waiting for at least one trigger event.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:28.181-60><thread=4844 (0x12EC)>
PF: ***** Evaluation cycle starts *****  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.184-60><thread=4844 (0x12EC)>
PF: Triggered by WAIT_TIMEOUT  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.184-60><thread=4844 (0x12EC)>
PF: Incremental cycle triggered  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.184-60><thread=4844 (0x12EC)>
SQL>>>set quoted_identifier on;set ansi_warnings on;set ansi_padding on;set ansi_nulls on;set concat_null_yields_null on;set arithabort on;set numeric_roundabort off;set DATEFORMAT mdy;  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.194-60><thread=4844 (0x12EC)>
SQL>>>>> Done.  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:33.194-60><thread=4844 (0x12EC)>
PF: Processing of file extensions starts  $$<SMS_COLLECTION_EVALUATOR><11-30-2022 01:08:34.194-60><thread=4844 (0x12EC)>
"""
    
    public static let Data6:String = """
This is some dummy test]LOG]!><time="00:00:13.4128412" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="12" file="">
<![LOG[IOCompletionCallback
System.ComponentModel.Win32Exception (0x80004005): The specified network name is no longer available]LOG]!><time="00:00:57.6942890" date="11-30-2022" component="Microsoft.Owin.Host.HttpListener.OwinHttpListener" context="" type="3" thread="14" file="">
<![LOG[Processing incoming request for resource [https://l1cm01.lab1.local/AdminService/v1.0/], method: [GET], User - [NT AUTHORITY\\SYSTEM]]LOG]!><time="00:08:51.8419434" date="11-30-2022" component="Microsoft.ConfigurationManager.AdminService" context="" type="1" thread="14" file="">
<![LOG[IOCompletionCallback
System.ComponentModel.Win32Exception (0x80004005):
The specified network name is no longer available]LOG]!><time="00:10:53.1991144" date="11-30-2022" component="Microsoft.Owin.Host.HttpListener.OwinHttpListener" context="" type="3" thread="14" file=""><![LOG[Processing
incoming request for resource [https://l1cm01.lab1.local/AdminService/v1.0/], method: [GET], User - [NT AUTHORITY\\SYSTEM]]LOG]!><time="00:18:51.8559877" date="11-30-2022"
"""
}
