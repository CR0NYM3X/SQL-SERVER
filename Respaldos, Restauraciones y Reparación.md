# Objetivo:
Aprender hacer respaldos y restaurar la información de una base de datos, para prevenir tragedias 


# Herramientas que se usan :
Esta es la ruta de donde se encuentran las herramientas que se van usar , dependiendo de la version que tienes instalada, por ejemplo en este caso yo tengo la 130 y uso esta ruta <br>

**C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn**

**BCP.exe**  (Bulk Copy Program) Es una herramienta que sirve para Importar y exportar datos en un archivo de windows, tambien sirve para restaurar la información <br>
```
usage: bcp {dbtable | query} {in | out | queryout | format} datafile
  [-m maxerrors]            [-f formatfile]          [-e errfile]
  [-F firstrow]             [-L lastrow]             [-b batchsize]
  [-n native type]          [-c character type]      [-w wide character type]
  [-N keep non-text native] [-V file format version] [-q quoted identifier]
  [-C code page specifier]  [-t field terminator]    [-r row terminator]
  [-i inputfile]            [-o outfile]             [-a packetsize]
  [-S server name]          [-U username]            [-P password]
  [-T trusted connection]   [-v version]             [-R regional enable]
  [-k keep null values]     [-E keep identity values]
  [-h "load hints"]         [-x generate xml format file]
  [-d database name]
```

**SQLCMD.exe / OSQL.exe** (Structured Query Language  Command-line) Es una herramienta de línea de comandos que permite ejecutar scripts de Transact-SQL (T-SQL) y comandos SQL en instancias de SQL Server.
```
Microsoft (R) SQL Server Command Line Tool
Version 10.50.6000.34 NT x64
Copyright (c) Microsoft Corporation.  All rights reserved.

usage: Sqlcmd            [-U login id]          [-P password]
  [-S server]            [-H hostname]          [-E trusted connection]
  [-N Encrypt Connection][-C Trust Server Certificate]
  [-d use database name] [-l login timeout]     [-t query timeout]
  [-h headers]           [-s colseparator]      [-w screen width]
  [-a packetsize]        [-e echo input]        [-I Enable Quoted Identifiers]
  [-c cmdend]            [-L[c] list servers[clean output]]
  [-q "cmdline query"]   [-Q "cmdline query" and exit]
  [-m errorlevel]        [-V severitylevel]     [-W remove trailing spaces]
  [-u unicode output]    [-r[0|1] msgs to stderr]
  [-i inputfile]         [-o outputfile]        [-z new password]
  [-f <codepage> | i:<codepage>[,o:<codepage>]] [-Z new password and exit]
  [-k[1|2] remove[replace] control characters]
  [-y variable length type display width]
  [-Y fixed length type display width]
  [-p[1] print statistics[colon format]]
  [-R use client regional setting]
  [-b On error batch abort]
  [-v var = "value"...]  [-A dedicated admin connection]
  [-X[1] disable commands, startup script, enviroment variables [and exit]]
  [-x disable variable substitution]
  [-? show syntax summary]
```


# Tipos de respaldos 
Respaldos incrementales <br> 
Respaldos completos <br>
Respaldos solo de data <br>



# Ejemplos de uso:

