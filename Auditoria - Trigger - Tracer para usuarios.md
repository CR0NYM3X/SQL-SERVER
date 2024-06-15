# Crear un trigger que valide cuando se creó, modificó o eliminó un usuario o login

```
--------- Creacion de la tabla donde se guardaran los regstros ----------

USE [master]

CREATE TABLE [dbo].[AuditoriaLogins](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FechaEvento] [datetime] NULL,
	[TipoEvento] [nvarchar](255) NULL,
	[Creador_del_Login] [nvarchar](255) NULL,
	[query_event] [nvarchar](255) NULL,
	[ip_Server] [varchar](255) NULL,
	[ip_cliente] [varchar](255) NULL);



---------- TRIGGER ----------
USE [master]

/*
Creacion de Trigger tipo desencadenadores  DDL https://learn.microsoft.com/es-es/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-ver16
Estos eventos corresponden principalmente a instrucciones CREATE, ALTER y DROP de Transact-SQL
*/


Create TRIGGER [DDL_Trigger_Login_Changed]
ON ALL SERVER

/* DDL Events: https://learn.microsoft.com/en-us/sql/relational-databases/triggers/ddl-events?view=sql-server-ver16 
Estos son los Eventos/Acciones que valida el trigger
*/
AFTER CREATE_LOGIN, ALTER_LOGIN, DROP_LOGIN, 
CREATE_USER, ALTER_USER, DROP_USER,
GRANT_DATABASE, DENY_DATABASE, REVOKE_DATABASE,
GRANT_SERVER, DENY_SERVER, REVOKE_SERVER
AS

BEGIN
Declare @eventDate DATETIME
Declare @results_query varchar(max)
Declare @results_type varchar(max)
Declare @results_user varchar(max)
--DECLARE @eventDate DATETIME = GETDATE();
Declare @IP_Server varchar(max)
Declare @IP_cliente varchar(max)

SET @IP_Server = (SELECT local_net_address + ',' + CAST(local_tcp_port AS VARCHAR(10)) as Servidor FROM sys.dm_exec_connections WHERE session_id = @@SPID)
SET @IP_cliente = (select client_net_address as IP_cliente FROM sys.dm_exec_connections WHERE session_id = @@SPID)


SET @eventDate  = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','DATETIME'))
SET @results_query = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)'))
SET @results_type = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(max)'))
SET @results_user = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','nvarchar(max)'))


INSERT INTO dbo.AuditoriaLogins (  TipoEvento,Creador_del_Login,FechaEvento,query_event, ip_server,ip_cliente) VALUES (@results_type, @results_user, @eventDate , @results_query,  @IP_Server, @IP_cliente)
  --	PRINT('Trigger fired!' + @subjectText  + @results);
END;

ENABLE TRIGGER [tri_VerificaUsuario] on  all server ;



----------  Consutlar Información  ----------

select * from  [master].[dbo].[AuditoriaLogins]
truncate table  [master].[dbo].[audit_user]



----------  Ejemplos ----------
CREATE LOGIN user_new2 WITH PASSWORD=N'123123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;

ALTER LOGIN user_new2 WITH PASSWORD = 'nueva_contraseña';
drop login user_new2;
```

# Crear una auditoria que valide cuando  se creó, modificó o eliminó un usuario o login

