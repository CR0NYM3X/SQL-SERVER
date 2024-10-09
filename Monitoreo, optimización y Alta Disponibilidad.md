# Objetivo:
Monitorear las base de datos detectar posibles bloqueos, lentitud y intentar solucionar el detalle que se presente, usando Dynamic Management Views

> [!TIP]
> **`Las cosas que se validan son:`** Porcentaje % de  procesador y discos, algún tipo de bloqueo a tablas, transacciones o consultas con tiempos elevados

# Pasos para un performance: 

**0.0 Validaciónes basicas:**
**0.1** .- Disco SSD o en buen estado y un buen formateo 

**0.2** .- Habilitar High Performance : Control  -> Power Options -> High Performance (Seleccionar)

**0.3** .- Agregar cuenta de Sql server : gpedit.msc -> Windows Settings -> Security Settings -> Local Policy -> User Rights Assigment  -> (Agregar) [Perform Volume Maintence tasks {mejora el tiempo para Agregar mas espacio en disco,cuando se llena} | Lock pages in memory]

**0.4** .- Memoria Ram: 90% 
**0.5** .- comprimir backup automatico : Server Properties -> DatabaseS Setting -> (Seleccionar) Compress Backup


**Paso 1: Validación Inicial del Servidor**  <br>
**1.1** Verificar Especificaciones del Hardware <br>
**1.2** Verificar Configuraciones del Sistema Operativo <br> 
	Actualizaciones, Plan de Energía: Configura el plan de energía en "Alto rendimiento" para evitar que la CPU se reduzca la velocidad. <br><br>
**1.3** Configuraciones Básicas de SQL Server <br>
Max Degree of Parallelism (MAXDOP) <br>
Memory Settings  <br>

**Paso 2: Monitorización del Rendimiento** <br> 
Activity Monitor: Revisa el monitor de actividad para ver el uso de recursos, bloqueos y consultas más costosas. <br> 
MONITOREAR WAITS, LOCKS Y ESTADISTICAS DE INDICES PARA DETERMINAR LAS QUERYS MAS USADAS <br>

**2.2** Dynamic Management Views (DMVs)  <br>
Consultas Lentas:, Bloqueos:  <br> <br>

**Paso 3: Optimización de Consultas** <br>
OPTIMIZACIÓN EN QUERYS COMO COSTOS O TIEMPOS DE EJECUCIOÓN <br>
Actualización de Estadísticas<br>
Índices: Verifica y optimiza los índices BASANDONOS EN LAS COLUMNAS MAS USADAS .<br><br>

**Paso 4: Mantenimiento Regular**<br>
Tareas de Mantenimiento como INDEX  REORGANIZE y REBUILD <br><br>

**Paso 5: Consideraciones Adicionales** <br>
la TempDB es el encargado de realizar estas Operaciones Temporales: <br>

Tablas Temporales <br>
Variables de Tabla  <br>
Cursors <br>
Operaciones de Sort y Join <br> 

configuraciones  importantes : <br>
Coloca TempDB en almacenamiento rápido (SSD o NVMe)  <br>
Tamaño Inicial: <br>
Crecimiento Automático <br>
Comienza con el mismo número de archivos de datos que el número de núcleos de CPU, hasta un máximo de 8 archivos.<br>
Configuración recomendada: La práctica recomendada es tener un archivo de datos por cada procesador lógico, hasta un máximo de 8 archivos


 


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
**`sys.dm_db_missing_index_details`** - Returns detailed information about a missing index <br>
**`sys.dm_db_missing_index_group_stats`**  - Returns summary information about missing index groups<br>
**`sys.dm_db_missing_index_groups`** - Returns information about a specific group of missing indexes<br>
**`sys.dm_db_missing_index_columns(index_handle)`** - Returns information about the database table columns that are missing for an index. This is a function and requires the index_handle to be passed.<br>
**`sys.sysindexes`** <br>
SELECT * FROM **`sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('CatPersona'), NULL, NULL)`** AS S WHERE index_id = 0; ---- saber la cantidad de updates, delete , insert <br>
**`sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL)`**  detallada sobre la fragmentación y la distribución física de los índices de una base de datos.<br>
**`sys.dm_db_index_physical_stats:`** Ofrece información detallada sobre el estado físico de los índices, lo que puede ser útil para identificar problemas de rendimiento relacionados con los índices. y ver si necesita una desfragmentacion <br>
**`sys.dm_db_index_usage_stats`** mantiene estadísticas sobre la actividad de los índices, como cuándo se han utilizado por última vez, cuántas operaciones de lectura y escritura han realizado<br>
**`sys.dm_db_missing_index_details:`** contiene detalles específicos sobre los índices que faltan, como las columnas que deberían incluirse en el índice propuesto
Son sugerencias generadas por el motor de SQL Server en función de consultas que se ejecutan en la base de datos y que podrían beneficiarse de un índice adicional  <br>
										    


