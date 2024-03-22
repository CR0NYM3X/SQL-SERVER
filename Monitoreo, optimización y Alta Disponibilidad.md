# Objetivo:
Monitorear las base de datos detectar posibles bloqueos, lentitud y intentar solucionar el detalle que se presente

> [!TIP]
> **`Las cosas que se validan son:`** Porcentaje % de  procesador y discos, algún tipo de bloqueo a tablas, transacciones o consultas con tiempos elevados


# Procedimientos almacenados para monitorear 


- Monitoreo de Actividad y Rendimiento:<br>
**`sp_who`** <br>
**`sp_who2:`** Proporciona información sobre usuarios activos, conexiones y bloqueos. <br>
**`sp_Who3`** <br>
**`sp_whoisactive:`** Ofrece una visión detallada de la actividad actual, incluyendo detalles de bloqueos, consultas en ejecución,  Provee detalles sobre sesiones activas, bloqueos y recursos utilizados por las consultas. <br>
**`sp_lock`**


- Monitoreo de Espacio en Disco:<br>
**`sp_spaceused:`** Muestra el espacio utilizado por una base de datos en particular. <br>
**`sp_helpdb:`** Proporciona información detallada sobre todas las bases de datos. <br>

- Monitorización del Plan de Mantenimiento:<br>
**`sp_help_job`** -- este proc se ejecuta en la msdb y Muestra información sobre trabajos de SQL Server Agent.


# tablas y vistas útiles para monitorear
<br><br>-------- `CONEXIONES Y SESIONES` --------<br><br>
**`sys.dm_exec_connections:`** Detalles de las conexiones activas al servidor. <br>
**`sys.dm_exec_requests:`** Proporciona información sobre las solicitudes actuales en ejecución en el servidor. <br>
**`sys.dm_exec_sessions:`** Contiene información sobre las sesiones actuales en el servidor, lo que puede ser útil para rastrear quién está conectado y qué están haciendo. <br>
**`sys.sysprocesses`**  detalles sobre las sesiones que estaban conectadas al servidor en un momento dado, incluyendo información sobre ID de sesión, estado de la sesión, tiempo de CPU utilizado, ID de usuario<br>
**`sys.dm_exec_query_stats:`** Estadísticas de ejecución de consultas. <br>

<br><br>-------- `OS` --------<br><br>
**`sys.stats:`** almacena información sobre las estadísticas de las columnas de las tablas de la base de datos<br>
**`sys.dm_db_partition_stats`** almacenamiento y la distribución de las filas y páginas de datos de una tabla o índice en una base de datos.<br>



<br><br>-------- `OS` --------<br><br>
**`sys.dm_io_virtual_file_stats:`** Proporciona estadísticas de E/S a nivel de archivo, lo que es esencial para monitorear la actividad de E/S en el servidor. <br>
**`sys.dm_os_wait_stats:`** Ofrece estadísticas sobre los tipos de espera que están afectando el rendimiento del servidor. <br>
**`sys.dm_os_sys_info:`** Contiene información sobre la configuración del sistema y los recursos del servidor. <br>
**`sys.dm_os_buffer_descriptors:`** Proporciona información sobre los bloques de memoria que se están utilizando actualmente en la memoria caché del búfer. <br>
**`sys.dm_os_ring_buffers:`** Registros de eventos del sistema. <br>
**`sys.dm_os_tasks:`** Detalles de las tareas en el sistema operativo. <br>
**`sys.dm_os_memory_clerks:`** Detalles sobre la asignación de memoria. <br>
**`sys.dm_os_loaded_modules:`** Módulos cargados en SQL Server. <br>
**`sys.dm_os_schedulers:`** Información sobre los programadores (schedulers) del sistema. <br>
**`sys.dm_os_waiting_tasks`** Esta vista es fundamental para identificar cuellos de botella, bloqueos y problemas de rendimiento en el servidor SQL Server.<br>
**`sys.dm_os_performance_counters:`** Ofrece información sobre contadores de rendimiento de SQL Server que pueden ser cruciales para monitorear el rendimiento general del servidor.  <br>
**`sys.dm_server_services:`** Detalles sobre los servicios de SQL Server en la máquina. <br>

