

 
## Eventos de sesión

ruta donde se guardan  : C:/programFiles/Microsoft SQL Server /MSSQL13.MSSQLSERVER/MSSQL/LOG
Archivos con extensión : 
CapturaEventos.xel
 
```sql


https://learn.microsoft.com/en-us/sql/relational-databases/extended-events/quick-start-extended-events-in-sql-server?view=sql-server-ver16


```



```sql

SELECT 
    name AS [Event Session Name],
    create_time AS [Created Time],
    state_desc AS [State],
    target_name AS [Target Name],
    event_count AS [Event Count]
FROM sys.dm_xe_sessions;
```


```SQL
SELECT 
    s.name AS [Event Session Name],
    t.target_name AS [Target Name],
    e.event_name AS [Event Name],
    e.package_name AS [Package Name],
    e.source_name AS [Source Name],
    e.channel AS [Channel]
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t ON s.address = t.event_session_address
JOIN sys.dm_xe_session_events AS e ON s.address = e.event_session_address
WHERE s.name = 'Nombre_de_la_Event_Session';
```


```SQL
SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
    event_data.value('(event/action[@name="duration"]/value)[1]', 'bigint') AS duration
FROM sys.fn_xe_file_target_read_file('ruta_al_archivo.xel', 'ruta_al_archivo.xem', NULL, NULL)
WHERE event_data.value('(event/@name)[1]', 'varchar(50)') = 'sql_statement_completed';
```