<br><br>-------- `TRANSACIONES` --------<br><br>
**`sys.dm_tran_locks:`** Información sobre bloqueos actuales. <br>
SELECT * FROM **`sys.dm_tran_active_transactions`**; <br>
select * from **`sys.dm_tran_session_transactions`**    <br>
SELECT * FROM  **`sys.dm_tran_database_transactions`** <br>
SELECT * FROM   **`dm_db_log_space_usage`** proporciona información sobre el uso del espacio en el archivo de registro de transacciones <br>


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



####### Identificar Columnas Más Usadas 

SELECT TOP 10
    qs.total_worker_time AS CPU_Time,
    qs.total_elapsed_time AS Total_Time,
    qs.total_logical_reads AS Reads,
    qs.total_logical_writes AS Writes,
    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
    ((CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
    END - qs.statement_start_offset)/2) + 1) AS query_text
FROM
    sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY
    qs.total_worker_time DESC;
	
	
 
####### Identificar Consultas con Alto Consumo de Recursos
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates
FROM
    sys.indexes AS i
    INNER JOIN sys.dm_db_index_usage_stats AS ius
        ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE
    i.object_id = OBJECT_ID('YourTableName')
ORDER BY
    ius.user_seeks DESC;


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

https://www.mssqltips.com/sqlservertutorial/9136/sql-server-full-text-indexes/
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




### Index performance 
Con esta query vas a saber las tablas, con columnas que tienen indices, que tipo de indices y los tamaños de las tablas y los indices 