<br><br>-------- `INDEX` --------<br><br>
**`sys.sysindexes`** 
SELECT * FROM **`sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('CatPersona'), NULL, NULL)`** AS S WHERE index_id = 0; ---- saber la cantidad de updates, delete , insert <br>
**`sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL)`**  detallada sobre la fragmentación y la distribución física de los índices de una base de datos.<br>
**`sys.dm_db_index_physical_stats:`** Ofrece información detallada sobre el estado físico de los índices, lo que puede ser útil para identificar problemas de rendimiento relacionados con los índices. y ver si necesita una desfragmentacion <br>
**`sys.dm_db_index_usage_stats`** mantiene estadísticas sobre la actividad de los índices, como cuándo se han utilizado por última vez, cuántas operaciones de lectura y escritura han realizado<br>
**`sys.dm_db_missing_index_details:`** Información sobre índices faltantes. <br
										    


<br><br>-------- `TRANSACIONES` --------<br><br>
**`sys.dm_tran_locks:`** Información sobre bloqueos actuales. <br>
SELECT * FROM **`sys.dm_tran_active_transactions`**; <br>
select * from **`sys.dm_tran_session_transactions`**    <br>
SELECT * FROM  **`sys.dm_tran_database_transactions`** <br>



### Habilita las estadisticas al momento de realizar consultas, para ver los tiempos de ejecucion y consumo 
```sql
  SET STATISTICS TIME ON; -- Muestra las estadísticas de tiempo
  SET STATISTICS IO ON; -- Muestra las estadísticas de E/S
  set statistics profile on
  SET SHOWPLAN_XML on; -- Muestra el plan de ejecución en formato XML -
  SET SHOWPLAN_ALL on;
  SET SHOWPLAN_TEXT on; -- Muestra el plan de ejecución en formato de texto
 ```


# ingresar el proc sp_who2  a una tabla temporal
```
************ CREAMOS TABLA TMP ************
CREATE TABLE #sp_who2 (SPID INT, Status VARCHAR(255),
Login  VARCHAR(255), HostName  VARCHAR(255),
BlkBy  VARCHAR(255), DBName  VARCHAR(255),
Command VARCHAR(255), CPUTime INT,
DiskIO INT, LastBatch VARCHAR(255),
ProgramName VARCHAR(255), SPID1 INT,
REQUESTID INT);

************ INSERTAMOS LOS DATOS EN LA TABLA ************
INSERT INTO #sp_who2 EXEC sp_who2

************ CONSULTAMOS ************ 
SELECT      * FROM    #sp_who2 WHERE       login like '%respa%'  ORDER BY    SPID ASC;

************ ELIMINAMOS TABLA ************
drop table #sp_who2
```


# Información que puede servir:
- ver máximo de conexiones
```
select  @@MAX_CONNECTIONS
```
- ver la ip actual 
```
select CONNECTIONPROPERTY('local_net_address') ---  
SELECT * FROM sys.dm_exec_connections WHERE session_id = @@SPID ---  ver la ip actual 
```
- Ver el usuario que se esta usando en la conexión
```
select SUSER_SNAME() -- saber el usuario que estas usando actualmente
select SUSER_ID()	-- saber el id del usuario que estas usando actualmente
select USER_NAME(grantee_principal_id) -- saber que usuario tiene un id
```

- ver el nombre de un objeto con el id
```
OBJECT_NAME(major_id) AS object_name
```



# Mantenimientos y optimización :

 ### Actualización de estadísticas:
Actualizar todas las estadísticas en una base de datos específica, Actualizar estadísticas ayuda al optimizador de consultas a tomar decisiones más precisas sobre los planes de ejecución de consultas, mejorando así el rendimiento
```
EXEC sp_updatestats;  
```
Actualizar estadísticas de una tabla específica
```
UPDATE STATISTICS nombre_tabla; 
```