# Obtener la estructura de los objetos de una la base de datos
![dba-struc-obj-sql](https://github.com/CR0NYM3X/SQL-SERVER/blob/main/img/estructra_objetos_db.png)

# Obtener la estructura de la base de datos
![dba-struc-sql](https://github.com/CR0NYM3X/SQL-SERVER/blob/main/img/estructura_de_dba.png)

# Ambientación 
Pasar tablas de un servidor SQL Server  a otro SQL Server  desde SQL  management studio
![ambiente-sql](https://github.com/CR0NYM3X/SQL-SERVER/blob/main/img/ambientaci%C3%B3n.jpg)


### Exportar toda la información de una tabla en un archivo csv y volverla a importar

**1.- Hacer CHECKPOINT en la base de datos :** <br> 
```sql
/* ******* HACER CHECKPOINT DE MANERA MANUAL ******* */
use  MY_DDBA_TEST 
CHECKPOINT

/* ******* HACER CHECKPOINT DE MANERA AUTOMATICA ******* */
EXEC sp_configure 'recovery interval', '3000' /*Segundos*/;
RECONFIGURE with override;

```
 **`"CHECKPOINT"`** Piensa en una base de datos como un gran almacén de información. Cuando guardamos cosas en ese almacén, a veces las dejamos en mesas temporales (la memoria/Buffer cache) para poder trabajar más rápido con ellas. Pero, ¿qué pasa si se corta la luz o pasa algo que haga que perdamos esas cosas temporales.
 
 <br> Aquí es donde entra el "checkpoint". Imagina que cada cierto tiempo, alguien toma lo que está en esas mesas temporales y las coloca en cajas bien guardadas (los discos duros). Eso es el checkpoint, asegurarse de que la información que estaba en mesas temporales se guarde en un lugar seguro.

<br> Ahora, ¿qué es la paginación? Piensa en la paginación como un libro enorme. A veces, cuando leemos, no leemos todo el libro de una vez, sino que vamos página por página. En las bases de datos, cuando almacenamos mucha información, a veces no la guardamos toda al mismo tiempo, sino que la dividimos en "páginas" para poder leer y escribir más rápido.

<br> Cuando se realizan modificaciones en la base de datos, como agregar, modificar o eliminar registros, estas modificaciones se realizan en la memoria en un principio, y no directamente en el disco. SQL Server mantiene estas modificaciones en memoria, en lo que se conoce como caché de páginas, para mejorar el rendimiento y minimizar la escritura constante en el disco, que es más lenta en comparación con la memoria.
 
 ********* **Ventajas** *************
 
 **Respaldos y recuperación:** Antes de realizar un respaldo (backup) completo de una base de datos, ejecutar un CHECKPOINT garantiza que todos los cambios realizados en la memoria se escriban en disco. Esto ayuda a asegurar que el respaldo refleje la última versión consistente de la base de datos.<br>
 
 **Mantenimiento y optimización del rendimiento:** En situaciones en las que hay una gran cantidad de transacciones realizadas en una base de datos, ejecutar CHECKPOINT periódicamente puede liberar recursos y mejorar el rendimiento al reducir la cantidad de datos transitorios en la memoria. <br>
 
 **Recuperación tras un fallo:** Después de un reinicio inesperado del servidor o una interrupción, un CHECKPOINT ayuda a minimizar la cantidad de transacciones no escritas en disco, lo que facilita una recuperación más rápida y reduce la posibilidad de pérdida de datos <br> 


**2.- Exportar la informacion con bcp**
en estos casos no se puede exportar con el encabezado

> [!CAUTION]
> **`[NOTA IMPORTANTE] --->`** esta operacion no bloquea las tablas por lo que puedes ir utilizando la tabla mientras realiza la exportacion de la info y  Se recomienda utilizar delimitadores diferente a la comilla,  ya que si la tabla que vas exportar tiene campos varchar puede tener comillas dentro de la columna y esto puede entorpecer al momento de importar la información ,por ejemplo yo uso "|"
```
--- Exportando toda la tabla
bcp my_dba_test.dbo.my_tabla_test out "C:\my_tabla_test.csv" -S 192.168.10.50 -T -t "," -c  -r\n

--- Exportando con condicional en la tabla
bcp "select * from my_tabla_test where nombre='jose' " queryout  "C:\my_tabla_test.csv" -S 192.168.10.50 -T -t "|" -c  -r "\n" -d new_dba_test2
```

**Exportar la informacion con sqlcmd**
```
sqlcmd -S servidor -d base_de_datos -Q "SELECT * FROM mi_tabla WHERE condicion_campo = 'valor'" -o salida_temporal.txt -h-1 -s"," -W
```

**3.- Importar la información con bcp**


> [!CAUTION]
> **`[NOTA IMPORTANTE] --->`** Esto bloqua las tablas por lo que no permite hacer lectura de la tabla a la que se esta  haciendo insertando la info, el espacio usado del log transaccional se va llenando y aumenta rapidamente, por lo que si el log transaccional llega a su limite de espacio, puede tener problemas para copiar la información, para ir monitoreando el tamaño utilizado,   [ingresa a este link, para ver la query que  monitorea el espacio usado del log transaccional](https://github.com/CR0NYM3X/SQL-SERVER/blob/main/Base%20de%20datos.md#saber-el-tama%C3%B1o-utilizado-de-los-archivos-mdf-ndf-y-ldf), una vez terminado el copiado, el espacio usado de log empieza a disminur, para validar si se esta insertando la información, lo validamos con el procedimiento sp_who2 en donde el campo status estara en RUNNABLE  y campo command estara en BULK INSERT 

 

```
bcp  my_dba_test.dbo.my_tabla_test in  "C:\my_tabla_test.csv" -S 192.168.10.50 -T -t "|" -c  -r\n -F 2

-- El parametro -F 2 le indica al programa que inicie desde la linea 2 y no desde la primera linea,
esto sirve para cuando el documento tiene el encabezado de cada columna, aunque el BCP en automatico puede salta el encabezado 
```

**Importar la información con bulk insert**
```
BULK INSERT my_tabla_test
FROM 'C:\my_tabla_test.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1 --- si tiene encabezado ponle el numero 2
);

```



###  hacer un respaldo de una base de datos  y realizar la restauración
[documentacion de backups](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-full-database-backup-sql-server?view=sql-server-ver16)
**hacer respaldo**
```
******* QUERY BACKUP COMPLETO *******
USE [master]
BACKUP DATABASE [MY_DBA_TEST]  ---- BACKUP LOG database_name 
TO  DISK = N'C:\respaldo_nuevo_completo.bak' 
WITH NOFORMAT, NOINIT, NAME = N'new_dba_test2-Full Database Backup',SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

******* QUERY BACKUP COMPLETO, PERO DIVIDIDO EN ARCHIVOS *******
USE [master]
BACKUP DATABASE [MY_DBA_TEST]
TO  DISK = N'C:\respaldo_nuevo_1.bak',
    DISK = N'C:\respaldo_nuevo_2.bak',
    DISK = N'C:\respaldo_nuevo_3.bak' 
WITH NOFORMAT, NOINIT, NAME = N'new_dba_test2-Full Database Backup',SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

******* PARÁMETROS *******
WITH NOFORMAT, NOINIT

WITH FORMAT --- Se eliminarán los conjuntos de respaldo anteriores
WITH INIT   --- Permite sobrescribir el contenido de los medios de respaldo existentes sin necesariamente eliminar la información sobre backups anteriores.
WITH DIFFERENTIAL --- especifica que el backup contiene solo las diferencias desde el último backup completo.
STATS = 10 -- Se utiliza para especificar la frecuencia con la que se mostrarán los mensajes de progreso durante la operación de backup
NOUNLOAD -- se utiliza para evitar la descarga (unload) automática del conjunto de medios de respaldo después de una operación de backup.
NOREWIND -- se indica que el conjunto de medios de respaldo no debe rebobinarse después de la operación de backup
SKIP -- se utiliza para saltar los dispositivos de respaldo que ya están abiertos.
RETAINDAYS = 11 --- colocar dias de expiracion 
EXPIREDATE = N'12/01/2023 00:00:00'  -- colocar fecha de expiracion del respaldo
COMPRESSION --- comprimir el backup

```

**Restaurar base de datos**
```
******* QUERY BACKUP COMPLETO *******
USE [master]
RESTORE DATABASE [MY_DBA_TEST] FROM  
DISK =  N'C:\respaldo_nuevo_completo.bak'
WITH  FILE = 1,  NOUNLOAD,  STATS = 5, REPLACE -- REPLACE SE USA PARA CUANDO LA BASE DE DATOS YA EXISTE ENTONCES LA REMPLAZA
GO


******* QUERY RESTAURAR COMPLETO, PERO DE ARCHIVOS DIVIDIDO *******
USE [master]
RESTORE DATABASE [MY_DBA_TEST] FROM  
DISK =  N'C:\respaldo_nuevo_1.bak',  
DISK =  N'C:\respaldo_nuevo_2.bak', 
DISK =  N'C:\respaldo_nuevo_3.bak', 
WITH  FILE = 1,  NOUNLOAD,  STATS = 5, REPLACE -- REPLACE SE USA PARA CUANDO LA BASE DE DATOS YA EXISTE ENTONCES LA REMPLAZA
GO

```



# Reparación de una base de datos

**1.- Colocar modo Emergencia:** Esto lo que hace es que coloca la dba en solo lectura, SQL Server trata de realizar un 
chequeo de integridad de la base de datos y permite al administrador realizar ciertas acciones para intentar recuperar
la base de datos.
```
ALTER DATABASE new_dba_test24 SET EMERGENCY
```

**2.- Analiza la base de datos, para detectar errores:**
```
 DBCC CHECKDB (N'database_name') WITH ALL_ERRORMSGS, NO_INFOMSGS 
```
 
**Cambiar a modo Single_user** esto lo que hace es que los usuarios no va a poder modificar los datos, mientras la restauración está en curso.
```
ALTER DATABASE NombreDeLaBaseDeDatos SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
```

**3.- Reparar la base de datos**
Si viste que sí tiene errores, entonces ejecuta este comando
```
******* QUERY *******
DBCC CHECKDB('NombreDeLaBaseDeDatos', REPAIR_REBUILD);

******* OPCIONES DE PARÁMETROS *******
REPAIR_REBUILD :  Esta opción es la recomendada
REPAIR_ALLOW_DATA_LOSS : Esta opción puede eliminar algunas páginas de la base de datos. Por lo tanto, Microsoft no recomienda, en caso de ser muy necesario usar esta opción
```

**4.- Ver el Porcentaje de recovery**
```
EXEC sp_readerrorlog 0, 1, 'Recovery of database' 
```


**5.- Cambiar a modo Multi_user:** Esto hace que es que ya puedan tener acceso 
```
ALTER DATABASE [NombreDeLaBaseDeDatos] SET READ_WRITE;
ALTER DATABASE [NombreDeLaBaseDeDatos] SET MULTI_USER;
```



# Modificar el tipo de respaldo 

```SQL
/* CONSULTA COMO ESTAN LAS BASE DE DATOS */
 SELECT name, recovery_model_desc FROM sys.databases where database_id = DB_ID()

/* ---------- DESCRIPCIÓN MODO SIMPLE ----------
determina cómo se registran y almacenan las transacciones. El modo "Simple" es útil en situaciones donde
no se necesita un registro detallado de las transacciones y se prioriza el espacio en disco y el rendimiento
*/
ALTER DATABASE [my_dba_test] SET RECOVERY SIMPLE;

/* ----------  DESCRIPCIÓN MODO FULL  ----------
 se registran todas las operaciones de la base de datos en el archivo de registro de transacciones.
 Esto permite realizar copias de seguridad de registros de transacciones (log backups)
*/
ALTER DATABASE [my_dba_test] SET RECOVERY FULL;

/* ----------  DESCRIPCIÓN MODO BULK_LOGGED  ----------
es similar al modo completo, pero reduce el registro de ciertas operaciones masivas,
como las operaciones de carga masiva (bulk operations)
*/
ALTER DATABASE [my_dba_test] SET RECOVERY BULK_LOGGED 

```

# Ver la información de los respaldos realizados y donde se guardan
```SQL
SELECT 
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Nombre_Servidor, 
msdb.dbo.backupset.database_name Nombre_BD, 
msdb.dbo.backupset.backup_start_date Fecha_Inicio, 
msdb.dbo.backupset.backup_finish_date Fecha_Termino, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
When 'I' THEN 'Differential database'
END AS Tipo_Backup, 
msdb.dbo.backupset.backup_size/1024/1024/1024 Tamaño_Backup, 
msdb.dbo.backupmediafamily.physical_device_name Ruta_fisica, 
isnull(msdb.dbo.backupset.name, 'SN') AS Nombre_Backup
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
ORDER BY msdb.dbo.backupset.backup_finish_date desc

```

# ver la informacion a detalle de cada physical_device_name
```sql


CREATE TABLE #TempFileInfo (
    LogicalName NVARCHAR(max),
    PhysicalName NVARCHAR(max),
    [Type] CHAR(1),
    FileGroupName NVARCHAR(max),
    [Size] INT,
    MaxSize BIGINT, -- Cambiado a BIGINT
    FileId INT,
    CreateLSN DECIMAL(25,0),
    DropLSN DECIMAL(25,0),
    UniqueId UNIQUEIDENTIFIER,
    ReadOnlyLSN DECIMAL(25,0),
    ReadWriteLSN DECIMAL(25,0),
    BackupSizeInBytes BIGINT, -- Cambiado a BIGINT
    SourceBlockSize INT,
    FileGroupId INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN DECIMAL(25,0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32)
);
-- Insertar la información en la tabla temporal
INSERT INTO #TempFileInfo
EXEC('RESTORE FILELISTONLY FROM DISK=''0b82922f-421e-4125-be8a-d6249f971e63''');

-- Consulta para verificar los datos en la tabla temporal
SELECT * FROM #TempFileInfo;

-- Realizar otras operaciones con los datos de la tabla temporal según sea necesario

-- Finalmente, eliminar la tabla temporal
DROP TABLE #TempFileInfo;



---	RESTORE HEADERONLY FROM DISK ='0b82922f-421e-4125-be8a-d6249f971e63';
``` 

# Mejorar el rendimiento de consulta de tablas pesadas
```
******* activar la información de estadísticas de E/S y tiempo de ejecución *********
SET STATISTICS IO, TIME on

```



# Bibliografías :
Reparación de una dba: https://nira.com/how-to-repair-a-corrupted-sql-database/
