
### Archivos 
En esta ruta por default sql server guarda sus log -->  C:/programFiles/Microsoft SQL Server /MSSQL13.MSSQLSERVER/MSSQL/LOG

```
/******** ARCHIVOS QUE GUARDA Y PROPISITO  ********/

fd.# --- es un archivo que se genera cuando se producen errores relacionados con el servicio Full-Text Search
FDLAUNCHERRORLOG --  guarda error al intentar cargar o iniciar la funcionalidad Full-Text Search (Búsqueda de texto completo). Este archivo suele contener información detallada sobre los errores específicos relacionados con el motor de búsqueda de texto completo de SQL Server,  Full-Text Search  permite realizar búsquedas eficientes dentro de texto almacenado en columnas de tipo nvarchar, varchar y otros tipos de datos de texto. 

---- Estos son Event Session ------  Te permitirá monitorear de manera efectiva el rendimiento, diagnosticar problemas y mejorar la eficiencia de tus bases de datos SQL Server.
ManagedBackupEvent_backup_####.xel
system_health_####.xel
HKEngineEventFile_####.xel 

ERRORLOG.#  -- Captura error de sql server
SQLAGENT.OUT -- captura error relacionados con los agentes que son los JOB
LOG.TRC  --- captura la informacion de tracer

```


# Usando el Visor de Eventos:
```
Presiona Win + R, escribe eventvwr.msc y presiona Enter. Esto abrirá el Visor de Eventos.
- Los eventos relacionados con SQL Server podrían estar en los registros de Aplicación o Seguridad.
```

# Verificar errores
**xp_readerrorlog** se utiliza para leer los archivos de registro de errores de SQL Server. Estos archivos de registro almacenan información detallada sobre eventos, mensajes de error, advertencias
```
xp_readerrorlog 0, 1, N'Logging SQL Server messages in file', NULL, NULL, N'asc'

****** Especificar un número de archivo de registro: ********
EXEC sp_readerrorlog 0, 1


****** Aplicar filtros de búsqueda: ******
EXEC sp_readerrorlog 0, 1, 'error'
EXEC sp_readerrorlog 0, 1, 'Login failed'
EXEC sp_readerrorlog 0, 1, 'Error: 18456' -- problemas de inicio de sesión.
EXEC sp_readerrorlog 0, 1, 'Backup' -- problemas o confirmar si las copias de seguridad se están realizando correctamente. 
EXEC sp_readerrorlog 0, 1, 'DatabaseName' --  experimentando problemas con una base de datos  
EXEC sp_readerrorlog 0, 1, 'Restore' --  identificar eventos de restauración de base de datos
EXEC sp_readerrorlog 0, 1, 'I/O' --  identificar eventos relacionados con problemas de E/S (entrada/salida), lo que puede ser útil para problemas de rendimiento o de disco.



****** Filtrar por fecha: ****** 
EXEC sp_readerrorlog 0, 1, '2023-01-01', '2023-12-31'


```



**Proporciona información sobre todos los mensajes de error del sistema en la base de datos actual.**
```
SELECT * FROM sys.messages WHERE language_id = 1033;
```

# funciones para validar errores  con TRY  - CATCH

```
BEGIN TRY
    -- Generar un error intencional
    SELECT 1/0;
END TRY
BEGIN CATCH
    -- Manejar el error
    SELECT ERROR_STATE(); -- Devuelve el estado de error del último error que ocurrió. 
    SELECT ERROR_SEVERITY();  -- Devuelve el nivel de gravedad del último error que ocurrió. 
    SELECT ERROR_NUMBER(); --  Devuelve el número de error del último error que ocurrió. Puede ser útil para identificar el código de error específico.
    SELECT ERROR_MESSAGE();  -- devuelve el mensaje de error asociado con el error más reciente. Es útil cuando estás en un bloque CATCH 
END CATCH;
```

# Examinar el log de transacciones
```SQL
  select  
		 [Current LSN]
       ,[Previous LSN]
       ,[Operation]
       ,[Context]
       ,[Transaction ID]
       ,[Log Record Length]
       ,[AllocUnitName]
       ,[Page ID]
       ,[SPID]
       ,[Xact ID]
       ,[Begin Time]
       ,[End Time]
       ,[Transaction Name]
       ,[Transaction SID]
       ,[Parent Transaction ID]
       ,[Transaction Begin]
       ,[Number of Locks]
       ,[Lock Information]
       ,[Description]
       ,[Log Record]  
from  fn_dblog(NULL, NULL) 
WHERE    ( CAST([Begin Time] AS DATETIME) BETWEEN  '20230810 11:40:00' and  '20230810 11:45:00' )
or  
CAST([End Time] AS DATETIME) BETWEEN  '20230810 11:40:00' and  '20230810 11:45:00'
--where   [Transaction ID] =  '0000:000004c4' ---  LOP_MODIFY_ROW  --- '0000:000004c4' LOP_INSERT_ROWS 

/*
Operation: 
LOP_BEGIN_XACT y LOP_COMMIT_XACT = Inicio y final de transacción
LOP_MODIFY_ROW = indica que se modifico un registro 
*/


DBCC INPUTBUFFER (629117)  

 SELECT object_name(object_id) AS name, object_id
 ,index_id ,allocation_unit_id
 FROM sys.allocation_units AS au
 INNER JOIN sys.partitions AS p
 ON au.container_id = p.hobt_id
 AND (au.type = 1 OR au.type = 3)
 where allocation_unit_id='72057594047954944'
  
DBCC OPENTRAN();

 https://www.gpsos.es/2019/11/fn_dblog-como-analizar-transactional-log-en-sql-server/
 https://blog.coeo.com/inside-the-transaction-log-file

 DBCC TRACEON(3604)
 DBCC IND(dba_test, 'Empleados', 1)
 DBCC PAGE('dba_test', 1, 228, 3)



```



### Validar el log de instalación 

Dentro de esta ruta encontraras carpetas, abre la mas actual ayudate con la fecha de creacion, los archivos importantes son <br>
**details.txt** aqui te va aparecer el detallado de todo lo que quiso intealar y marco error <br>
**summary_.txt**   aqui después del "_" apareceneran números, y te sirve el archivo las especificaciones de la instalación y algunos errores  <br>
C:\Program Files\Microsoft SQL Server\110\Setup Bootstrap\Log

<br>**Palabras Clave Comunes que te ayudan a indentificar el problema**
```sql

"Error": Esto te ayudará a identificar cualquier mensaje de error general.
"Failed": Indica operaciones que han fallado.
"Warning": Señala advertencias que podrían estar relacionadas con el problema.
"Exception": Para detectar excepciones que puedan haber ocurrido durante la instalación.
"Return value 3": Específico de los logs de MSI (Microsoft Installer), indica un error en la instalación.
"Configuration failure": Para identificar fallos en la configuración.
"Access denied": Problemas de permisos o acceso.
"Unable to": Seguido por la acción que no se pudo completar.
"Missing": Para detectar componentes o archivos faltantes.
"Fatal": Para identificar errores críticos que impiden la instalación.
"Timeout": Problemas relacionados con tiempos de espera agotados.
"Rollback": Indica que se ha revertido una acción debido a un fallo.
"Path not found": Problemas relacionados con rutas de archivos o directorios no encontrados.


```



 EXEC xp_logininfo '[sysappdynamics]', 'all'