### Reorganización o reconstrucción de índices:
Esto puede mejorar el rendimiento de las consultas al mantener los índices de la base de datos.
```
************** REINDEX ESPECIFICANDO TABLAS ********
ALTER INDEX ALL ON tu_tabla REBUILD;
ALTER INDEX ALL ON tu_tabla REORGANIZE;

ALTER INDEX nombre_indice ON nombre_tabla REBUILD;


************** REINDEX EN TODAS LA TABLAS ********
DECLARE @sql NVARCHAR(MAX);

SELECT @sql = 
    COALESCE(@sql  , '') +
    'ALTER INDEX ALL ON ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ' REBUILD;' +
    'ALTER INDEX ALL ON ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ' REORGANIZE;'
FROM sys.tables;
 
 EXEC sp_executesql @sql;


************** REINDEX CON PROC ********
DBCC DBREINDEX ('HumanResources.Employee', PK_Employee_BusinessEntityID, 80);

```





### Verificación de planes de ejecución:
Limpiar la caché de consultas puede ser útil en ciertos casos para que el optimizador de consultas pueda reevaluar los planes de ejecución.
```
DBCC FREEPROCCACHE; 
```
### Liberar espacio en disco 
En SQL Server que se utiliza para reducir el tamaño de un archivo de base de datos específico.
Se puede aplicar tanto a archivos de datos **`(.mdf)`** como a archivos de registro de transacciones **`(.ldf)`**
Esta operación libera espacio no utilizado dentro de los archivos de la base de datos,
lo que puede ser útil en situaciones donde se ha producido un crecimiento excesivo de los archivos o para recuperar espacio en disco.

```
DBCC SHRINKFILE ('MibaseDeDatos_log', 1024); -- 1024 es el nuevo tamaño en MB

DBCC SHRINKDATABASE
```

Este tipo de consulta te proporciona información sobre el tamaño actual y el crecimiento configurado de los archivos de datos de tus bases de datos.
```
SELECT name, size/128.0 AS 'Tamaño (MB)', growth/128.0 AS 'Crecimiento (MB)' FROM sys.master_files WHERE type_desc = 'ROWS';
```

Ver el espacio usado de un disco y lo disponible
```
execute SYS.sp_MSforeachdb '
      use [?];
SELECT DB_NAME()AS DbName,
name ASFileName,
(size/128.0)/1024 AS CurrentSizeGB,
(size/128.0 -CAST(FILEPROPERTY(name,''SpaceUsed'')AS INT)/128.0)/1024 AS FreeSpaceGB 
FROM sys.database_files'

```

### Saber el tamaño utilizado de los archivos MDF, NDF y LDF 
```
******* OPCION #1 *******
SELECT
     DB_NAME(database_id) AS 'Nombre de la base de datos'
    ,name AS 'Nombre del archivo'
    ,size * 8 / 1024 AS 'Tamaño total del archivo (MB)'
    ,CAST(growth / 128.0 AS DECIMAL(18, 2)) AS 'Crecimiento (MB)'
    ,CASE WHEN max_size = -1 THEN 'Unlimited' ELSE CAST(CAST(max_size * 8.0 / 1024 AS DECIMAL(18, 2)) as NVARCHAR(20)) + ' MB' END AS MaxSize
    ,FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024 AS 'Espacio utilizado (MB)'
    ,(size * 8 / 1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024 ) as 'Espacio disponible (MB)'
    ,physical_name AS 'Ruta física'
    ,LEFT(physical_name, 1) unidad_disco
FROM sys.master_files
	where database_id =  DB_ID()
ORDER BY LEFT(physical_name, 1) asc, database_id;

******* OPCION #2 *******
SELECT name, size/128.0 FileSizeInMB,
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 
   AS EmptySpaceInMB
FROM sys.database_files;

******* OPCION #3 *******
DBCC SQLPERF(logspace);
```