```sql
1.- Validar que todas las tablas tengan PK , [cuando en una tabla se asigna un primary key
esto genera en automatico un indice agrupado, por lo que ya no se puede generar otro,  no pueden existir 2 pk]
2.- Índices eficientes:
	2.1 - Identifica las consultas más comunes y crea índices adecuados para ellas.
	2.2 - Evita tener demasiados índices innecesarios, ya que pueden ralentizar las operaciones de inserción, actualización y eliminación.
	2.3 - Mantén actualizadas las estadísticas de índice para que el optimizador de consultas pueda generar planes de ejecución óptimos.
	2.4 - columnas con mas de 2 index
	2.5 - Evitar tablas sin indices clustered/agrupados
	2.6 - No usar mas indices que columnas
	2.7 - limitar la fragmentacion de indices
 

Particionamiento de la tabla
Estadísticas actualizadas:
Fragmentación de índices
Consultas eficientes
Almacenamiento en disco SSD 
Re index 
Mantenimientos


/*
SABER SI ESTA PARTICIONADA LA TABLA 

*/

WITH allindex AS (

	 
	 select 
		i.OBJECT_ID, 
		i.index_id,
		OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
		OBJECT_NAME(i.OBJECT_ID) tablename,  
		COL_NAME(ic.object_id, ic.column_id) AS ColumnName  ,
		i.name AS [Index_Name],
		i.type_desc  
	from sys.indexes  i
	 LEFT JOIN  sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	 where  
	   i.type_desc not in('CLUSTERED','HEAP')   
	   and OBJECTPROPERTY(i.object_id,'IsUserTable') = 1 -- /* con esto excluye las tablas del sistema */
	   and  i.is_primary_key  = 0 


), index_stat AS (


	SELECT 
		OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
		OBJECT_NAME(i.[object_id]) AS [TableName],
	   --COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
		i.object_id ,
		i.name AS [Index Name],
		i.index_id,
		i.type_desc,
		ISNULL(s.user_seeks   ,0) user_seeks,
		ISNULL(s.user_scans   ,0) user_scans,
		ISNULL(s.user_lookups ,0) user_lookups,
		ISNULL(s.user_updates ,0) user_updates,
		CAST(ISNULL(ps.avg_fragmentation_in_percent,0) AS DECIMAL(20,2)) AS Fragmentacion_Porcentaje
	FROM 
		sys.indexes i 
	LEFT JOIN  sys.dm_db_index_usage_stats s ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
	--LEFT JOIN  sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ps ON ps.[object_id] = s.[object_id] AND ps.index_id = s.index_id

	 LEFT JOIN  (select * from (select object_id,index_id,avg_fragmentation_in_percent,   ROW_NUMBER() OVER (PARTITION BY object_id, index_id ORDER BY avg_fragmentation_in_percent DESC) AS RowNum
      from   sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) 	) a where RowNum = 1  ) as ps  ON ps.[object_id] = s.[object_id] AND ps.index_id = s.index_id
	--LEFT JOIN  sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id

	WHERE 
		 OBJECTPROPERTY(i.[object_id],'IsUserTable') = 1 
		 and i.type_desc not in('CLUSTERED','HEAP') 
		 and   i.is_primary_key  = 0 
		-- and OBJECT_NAME(i.OBJECT_ID)  = 'table' 
		 --AND i.name =	    'column'



), index_size AS (
	
	
	    
	SELECT
		i.OBJECT_ID,
		OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
		OBJECT_NAME(i.OBJECT_ID) AS TableName,
		i.name AS IndexName,
		i.is_primary_key ,
		i.index_id,
		8 * SUM(a.used_pages) AS 'Indexsize(KB)'
	FROM sys.indexes AS i
		left JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
		left JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
	where i.name is not null and i.is_primary_key  = 0 and OBJECTPROPERTY(i.object_id,'IsUserTable') = 1 
		and  i.type_desc not in('CLUSTERED','HEAP')
	GROUP BY i.OBJECT_ID,i.index_id,i.name, i.is_primary_key  
	 


),alltable AS  (

	select  nombreTabla, 
			esquema,
			object_id	,
			sum(rows) rows ,
			sum(EspacioTotalMB) EspacioTotalMB ,	
			sum(EspacioUsadoMB) EspacioUsadoMB,
			sum(EspacioNoUsadoMB) EspacioNoUsadoMB,
			FilePathDB,	
			letra  
	from 
		(SELECT 
			t.name AS nombreTabla,
			t.object_id,
			s.name AS esquema,
			p.rows,
			CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2))  AS EspacioTotalMB,
		   CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS EspacioUsadoMB, 
		   CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS EspacioNoUsadoMB,

			mf.physical_name AS FilePathDB,
			LEFT(mf.physical_name, 1) letra 

		FROM 
			sys.tables t
		INNER JOIN      
			sys.indexes i ON t.object_id = i.object_id
		INNER JOIN 
			sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
		INNER JOIN 
			sys.allocation_units a ON p.partition_id = a.container_id
		LEFT OUTER JOIN 
			sys.schemas s ON t.schema_id = s.schema_id
		LEFT OUTER JOIN 
			sys.master_files mf ON mf.database_id = DB_ID() AND mf.type_desc = 'ROWS'


		WHERE 
			--t.is_ms_shipped = 0
			OBJECTPROPERTY(t.object_id,'IsUserTable') = 1
		--	and p.partition_number = 1 --- solo deja las tabla principal , no agrega las particiones 
		GROUP BY 
			t.name, s.name, p.rows , mf.physical_name ,t.object_id
		)a  group  by nombreTabla,	esquema,	 FilePathDB,	letra , object_id 

), tb_cnt_index AS (

	select OBJECT_ID,count(*) cnt_index from 
		 (select 
			i.OBJECT_ID, 
			i.index_id,
			OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
			OBJECT_NAME(i.OBJECT_ID) tablename,  
			COL_NAME(ic.object_id, ic.column_id) AS ColumnName  ,
			i.name AS [Index_Name],
			i.type_desc  
	from sys.indexes  i
		 LEFT JOIN  sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	where  
		   i.type_desc not in('CLUSTERED','HEAP')   
		   and OBJECTPROPERTY(i.object_id,'IsUserTable') = 1 -- /* con esto excluye las tablas del sistema */
		   and  i.is_primary_key  = 0  ) a
	group by OBJECT_ID
)


select 
     db_name() db,
	 a.SchemaName,
	 a.OBJECT_ID,	
	 a.tablename,
	 cnt_index,
	 b.rows,
	 b.EspacioTotalMB,
	 b.EspacioUsadoMB,
	 b.EspacioNoUsadoMB,
	 a.ColumnName,
	 a.Index_Name,
	 --a.index_id,
	 a.type_desc,
	 D.user_seeks,
	 D.user_scans,
	 D.user_lookups,
	 D.user_updates,
	 D.Fragmentacion_Porcentaje,
 	 C.[Indexsize(KB)]
from allindex a 
LEFT JOIN alltable B 		ON   a.OBJECT_ID =  b.OBJECT_ID
LEFT JOIN tb_cnt_index E	ON   a.OBJECT_ID =  E.OBJECT_ID  
LEFT JOIN index_size C 		ON   a.OBJECT_ID =  C.OBJECT_ID AND C.index_id = a.index_id
LEFT JOIN index_stat D 		ON   a.OBJECT_ID =  D.OBJECT_ID AND D.index_id = a.index_id

ORDER BY  D.user_seeks ASC, D.user_scans ASC , D.user_lookups ASC,  D.user_updates  ASC 
   

   
   

```