```

---------- Creando auditoria --------------

use master
go 

CREATE SERVER AUDIT [nueva_auditoria_user]
TO FILE 
(	FILEPATH = N'F:\prueba123\'
	,MAXSIZE = 256 MB
	,MAX_ROLLOVER_FILES = 8
	,RESERVE_DISK_SPACE = ON
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE )

--- habulitar la auditoria 
ALTER SERVER AUDIT [nueva_auditoria_user] WITH (STATE = ON)



---------- Especificando que quiere que guarde la auditoria ----------

/*
Estos son los eventos que le podemos pedir a la auditoria que guarde

#Server-Level Audit Action Groups
https://learn.microsoft.com/en-us/sql/relational-databases/security/auditing/sql-server-audit-action-groups-and-actions?view=sql-server-ver16
*/

CREATE SERVER AUDIT SPECIFICATION [auditando-servidor-nivel-user]
FOR SERVER AUDIT [nueva_auditoria_user]
ADD (AUDIT_CHANGE_GROUP),
ADD (DATABASE_CHANGE_GROUP),
ADD (DATABASE_OBJECT_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP)
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP)

WITH (STATE = ON);
GO




--------- 	CONSULTA LA AUDITORIA -------


### Server Audit Filter Values For [action_id] https://sqlquantumleap.com/reference/server-audit-filter-values-for-action_id/


SELECT   client_ip,event_time, a.action_id, action_id_desc, a.class_type,class_type_desc, securable_class_desc , session_server_principal_name, server_principal_name, database_name, object_name, statement as query  FROM sys.fn_get_audit_file('F:\prueba123\nueva_auditoria_user*.sqlaudit', DEFAULT, DEFAULT) as a  
left join  sys.dm_audit_class_type_map as b on a.class_type=b.class_type
left join (select * from (SELECT 'ACCESS'  as action_id_desc  ,     'AS' as action_id UNION ALL SELECT 'ADD FEATURE RESTRICTION',       'ADFR' UNION ALL SELECT 'ADD MEMBER',    'APRL' UNION ALL SELECT 'ADD SENSITIVITY CLASSIFICATION',        'ADSC' UNION ALL SELECT 'ALTER', 'AL' UNION ALL SELECT 'ALTER CONNECTION',      'ALCN' UNION ALL SELECT 'ALTER RESOURCES',       'ALRS' UNION ALL SELECT 'ALTER SERVER STATE',    'ALSS' UNION ALL SELECT 'ALTER SETTINGS',        'ALST' UNION ALL SELECT 'ALTER TRACE',   'ALTR' UNION ALL SELECT 'APPLICATION_ROLE_CHANGE_PASSWORD_GROUP',        'PWAR' UNION ALL SELECT 'AUDIT SESSION CHANGED', 'AUSC' UNION ALL SELECT 'AUDIT SHUTDOWN ON FAILURE',     'AUSF' UNION ALL SELECT 'AUDIT_CHANGE_GROUP',    'CNAU' UNION ALL SELECT 'AUTHENTICATE',  'AUTH' UNION ALL SELECT 'BACKUP',        'BA' UNION ALL SELECT 'BACKUP LOG',    'BAL' UNION ALL SELECT 'BACKUP_RESTORE_GROUP',  'BRDB' UNION ALL SELECT 'BATCH COMPLETED',       'BCM' UNION ALL SELECT 'BATCH STARTED', 'BST' UNION ALL SELECT 'BATCH_COMPLETED_GROUP', 'BCMG' UNION ALL SELECT 'BATCH_STARTED_GROUP',   'BSTG' UNION ALL SELECT 'BROKER LOGIN',  'LGB' UNION ALL SELECT 'BROKER_LOGIN_GROUP',    'LGBG' UNION ALL SELECT 'BULK ADMIN',    'ADBO' UNION ALL SELECT 'CHANGE DEFAULT DATABASE',       'LGDB' UNION ALL SELECT 'CHANGE DEFAULT LANGUAGE',       'LGLG' UNION ALL SELECT 'CHANGE LOGIN CREDENTIAL',       'CCLG' UNION ALL SELECT 'CHANGE OWN PASSWORD',   'PWCS' UNION ALL SELECT 'CHANGE PASSWORD',       'PWC' UNION ALL SELECT 'CHANGE USERS LOGIN',    'USLG' UNION ALL SELECT 'CHANGE USERS LOGIN AUTO',       'USAF' UNION ALL SELECT 'CHECKPOINT',    'CP' UNION ALL SELECT 'CONNECT',       'CO' UNION ALL SELECT 'COPY PASSWORD', 'USTC' UNION ALL SELECT 'CREATE',        'CR' UNION ALL SELECT 'CREDENTIAL MAP TO LOGIN',       'CMLG' UNION ALL SELECT 'DATABASE AUTHENTICATION FAILED',        'DBAF' UNION ALL SELECT 'DATABASE AUTHENTICATION SUCCEEDED',     'DBAS' UNION ALL SELECT 'DATABASE BULK ADMIN',   'DABO' UNION ALL SELECT 'DATABASE LOGOUT',       'DBL' UNION ALL SELECT 'DATABASE MIRRORING LOGIN',      'LGM' UNION ALL SELECT 'DATABASE_CHANGE_GROUP', 'MNDB' UNION ALL SELECT 'DATABASE_LOGOUT_GROUP', 'DAGL' UNION ALL SELECT 'DATABASE_MIRRORING_LOGIN_GROUP',        'LGMG' UNION ALL SELECT 'DATABASE_OBJECT_ACCESS_GROUP',  'ACDO' UNION ALL SELECT 'DATABASE_OBJECT_CHANGE_GROUP',  'MNDO' UNION ALL SELECT 'DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP',        'TODO' UNION ALL SELECT 'DATABASE_OBJECT_PERMISSION_CHANGE_GROUP',       'GRDO' UNION ALL SELECT 'DATABASE_OPERATION_GROUP',      'OPDB' UNION ALL SELECT 'DATABASE_OWNERSHIP_CHANGE_GROUP',       'TODB' UNION ALL SELECT 'DATABASE_PERMISSION_CHANGE_GROUP',      'GRDB' UNION ALL SELECT 'DATABASE_PRINCIPAL_CHANGE_GROUP',       'MNDP' UNION ALL SELECT 'DATABASE_PRINCIPAL_IMPERSONATION_GROUP',        'IMDP' UNION ALL SELECT 'DATABASE_ROLE_MEMBER_CHANGE_GROUP',     'ADDP' UNION ALL SELECT 'DBCC',  'DBCC' UNION ALL SELECT 'DBCC_GROUP',    'DBCG' UNION ALL SELECT 'DELETE',        'DL' UNION ALL SELECT 'DENY',  'D' UNION ALL SELECT 'DENY WITH CASCADE',     'DWC' UNION ALL SELECT 'DISABLE',       'LGDA' UNION ALL SELECT 'DROP',  'DR' UNION ALL SELECT 'DROP FEATURE RESTRICTION',      'DRFR' UNION ALL SELECT 'DROP MEMBER',   'DPRL' UNION ALL SELECT 'DROP SENSITIVITY CLASSIFICATION',       'DRSC' UNION ALL SELECT 'ENABLE',        'LGEA' UNION ALL SELECT 'EXECUTE',       'EX' UNION ALL SELECT 'EXTERNAL ACCESS ASSEMBLY',      'XA' UNION ALL SELECT 'FAILED_DATABASE_AUTHENTICATION_GROUP',  'DAGF' UNION ALL SELECT 'FAILED_LOGIN_GROUP',    'LGFL' UNION ALL SELECT 'FEATURE_RESTRICTION_CHANGE_GROUP',      'FRCG' UNION ALL SELECT 'FULLTEXT',      'FT' UNION ALL SELECT 'FULLTEXT_GROUP',        'FTG' UNION ALL SELECT 'GLOBAL TRANSACTIONS LOGIN',     'LGG' UNION ALL SELECT 'GLOBAL_TRANSACTIONS_LOGIN_GROUP',       'LGGG' UNION ALL SELECT 'GRANT', 'G' UNION ALL SELECT 'GRANT WITH GRANT',      'GWG' UNION ALL SELECT 'IMPERSONATE',   'IMP' UNION ALL SELECT 'INSERT',        'IN' UNION ALL SELECT 'LOGIN FAILED',  'LGIF' UNION ALL SELECT 'LOGIN SUCCEEDED',       'LGIS' UNION ALL SELECT 'LOGIN_CHANGE_PASSWORD_GROUP',   'PWCG' UNION ALL SELECT 'LOGOUT',        'LGO' UNION ALL SELECT 'LOGOUT_GROUP',  'LO' UNION ALL SELECT 'MUST CHANGE PASSWORD',  'PWMC' UNION ALL SELECT 'NAME CHANGE',   'LGNM' UNION ALL SELECT 'NO CREDENTIAL MAP TO LOGIN',    'NMLG' UNION ALL SELECT 'OPEN',  'OP' UNION ALL SELECT 'PASSWORD EXPIRATION',   'PWEX' UNION ALL SELECT 'PASSWORD POLICY',       'PWPL' UNION ALL SELECT 'RECEIVE',       'RC' UNION ALL SELECT 'REFERENCES',    'RF' UNION ALL SELECT 'RESET OWN PASSWORD',    'PWRS' UNION ALL SELECT 'RESET PASSWORD',        'PWR' UNION ALL SELECT 'RESTORE',       'RS' UNION ALL SELECT 'REVOKE',        'R' UNION ALL SELECT 'REVOKE WITH CASCADE',   'RWC' UNION ALL SELECT 'REVOKE WITH GRANT',     'RWG' UNION ALL SELECT 'RPC COMPLETED', 'RCM' UNION ALL SELECT 'RPC STARTED',   'RST' UNION ALL SELECT 'SCHEMA_OBJECT_ACCESS_GROUP',    'ACO' UNION ALL SELECT 'SCHEMA_OBJECT_CHANGE_GROUP',    'MNO' UNION ALL SELECT 'SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP',  'TOO' UNION ALL SELECT 'SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP', 'GRO' UNION ALL SELECT 'SELECT',        'SL' UNION ALL SELECT 'SEND',  'SN' UNION ALL SELECT 'SENSITIVITY_CLASSIFICATION_CHANGE_GROUP',       'SCCG' UNION ALL SELECT 'SERVER CONTINUE',       'SVCN' UNION ALL SELECT 'SERVER PAUSED', 'SVPD' UNION ALL SELECT 'SERVER SHUTDOWN',       'SVSD' UNION ALL SELECT 'SERVER STARTED',        'SVSR' UNION ALL SELECT 'SERVER_OBJECT_CHANGE_GROUP',    'MNSO' UNION ALL SELECT 'SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP',  'TOSO' UNION ALL SELECT 'SERVER_OBJECT_PERMISSION_CHANGE_GROUP', 'GRSO' UNION ALL SELECT 'SERVER_OPERATION_GROUP',        'OPSV' UNION ALL SELECT 'SERVER_PERMISSION_CHANGE_GROUP',        'GRSV' UNION ALL SELECT 'SERVER_PRINCIPAL_CHANGE_GROUP', 'MNSP' UNION ALL SELECT 'SERVER_PRINCIPAL_IMPERSONATION_GROUP',  'IMSP' UNION ALL SELECT 'SERVER_ROLE_MEMBER_CHANGE_GROUP',       'ADSP' UNION ALL SELECT 'SERVER_STATE_CHANGE_GROUP',     'STSV' UNION ALL SELECT 'SHOW PLAN',     'SPLN' UNION ALL SELECT 'STATEMENT ROLLBACK',    'UNDO' UNION ALL SELECT 'STATEMENT_ROLLBACK_GROUP',      'UNDG' UNION ALL SELECT 'STORAGE LOGIN', 'LGS' UNION ALL SELECT 'STORAGE_LOGIN_GROUP',   'LGSG' UNION ALL SELECT 'SUBSCRIBE QUERY NOTIFICATION',  'SUQN' UNION ALL SELECT 'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP',      'DAGS' UNION ALL SELECT 'SUCCESSFUL_LOGIN_GROUP',        'LGSD' UNION ALL SELECT 'TAKE OWNERSHIP',        'TO' UNION ALL SELECT 'TRACE AUDIT C2OFF',     'C2OF' UNION ALL SELECT 'TRACE AUDIT C2ON',      'C2ON' UNION ALL SELECT 'TRACE AUDIT START',     'TASA' UNION ALL SELECT 'TRACE AUDIT STOP',      'TASP' UNION ALL SELECT 'TRACE_CHANGE_GROUP',    'TRCG' UNION ALL SELECT 'TRANSACTION BEGIN',     'TXBG' UNION ALL SELECT 'TRANSACTION BEGIN COMPLETED',   'TRBC' UNION ALL SELECT 'TRANSACTION BEGIN STARTING',    'TRBS' UNION ALL SELECT 'TRANSACTION COMMIT',    'TXCM' UNION ALL SELECT 'TRANSACTION COMMIT COMPLETED',  'TRCC' UNION ALL SELECT 'TRANSACTION COMMIT STARTING',   'TRCS' UNION ALL SELECT 'TRANSACTION PROMOTE COMPLETED', 'TRPC' UNION ALL SELECT 'TRANSACTION PROMOTE STARTING',  'TRPS' UNION ALL SELECT 'TRANSACTION PROPAGATE COMPLETED',       'TRGC' UNION ALL SELECT 'TRANSACTION PROPAGATE STARTING',        'TRGS' UNION ALL SELECT 'TRANSACTION ROLLBACK',  'TXRB' UNION ALL SELECT 'TRANSACTION ROLLBACK COMPLETED',        'TRRC' UNION ALL SELECT 'TRANSACTION ROLLBACK STARTING', 'TRRS' UNION ALL SELECT 'TRANSACTION SAVEPOINT COMPLETED',       'TRSC' UNION ALL SELECT 'TRANSACTION SAVEPOINT STARTING',        'TRSS' UNION ALL SELECT 'TRANSACTION_BEGIN_GROUP',       'TXGG' UNION ALL SELECT 'TRANSACTION_COMMIT_GROUP',      'TXCG' UNION ALL SELECT 'TRANSACTION_GROUP',     'TX' UNION ALL SELECT 'TRANSACTION_ROLLBACK_GROUP',    'TXRG' UNION ALL SELECT 'TRANSFER',      'TRO' UNION ALL SELECT 'UNLOCK ACCOUNT',        'PWU' UNION ALL SELECT 'UNSAFE ASSEMBLY',       'XU' UNION ALL SELECT 'UPDATE',        'UP' UNION ALL SELECT 'USER DEFINED AUDIT',    'UDAU' UNION ALL SELECT 'USER_CHANGE_PASSWORD_GROUP',    'UCGP' UNION ALL SELECT 'USER_DEFINED_AUDIT_GROUP',      'UDAG' UNION ALL SELECT 'VIEW',  'VW' UNION ALL SELECT 'VIEW CHANGETRACKING',   'VWCT' UNION ALL SELECT 'VIEW DATABASE STATE',   'VDST' UNION ALL SELECT 'VIEW SERVER STATE',     'VSST') as f) as f on a.action_id=f.action_id

```