se utiliza para corregir las páginas de asignación de espacio y actualizar la información de uso de espacio de la base de datos en el catálogo del sistema y  son responsables de los reportes de uso de espacio mediante comandos como sp_spaceused que sirve para ver el espacio usado de las tablas 
**`[NOTA ]--->`**  Usar casos excepcionales donde los datos de asignación de espacio necesiten ponerse al día después de cambios extensos.
```
DBCC UPDATEUSAGE(0)
```

Muestra información detallada sobre los archivos de la base de datos.
```
DBCC SHOWFILESTATS
```


Tamaño de los archivos de la base de datos y espacio utilizado
```
EXEC sp_spaceused;
```

Proporciona detalles sobre el tamaño total del registro de transacciones, así como el espacio utilizado y el espacio libre dentro del registro.
```
DBCC SQLPERF(logspace);
```

# Ejemplos de usos de las tablas para monitorear 

```

SELECT * FROM sys.dm_exec_connections WHERE client_net_address = '192.59.21.100'
SELECT * FROM sys.dm_exec_sessions WHERE login_name = 'MYDOMINIO\omar.lopez'
SELECT * --spid, loginame, hostname, program_name FROM sys.sysprocesses WHERE loginame= 'MYDOMINIO\omar.lopez' and status = 'runnable' OR status = 'sleeping'


************** ESTADISTICAS DE EJECUCIÓN DE CONSULTAS **************
SELECT qs.execution_count, 
       CAST((CAST(qs.total_elapsed_time as float)/60000) AS DECIMAL(10, 3)) as total_time, 
	   CAST(CAST((qs.total_elapsed_time/qs.execution_count)as float)/60000 AS DECIMAL(10, 3))  AS time_por_ejecucion, 
       qt.text AS [Query Text], 
	   qp.query_plan AS [Query Plan]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp



 	SELECT TOP 10
	        t.text ,
	        execution_count ,
	        statement_start_offset AS stmt_start_offset ,
	        sql_handle ,
	        plan_handle ,
	        total_logical_reads / execution_count AS avg_logical_reads ,
	        total_logical_writes / execution_count AS avg_logical_writes ,
	        total_physical_reads / execution_count AS avg_physical_reads
	FROM	sys.dm_exec_query_stats AS s
	        CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
	ORDER BY avg_physical_reads DESC;



```



# ver procesos bloqueados 

1. -  procesos bloqueador y proceso bloqueado
```
SELECT blocking_session_id as Proceso_BLOQUEADOR, session_id as Proceso_Bloqueado, (wait_duration_ms / (1000 * 60))/ 60  as Duracion_Minutos
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL and (blocking_session_id <> session_id) order by wait_duration_ms desc
```

2. -  revisar con que usuario y desde que ip se esta ejecutando el proceso que esta bloqueando
```
select a.session_id,a.login_name,b.client_net_address,a.login_time,a.host_name,program_name,a.host_process_id,
a.client_interface_name,a.status,b.last_read,b.last_write from sys.dm_exec_sessions a
join sys.dm_exec_connections b on a.session_id=b.session_id AND a.session_id = 88
```
3.-  Esta consulta devolverá información sobre la última instrucción ejecutada en la conexión con el identificador de sesión
```
DBCC INPUTBUFFER (88)   -- num session_id
```

4.- si detectas que un proceso esta bloqueando mata la sesion de esta forma 
```
kill 80 
```
### Habilitar la busqueda de texto
Permite realizar búsquedas eficientes en texto no estructurado o semi-estructurado. Este tipo de búsqueda es útil cuando necesitas buscar patrones de texto, palabras clave o frases dentro de grandes cantidades de datos de texto, como artículos, descripciones, documentos 
```
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dba1_test].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

************* EJEMPLO DE USO *************
SELECT * FROM Documentos WHERE CONTAINS(Contenido, 'palabra1 OR palabra2');
SELECT * FROM Documentos WHERE CONTAINS(Contenido, '"frase exacta"');
SELECT * FROM Documentos WHERE CONTAINS(Contenido, 'NEAR((palabra1, palabra2), n)');
```


### Monitor CPU and Memory usage for all SQL Server instances