###  saber los update,delete, insert de una tabla 
```sql



SELECT
	db_name (a.database_id),
    OBJECT_NAME(a.object_id) AS Nombre_Tabla,
	index_type_desc,
   leaf_insert_count AS Total_Inserts,
   leaf_delete_count AS Total_Updates,
   leaf_update_count AS Total_Deletes
   ,ps.avg_fragmentation_in_percent AS Fragmentacion_Porcentaje
 
FROM 
    sys.dm_db_index_operational_stats(DB_id(), NULL, NULL, NULL) a
LEFT JOIN  sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ps ON ps.[object_id] = a.[object_id] AND ps.index_id = a.index_id
	where    OBJECT_NAME(a.object_id) = 'ropa'
group by  a.database_id , a.object_id , leaf_insert_count , leaf_delete_count  , leaf_update_count   ,ps.avg_fragmentation_in_percent ,	index_type_desc
```

# ver espacio de log de transacciones 
```
SELECT 
    DB_NAME(database_id) AS database_name,
    total_log_size_in_bytes / 1024.0 / 1024.0 AS total_log_size_in_mb,
    used_log_space_in_bytes / 1024.0 / 1024.0 AS used_log_space_in_mb,
    used_log_space_in_percent,
    reserved_log_space_for_internal_use_in_bytes / 1024.0 / 1024.0 AS reserved_log_space_for_internal_use_in_mb,
    log_space_in_use_since_last_backup_in_bytes / 1024.0 / 1024.0 AS log_space_in_use_since_last_backup_in_mb
FROM sys.dm_db_log_space_usage;
```


# waiting tasks
Cuando una tarea está en espera, significa que está esperando algún recurso para poder continuar su ejecución. Estas esperas pueden ser causadas por varios factores, como bloqueos, falta de memoria, E/S en disco, y otros recursos del sistema.

```sql

LOCK_XX: Esperas relacionadas con bloqueos (locks). Ocurren cuando una transacción está esperando para obtener un bloqueo en un recurso que ya está bloqueado por otra transacción.

LATCH_XX: Esperas relacionadas con los pestillos (latches). Ocurren cuando una tarea está esperando a que se libere un pestillo en la memoria.

PAGEIOLATCH_XX: Esperas relacionadas con la E/S de páginas. Ocurren cuando una tarea está esperando que una página sea leída desde el disco a la memoria.

NETWORK_IO: Esperas relacionadas con la red. Ocurren cuando una tarea está esperando para enviar o recibir datos a través de la red.

ASYNC_NETWORK_IO: Esperas asíncronas relacionadas con la red. Ocurren cuando el servidor está esperando a que el cliente lea los datos enviados.


SELECT wait_type, SUM(wait_time_ms) AS total_wait_time_ms,
       SUM(waiting_tasks_count) AS total_waiting_tasks,
       SUM(wait_time_ms) / SUM(waiting_tasks_count) AS avg_wait_time_ms
FROM sys.dm_os_wait_stats
GROUP BY wait_type
ORDER BY total_wait_time_ms DESC;



SELECT wait_type, wait_time_ms, wait_time_ms / waiting_tasks_count AS avg_wait_time_ms, waiting_tasks_count
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC;

```