# Verificar con tracer cuando se  creó, modificó o eliminó un usuario o login

https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-create-transact-sql?view=sql-server-ver16


```
SELECT * FROM SYS.TRACES;

/*
 Es una función en SQL Server que se utiliza para obtener información sobre las trazas de seguimiento (traces) que se están ejecutando en el servidor. Esta función proporciona detalles sobre las trazas de eventos que están activas en la instancia actual de SQL Server.
 
 En SQL Server, cuando configuras una traza de seguimiento, puedes definir un tamaño máximo para los archivos de traza para evitar que crezcan indefinidamente
 
 https://learn.microsoft.com/es-es/sql/relational-databases/system-stored-procedures/sp-trace-setstatus-transact-sql?view=sql-server-ver16
 
 Para configurar la traza :
 
 DECLARE @traceid INT;
SET @traceid = (SELECT TraceID FROM sys.fn_trace_getinfo(NULL) WHERE Property = 2); -- Obtener el TraceID de la traza

-- Cambiar el tamaño máximo del archivo de traza
EXEC sp_trace_setstatus @traceid, 2, @maxfilesize = 100;
 
 
*/



---- Saber cuando crearon un usuario y cuano lo eliminaron 

SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.RoleName ,
        t.TargetUserName ,
        t.TargetLoginName ,
        t.SessionLoginName,
		v.subclass_name
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Audit Addlogin Event', 'Audit Add DB User Event',
                     'Audit Add Member to DB Role Event' )
      AND v.subclass_name IN ( 'add', 'create' ,'drop')


--- saber cuando se creo | esto solo sirve si todavia existe el usuario  
SELECT name, create_date, modify_date  FROM sys.server_principals WHERE type_desc = 'SQL_LOGIN'
```