```SQL

---  SELECT @@cpu_busy AS "CPU Busy"

declare 
    @Total_SQL_Server_Memory_MB int


-- memory
select @Total_SQL_Server_Memory_MB = (select 
    cntr_value / 1024
from sys.dm_os_performance_counters pc
where   [object_name] = 'SQLServer:Memory Manager'
        and counter_name = 'Total Server Memory (KB)'                                                                                                        
)


select 
    SERVERPROPERTY('SERVERNAME') AS 'Instance',
    (SELECT  sqlserver_start_time FROM sys.dm_os_sys_info) as sqlserver_start_time,
    (SELECT  cpu_count   FROM sys.dm_os_sys_info) as cpu_count,
    (SELECT hyperthread_ratio  FROM sys.dm_os_sys_info) as hyperthread_ratio,
  --  @CPU_Usage_Percentage           [CPU_Usage_Percentage], 
	(SELECT    100 - x.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle/text())[1]', 'TINYINT')FROM (SELECT TOP(1) [timestamp], x = CONVERT(XML, record) 
		FROM sys.dm_os_ring_buffers 
	WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' AND record LIKE '%%') t) as cpu_total,

	cast((SELECT (MAX(CASE WHEN counter_name = 'CPU usage %' THEN t.cntr_value * 1. END) / MAX(CASE WHEN counter_name = 'CPU usage % base' THEN t.cntr_value END) ) * 100 
		FROM (SELECT TOP(2) cntr_value, counter_name
		FROM sys.dm_os_performance_counters
	WHERE counter_name IN ('CPU usage %', 'CPU usage % base') AND instance_name = 'default' ) t) as decimal(18,2)) CPU_SQL,



   (SELECT total_physical_memory_kb/1024 FROM sys.dm_os_sys_memory) AS 'Total Memory Ram OS (MB)',
   (SELECT (total_physical_memory_kb - available_physical_memory_kb)/1024 FROM sys.dm_os_sys_memory) as Memory_used_OS,
   (SELECT (total_physical_memory_kb - available_physical_memory_kb)/1024 FROM sys.dm_os_sys_memory) *100 / (SELECT total_physical_memory_kb/1024 FROM sys.dm_os_sys_memory) AS PERCENTAGE_Memory_used_OS,
   (SELECT available_physical_memory_kb/1024 FROM sys.dm_os_sys_memory) AS 'Available Memory RAM OS (MB)',
   100 - ((SELECT (total_physical_memory_kb - available_physical_memory_kb)/1024 FROM sys.dm_os_sys_memory) *100 / (SELECT total_physical_memory_kb/1024 FROM sys.dm_os_sys_memory)) as 'PERCENTAGE_Available Memory RAM OS',
   @Total_SQL_Server_Memory_MB     [Total_SQL_Server_Memory_MB],
-- (SELECT physical_memory_in_use_kb/1024 FROM sys.dm_os_process_memory) AS 'SQL Server Memory RAM Usage RAM (MB)',
   (SELECT value_in_use FROM sys.configurations WHERE name like '%max server memory%') AS 'Max SQL Server Memory RAM (MB)',
   (SELECT system_memory_state_desc FROM sys.dm_os_sys_memory) AS 'System Memory State',
   (SELECT [cntr_value] FROM sys.dm_os_performance_counters WHERE [object_name] LIKE '%Manager%' AND [counter_name] = 'Page life expectancy') AS 'Page Life Expectancy',
   GETDATE() AS 'Data Sample Timestamp'





-- Otros links:
-- Link : https://learn.microsoft.com/en-us/sql/relational-databases/performance-monitor/monitor-memory-usage?view=sql-server-ver16
-- Link:  https://www.mssqltips.com/sqlservertip/5724/monitor-cpu-and-memory-usage-for-all-sql-server-instances-using-powershell/
-- Link : https://dba.stackexchange.com/questions/298516/how-to-know-real-sql-server-memory-and-cpu-usage
-- Link : http://udayarumilli.com/monitor-cpu-utilization-io-usage-and-memory-usage-in-sql-server/

```