# Crecimiento de espacio del LDF 
información crucial sobre por qué el espacio en el archivo de registro de transacciones no se puede reutilizar. identificar y solucionar problemas relacionados con el crecimiento del registro de transacciones. 

Acciones Correctivas
Dependiendo del valor de log_reuse_wait_desc, aquí hay algunas acciones que podrías tomar:

**`CHECKPOINT:`**  Ejecuta manualmente un CHECKPOINT en la base de datos si es necesario. <br>
**`LOG_BACKUP:`**  Realiza un backup del registro de transacciones.<br>
**`ACTIVE_TRANSACTION:`**  Asegúrate de que las transacciones largas se completen lo antes posible.<br>
**`REPLICATION:`**  Verifica que la replicación esté funcionando correctamente y que no haya problemas de retraso.<br>
**`AVAILABILITY_REPLICA:`** Revisa el estado de las réplicas de disponibilidad y soluciona cualquier problema de sincronización.<br>


```SQL

SELECT 
    name AS database_name,
    log_reuse_wait_desc
FROM sys.databases;

/******** Valores Comunes de log_reuse_wait_desc *************\

NOTHING: No hay nada que impida la reutilización del espacio del registro de transacciones.

CHECKPOINT: El espacio no puede ser reutilizado porque el último punto de control no ha sido escrito. Un punto de control asegura que todas las páginas sucias han sido escritas al disco y que las entradas de registro necesarias están en el disco.

LOG_BACKUP: El espacio no puede ser reutilizado porque no se ha realizado un backup del registro de transacciones. En el modelo de recuperación completa, el registro debe ser respaldado periódicamente para liberar espacio.

ACTIVE_BACKUP_OR_RESTORE: El espacio no puede ser reutilizado porque hay una operación de backup o restauración en progreso.

ACTIVE_TRANSACTION: El espacio no puede ser reutilizado porque hay transacciones activas. Las transacciones deben completarse para que el espacio pueda ser reutilizado.

DATABASE_MIRRORING: El espacio no puede ser reutilizado debido a la replicación de la base de datos. Esto sucede cuando la replicación no está al día.

REPLICATION: El espacio no puede ser reutilizado debido a la replicación transaccional. Esto ocurre cuando los registros no han sido entregados a todos los suscriptores.

AVAILABILITY_REPLICA: El espacio no puede ser reutilizado porque la réplica de disponibilidad en un grupo de disponibilidad AlwaysOn no está sincronizada.

OTHER_TRANSIENT: Otras razones transitorias que no caen en las categorías anteriores.



```


# hacer pruebas de performance  : 

```sql
Descarga : https://learn.microsoft.com/es-es/troubleshoot/sql/tools/replay-markup-language-utility 

OStress: Es una herramienta proporcionada por Microsoft para realizar pruebas de estrés en SQL Server. Esta herramienta permite ejecutar múltiples sesiones y simular una carga alta en el servidor de bases de datos, lo que es útil para pruebas de rendimiento y estabilidad.


stress -S servidor_sql -d base_de_datos -Q "SELECT * FROM tabla" -n 10 -r 5

-S servidor_sql especifica el nombre del servidor SQL.
-d base_de_datos especifica la base de datos a la que te estás conectando.
-Q "SELECT * FROM tabla" es la consulta SQL que quieres ejecutar.
-n 10 especifica el número de conexiones concurrentes.
-r 5 especifica el número de repeticiones para cada consulta.



```


#  Optimización TEMPDB
https://blogs.triggerdb.com/2022/12/27/sql-2022-optimizacion-tempdb/

