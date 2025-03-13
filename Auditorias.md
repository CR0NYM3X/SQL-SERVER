## Ver como esta configurado las auditorias (Login Auditing y Server Authentication)
```SQL
--- https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/xp-loginconfig-transact-sql?view=sql-server-ver16
--- https://stackoverflow.com/questions/11367886/how-to-get-sql-server-login-audit-setting-using-t-sql-or-sys-view
EXEC xp_loginconfig 'default domain';
EXEC xp_loginconfig 'default login';
EXEC xp_loginconfig 'map $';


EXEC xp_loginconfig 'login mode';
 
EXEC xp_loginconfig 'audit level'; 

declare @AuditLevel int
exec master..xp_instance_regread 
    @rootkey='HKEY_LOCAL_MACHINE',
    @key='SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    @value_name='AuditLevel',
    @value=@AuditLevel output
select @AuditLevel

/*
None = 0
Successful Logins Only = 1
Failed Logins Only = 2
Both Failed and Successful Logins = 3
*/

```


## Otros 

```SQL
SELECT * FROM   SYS.SERVER_FILE_AUDITS
SELECT * FROM sys.server_audits; -- Muestra las auditorías de nivel de servidor

SELECT * FROM sys.server_audit_specifications; -- Muestra las especificaciones de auditoría de nivel de servidor

SELECT * FROM sys.database_audit_specifications; -- Muestra las especificaciones de auditoría de nivel de base de datos


--- audit servver 
SELECT sas.name           AS audit_specification_name,
       audit_action_name
FROM   sys.server_audits  AS sa
       JOIN sys.server_audit_specifications AS sas
            ON  sa.audit_guid = sas.audit_guid
       JOIN sys.server_audit_specification_details AS sasd
            ON  sas.server_specification_id = sasd.server_specification_id

--- audit database
SELECT sas.name as audit_specification_name,
       audit_action_name,
       dp.name                       AS [principal],
       SCHEMA_NAME(o.schema_id) + '.' + o.name AS OBJECT
FROM   sys.server_audits             AS sa
       JOIN sys.database_audit_specifications AS sas
            ON  sa.audit_guid = sas.audit_guid
       JOIN sys.database_audit_specification_details AS sasd
            ON  sas.database_specification_id = sasd.database_specification_id
       JOIN sys.database_principals  AS dp
            ON  dp.principal_id = sasd.audited_principal_id
       JOIN sys.objects              AS o
            ON  o.object_id = sasd.major_id





select * from sys.server_file_audits  
select * from sys.dm_server_audit_status
SELECT * FROM  sys.dm_audit_class_type_map where class_type like '%SL%'
```