### ver sesiones activas o inactivas
```
SELECT 
    session_id, 
    login_name, 
    status, 
    program_name, 
    host_name, 
    login_time,
    last_request_start_time,
    last_request_end_time
FROM 
    sys.dm_exec_sessions
WHERE 
    status = 'sleeping' -- Filtra las conexiones inactivas (idle)
---  status = 'running' -- Filtra las conexiones activas
```

### Ver si la base de datos le estan insertando o consultando 
```
SELECT   

  	SUBSTRING(volume_mount_point, 1, 1) AS Disco_OS
	,total_bytes/1024/1024/1024 AS total_GB_OS
    ,total_bytes/1024/1024/1024 - available_bytes/1024/1024/1024 AS Usado_GB_OS
    ,available_bytes/1024/1024/1024 AS Disponible_GB_OS
	,DB_NAME() dba ,num_of_reads ,num_of_writes ,type_desc ,name ,physical_name ,state_desc
    ,size * 8 / 1024 AS 'Tamaño total del archivo (MB)'
    ,CAST(growth / 128.0 AS DECIMAL(18, 2)) AS 'Crecimiento (MB)'
	,CASE WHEN max_size = -1 THEN 'Unlimited' ELSE CAST(CAST(max_size * 8.0 / 1024 AS DECIMAL(18, 2)) as NVARCHAR(20)) + ' MB' END AS MaxSize
    ,FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024 AS 'Espacio utilizado (MB)' 
	  FROM sys.dm_io_virtual_file_stats(NULL, NULL) as a
CROSS APPLY  sys.dm_os_volume_stats(a.database_id, a.file_id)
left join  sys.master_files b on a.database_id=b.database_id and a.file_id = b.file_id
where a.database_id = DB_ID()
```






 
### Ver objetos bloqueados 
Recordemos que los objetos se bloquean por seguridad, cuando se realizan algun movimiento por ejemplo :  bulk insert,  bulk copy, insert , update, delete , etc.. etc <br>
Con esta query te va mostar los objetos que estan bloqueados  y ver quien lo esta bloqueando y que ip y la duracion del bloqueo 
```SQL 
/* ---------- DESCRIPCIÓN DEL LA COLUMNA request_mode ----------
[NOTA] todos los que tengan columna  request_mode in('X','IX') y  tranType = read/write --> son transacciones que bloquan la tabla y no van a permitir que realice otro movimiento 

Sch-S (Schema Stability): Este modo de bloqueo se utiliza cuando una transacción intenta adquirir un bloqueo de esquema (Schema Lock)
 para un objeto. Este tipo de bloqueo permite que otros procesos puedan realizar consultas pero evita que realicen modificaciones
 que puedan interferir con la estructura del esquema del objeto.

S (Shared): El bloqueo compartido permite que múltiples transacciones puedan leer datos simultáneamente, pero ninguna de ellas puede
realizar modificaciones mientras el bloqueo está activo. Este tipo de bloqueo es compatible con otros bloqueos compartidos pero no
con bloqueos exclusivos.

U (Update): Indica un bloqueo de actualización. Este bloqueo se adquiere cuando una transacción necesita realizar una modificación
en un recurso y no quiere permitir que otros procesos realicen cambios simultáneos.

X (Exclusive): El bloqueo exclusivo es el tipo más restrictivo de bloqueo. Se adquiere cuando una transacción necesita realizar
 una modificación en un recurso y no permite que otros procesos realicen ninguna operación (lectura o escritura) en ese recurso
hasta que se libere el bloqueo.

IS (Intent Shared): Este tipo de bloqueo indica la intención de adquirir un bloqueo compartido en un recurso más específico dentro
de una jerarquía. Ayuda a evitar bloqueos incoherentes en la jerarquía de bloqueos.

IU (Intent Update): Similar al IS, indica la intención de adquirir un bloqueo de actualización en un recurso más específico dentro
 de una jerarquía de bloqueos.

IX (Intent Exclusive): Indica la intención de adquirir un bloqueo exclusivo en un recurso más específico dentro de una jerarquía
de bloqueos.

*/

  SELECT
	z.transaction_begin_time,
	Duration = CAST(GETDATE() - z.transaction_begin_time AS TIME),
	CASE 
        WHEN z.name = 'user_transaction' THEN 'BEGIN TRANSACTION' 
        ELSE z.name
    END AS Tipo_Transaccion,
	OBJ.name AS object_name,
    TL.resource_type,
	TL.request_type,
    DB_name(TL.resource_database_id) db,
	SCHEMA_NAME(OBJ.schema_id) AS schema_name,
-- TL.resource_associated_entity_id,
-- TL.request_mode,
	    CASE  TL.request_mode
        WHEN 'Sch-S' THEN 'Schema Stability'
        WHEN 'S' THEN '(S)Shared'
        WHEN 'U' THEN '(U)Update'
        WHEN 'X' THEN '(X)Exclusive'
        WHEN 'IS' THEN '(IS)Intent Shared'
        WHEN 'IU' THEN '(IU)Intent Update'
        WHEN 'IX' THEN '(IX)Intent Exclusive'
        ELSE 'Otros modos de bloqueo'
    END AS modo_de_bloqueo,
	ES.session_id,
--  TL.request_session_id,
	TL.request_owner_type,
--  ER.blocking_session_id,
    ES.login_name,
	b.client_net_address,
    ES.host_name,
--  ES.program_name,
    ER.command,
    ER.status,
    ER.wait_type
    ,qt.text Query_Ejecutada
	 ,case z.transaction_type   
      when 1 then 'Read/Write'   
      when 2 then 'Read-Only'    
      when 3 then 'System'   
      when 4 then 'Distributed'  
      else 'Unknown - ' + convert(varchar(20), transaction_type)     
 end as tranType,    
 case z.transaction_state 
    when 0 then '0 = The transaction has not been completely initialized yet'
    when 1 then '1 = The transaction has been initialized but has not started'
    when 2 then '2 = The transaction is active'
    when 3 then '3 = The transaction has ended. This is used for read-only transactions'
    when 4 then '4 = The commit process has been initiated on the distributed transaction'
    when 5 then '5 = The transaction is in a prepared state and waiting resolution'
    when 6 then '6 = The transaction has been committed'
    when 7 then '7 = The transaction is being rolled back'
    when 8 then '8 = The transaction has been rolled back'
      else 'Unknown - ' + convert(varchar(20), transaction_state) 
 end as tranState, 
 case z.dtc_state 
      when 0 then NULL 
      when 1 then 'Active' 
      when 2 then 'Prepared' 
      when 3 then 'Committed' 
      when 4 then 'Aborted' 
      when 5 then 'Recovered' 
      else 'Unknown - ' + convert(varchar(20), dtc_state) 
 end as dtcState 
FROM sys.dm_tran_locks TL
LEFT JOIN sys.dm_exec_requests ER ON TL.request_session_id = ER.session_id
LEFT JOIN sys.dm_exec_sessions ES ON TL.request_session_id = ES.session_id
LEFT JOIN sys.objects OBJ ON TL.resource_associated_entity_id = OBJ.object_id
LEFT JOIN  sys.dm_exec_connections b on  TL.request_session_id=b.session_id  
LEFT JOIN sys.dm_tran_active_transactions  z on z.transaction_id= TL.request_owner_id
CROSS APPLY sys.dm_exec_sql_text( /*ER.sql_handle*/ b.most_recent_sql_handle ) as qt 
  where OBJ.name is not null and  TL.request_mode in('X','IX')
```








