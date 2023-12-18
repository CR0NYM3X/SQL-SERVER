# Objetivo:
Monitorear las base de datos detectar posibles bloqueos, lentitud y intentar solucionar el detalle que se presente

# Procedimientos almacenados para monitorear 


- Monitoreo de Actividad y Rendimiento:<br>
**`sp_who`** <br>
**`sp_who2:`** Proporciona información sobre usuarios activos, conexiones y bloqueos. <br>
**`sp_Who3`** <br>
**`sp_whoisactive:`** Ofrece una visión detallada de la actividad actual, incluyendo detalles de bloqueos, consultas en ejecución,  Provee detalles sobre sesiones activas, bloqueos y recursos utilizados por las consultas. <br>


- Monitoreo de Espacio en Disco:<br>
**`sp_spaceused:`** Muestra el espacio utilizado por una base de datos en particular. <br>
**`sp_helpdb:`** Proporciona información detallada sobre todas las bases de datos. <br>

- Monitorización del Plan de Mantenimiento:<br>
**`sp_help_job`** -- este proc se ejecuta en la msdb y Muestra información sobre trabajos de SQL Server Agent.


# tablas y vistas útiles para monitorear
**`sys.sysindexes`** 
**`sys.dm_exec_connections:`** Detalles de las conexiones activas al servidor. <br>
**`sys.dm_exec_requests:`** Proporciona información sobre las solicitudes actuales en ejecución en el servidor. <br>
**`sys.dm_exec_sessions:`** Contiene información sobre las sesiones actuales en el servidor, lo que puede ser útil para rastrear quién está conectado y qué están haciendo. <br>
**`sys.sysprocesses`**  detalles sobre las sesiones que estaban conectadas al servidor en un momento dado, incluyendo información sobre ID de sesión, estado de la sesión, tiempo de CPU utilizado, ID de usuario<br>
**`sys.dm_exec_query_stats:`** Estadísticas de ejecución de consultas. <br>
**`sys.dm_os_wait_stats:`** Ofrece estadísticas sobre los tipos de espera que están afectando el rendimiento del servidor. <br>
**`sys.stats:`** almacena información sobre las estadísticas de las columnas de las tablas de la base de datos<br>
**`sys.dm_db_partition_stats`** almacenamiento y la distribución de las filas y páginas de datos de una tabla o índice en una base de datos.<br>
**`sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL)`**  detallada sobre la fragmentación y la distribución física de los índices de una base de datos.<br>
**`sys.dm_io_virtual_file_stats:`** Proporciona estadísticas de E/S a nivel de archivo, lo que es esencial para monitorear la actividad de E/S en el servidor. <br>
**`sys.dm_db_index_physical_stats:`** Ofrece información detallada sobre el estado físico de los índices, lo que puede ser útil para identificar problemas de rendimiento relacionados con los índices. y ver si necesita una desfragmentacion <br>
**`sys.dm_os_sys_info:`** Contiene información sobre la configuración del sistema y los recursos del servidor. <br>
**`sys.dm_os_buffer_descriptors:`** Proporciona información sobre los bloques de memoria que se están utilizando actualmente en la memoria caché del búfer. <br>
**`sys.dm_os_ring_buffers:`** Registros de eventos del sistema. <br>
**`sys.dm_os_tasks:`** Detalles de las tareas en el sistema operativo. <br>
**`sys.dm_os_memory_clerks:`** Detalles sobre la asignación de memoria. <br>
**`sys.dm_db_missing_index_details:`** Información sobre índices faltantes. <br>
**`sys.dm_os_loaded_modules:`** Módulos cargados en SQL Server. <br>
**`sys.dm_tran_locks:`** Información sobre bloqueos actuales. <br>
**`sys.dm_server_services:`** Detalles sobre los servicios de SQL Server en la máquina. <br>
**`sys.dm_os_schedulers:`** Información sobre los programadores (schedulers) del sistema. <br>
**`sys.dm_os_performance_counters:`** Ofrece información sobre contadores de rendimiento de SQL Server que pueden ser cruciales para monitorear el rendimiento general del servidor.  <br>
**`sys.dm_db_index_usage_stats`** mantiene estadísticas sobre la actividad de los índices, como cuándo se han utilizado por última vez, cuántas operaciones de lectura y escritura han realizado
**`sys.dm_os_waiting_tasks`** Esta vista es fundamental para identificar cuellos de botella, bloqueos y problemas de rendimiento en el servidor SQL Server.


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

Este comando actualiza las páginas de asignación de espacio de la base de datos actual. Asegura que la información de espacio utilizada se actualice correctamente para cada tabla.
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

###
```
 

```
