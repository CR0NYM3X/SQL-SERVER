# Aprenderemos a crear trazas 
Existe un trace que se crea por default y  que captura todo 


### Deshabilitar el Trace Default 
```SQL 
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'default trace enabled', 0;
RECONFIGURE;

```

### Consultar trarace
```
Aquí estan todos los eventos:
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-setevent-transact-sql?view=sql-server-ver16

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

```


### Blibliografías 
```
https://sqland.wordpress.com/2017/12/08/what-is-server-side-trace-and-how-to-use-it/ 
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-create-transact-sql?view=sql-server-ver16

```