### Query para ver que transaccion tiene mas de 2 min ejecutandose

```sql
select	transaction_begin_time  
	--  ,r.session_id  
		,CAST(GETDATE() - transaction_begin_time AS TIME) duracion 
		,db_name(TL.resource_database_id) db
		,OBJ.name AS object_name
		,TL.resource_associated_entity_id  OBject_id_
		,CASE WHEN z.name = 'user_transaction' THEN 'BEGIN TRANSACTION' ELSE z.name END AS Tipo_Transaccion
		,qt.text Query_Ejecutada
		,case z.transaction_type   
			when 1 then 'Read/Write'   
			when 2 then 'Read-Only'    
			when 3 then 'System'   
			when 4 then 'Distributed'  
			else 'Unknown - ' + convert(varchar(20), transaction_type)     
		 end as tranType
		,CASE  TL.request_mode
			WHEN 'Sch-S' THEN 'Schema Stability'
			WHEN 'S' THEN '(S)Shared'
			WHEN 'U' THEN '(U)Update'
	        WHEN 'X' THEN '(X)Exclusive'
			WHEN 'IS' THEN '(IS)Intent Shared'
		    WHEN 'IU' THEN '(IU)Intent Update'
			WHEN 'IX' THEN '(IX)Intent Exclusive'
			ELSE 'Otros modos de bloqueo'
		END AS modo_de_bloqueo
		 , r.status
		 ,r.host_name 
		 ,r.login_name
		 ,b.client_net_address
		 ,r.reads
		 ,r.writes
		--,*
from sys.dm_tran_active_transactions z
LEFT JOIN (select resource_type, resource_database_id, request_owner_id, request_session_id, resource_associated_entity_id ,request_mode
				from  sys.dm_tran_locks 
				where resource_type= 'OBJECT' 
		   group by  resource_type, resource_database_id, request_owner_id, request_session_id, resource_associated_entity_id,request_mode)  TL on z.transaction_id= TL.request_owner_id 
LEFT JOIN sys.dm_exec_connections b on  TL.request_session_id=b.session_id  
LEFT JOIN sys.objects OBJ ON TL.resource_associated_entity_id = OBJ.object_id
LEFT JOIN sys.dm_exec_sessions r on  TL.request_session_id=r.session_id  
CROSS APPLY sys.dm_exec_sql_text( /*ER.sql_handle*/ b.most_recent_sql_handle ) as qt 
where not z.name  = 'worktable' and TL.resource_type= 'OBJECT' and DATEDIFF(/*HOUR SECOND*/ MINUTE , transaction_begin_time, GETDATE()) >= 2
```