```sql
/********* PARA HABILITAR LA OPTIMIZACION DE TMP DB ************/
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA=ON;

SELECT SERVERPROPERTY('IsTempDBMetadataMemoryOptimized') AS IsTempDBMetadataMemoryOptimized;

bibliogafías :
https://blogs.triggerdb.com/2022/12/27/sql-2022-optimizacion-tempdb/
https://www.mssqltips.com/sqlservertip/6230/memoryoptimized-tempdb-metadata-in-sql-server-2019/


```


 # comandos DBCC
```sql
DBCC DROPCLEANBUFFERS;
Este comando se utiliza para eliminar los buffers limpios del caché de la base de datos. Los buffers limpios son aquellos que han sido leídos desde el disco pero no han sido modificados. Utilizar este comando es útil para pruebas de rendimiento, ya que garantiza que los datos se leerán desde el disco en lugar del caché.

DBCC FREESYSTEMCACHE ('ALL');
Este comando libera toda la memoria del caché del sistema. El caché del sistema incluye caché de planes de consulta, caché de procedimientos almacenados, caché de objetos de usuario y otras estructuras de caché del sistema. Es útil para liberar memoria y resolver problemas de rendimiento relacionados con el uso excesivo de caché del sistema.


DBCC FREEPROCCACHE;
Este comando elimina todos los planes de ejecución almacenados en la caché de procedimientos. Esto puede ser útil si se han realizado cambios significativos en las bases de datos o en el esquema y se desea forzar la recompilación de todos los procedimientos y consultas la próxima vez que se ejecuten. Es útil para problemas de rendimiento relacionados con planes de consulta obsoletos.


DBCC FREESESSIONCACHE;
Este comando libera el caché de sesión, que almacena información sobre las sesiones actuales y sus contextos. Al liberar este caché, se pueden resolver problemas relacionados con sesiones persistentes que ocupan demasiada memoria.
```



 # Query Store 
Disponible desde SQL Server 2016 , Recopila y almacena información detallada sobre el rendimiento de las consultas, Planes de ejecución de las consultas, Estadísticas de rendimiento, Historial de consultas proporcionando una visión histórica del comportamiento de las consultas, sus planes de ejecución y sus tiempos de ejecución.   poderosa para el monitoreo, análisis y optimización del rendimiento de las consultas en SQL Server. <br> <br>

Los **"hints"** en SQL Server son indicaciones o forzar  que se le pueden dar al optimizador de consultas para influir en cómo se ejecuta una consulta. por ejemplo le podemos decir que una consulta no utilice paralelismo 
```sql
ALTER DATABASE [NombreBaseDatos]  SET QUERY_STORE CREAR;
ALTER DATABASE [NombreBaseDatos]  SET QUERY_STORE = ON;
ALTER DATABASE [NombreBaseDatos]  SET QUERY_STORE = (OPERATION_MODE = READ_WRITE);


Consultas y Análisis:
SELECT * FROM sys.query_store_runtime_stats;
SELECT * FROM sys.query_store_plan -- WHERE is_forced_plan = 1;;
SELECT * FROM sys.query_store_query;
SELECT * FROM sys.query_store_text;
SELECT * FROM sys.query_store_hints;

SELECT query_id, plan_id, runtime_stats_id, last_execution_time
FROM sys.query_store_query
JOIN sys.query_store_plan
ON sys.query_store_query.query_id = sys.query_store_plan.query_id
ORDER BY last_execution_time DESC;


EXEC sp_query_store_force_plan @query_id = [QueryID], @plan_id = [PlanID];
EXEC sp_query_store_unforce_plan @query_id = 123, @plan_id = 456;

#################################  hints  #################################

Ejemplo optimizar de manera manual:
SELECT *  FROM MiTabla  OPTION (MAXDOP 1);

EXEC sp_query_store_set_hints 
    @query_id = 123, 
    @query_hints = 'OPTION (FORCESEEK)';

EXEC sp_query_store_clear_hints @query_id = 123;

```




# Bibliografías : 
https://blog.sqlauthority.com/2023/10/06/sql-server-maintenance-techniques-a-comprehensive-guide-to-keeping-your-server-running-smoothly/ <br> 
monitorear: https://sqlperformance.com/2015/03/io-subsystem/monitoring-read-write-latency
