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

SELECT  
 --EventClass,
TE.name AS [EventName] ,
   v.subclass_name ,       
   T.DatabaseName ,       
   t.DatabaseID ,       
   t.NTDomainName ,        
   t.ApplicationName ,       
   t.LoginName ,   
   
   CASE 
        WHEN CHARINDEX('[CLIENT: ', textdata) > 0 AND CHARINDEX(']', textdata) > CHARINDEX('[CLIENT: ', textdata)
        THEN SUBSTRING(
            textdata,
            CHARINDEX('[CLIENT: ', textdata) + LEN('[CLIENT: '),
            CHARINDEX(']', textdata) - (CHARINDEX('[CLIENT: ', textdata) + LEN('[CLIENT: '))
        )
        ELSE null
    END AS IPAddress,

   t.SPID ,   
   t.StartTime ,     
   t.RoleName ,      
   t.TargetUserName ,   
   t.TargetLoginName ,       
   t.SessionLoginName,        
    textdata
    
    
   FROM   

   sys.fn_trace_gettable( ('I:\SQLERRORLOG\login_user.trc' ), DEFAULT) T    
   JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id     
   JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id     
   AND v.subclass_value = t.EventSubClass 
   where  cast(StartTime as date ) = cast(getdate() as date )
   order by StartTime desc

```


### Blibliografías 
```
https://sqland.wordpress.com/2017/12/08/what-is-server-side-trace-and-how-to-use-it/ 
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-create-transact-sql?view=sql-server-ver16

```