### info extra
```sql
 

SELECT 
	cpu_count
	,hyperthread_ratio
	,((physical_memory_in_bytes/1024 /*KB*/) /1024 /*MB*/)
FROM sys.dm_os_sys_info

 

SELECT cast((physical_memory_in_use_kb/1024)as  decimal(10,2)), * FROM sys.dm_os_process_memory

SELECT 
	cast(cast(((total_physical_memory_kb/1024 /*MG*/) ) as  decimal(10,2))/1024 as  decimal(15,2)) total_physical_memory
	,cast(cast(((available_physical_memory_kb/1024 /*MG*/) ) as  decimal(10,2))/1024 as  decimal(15,2)) available_physical_memory  
FROM sys.dm_os_sys_memory



	SELECT * FROM  sys.dm_os_tasks  where task_state = 'RUNNING'
	SELECT * FROM  sys.dm_os_threads
	 
 

*********************  Validar log  ***************
 
SELECT 
    top 100  tl.[Begin Time],[End Time], tl.[Transaction name],*
FROM 
    fn_dblog(NULL, NULL) AS TL
	--where  [Transaction name] = 'BULK INSERT' 
order by [Begin Time] desc


********************* VERIFICAR LOS PORCENTAJES DEL PROCESADOR/ ESTADISTICAS DEL OS *********************


SELECT 
    cntr_value AS 'Uso_CPU',*
FROM 
    sys.dm_os_performance_counters
WHERE 
    object_name = N'SQLServer:Resource Pool Stats'
    AND counter_name like N'%CPU%'
    order by cntr_type 


```





# Bibliografías : 
https://blog.sqlauthority.com/2023/10/06/sql-server-maintenance-techniques-a-comprehensive-guide-to-keeping-your-server-running-smoothly/ <br> 
monitorear: https://sqlperformance.com/2015/03/io-subsystem/monitoring-read-write-latency
