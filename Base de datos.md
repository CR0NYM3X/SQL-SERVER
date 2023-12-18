
### funciones 
```
select   DB_ID()
select   DB_NAME(5)
select   SCHEMA_NAME(2)
```

# falta por investigar más sobre: 
1.- los tipos de creacion de base de datos como el tema de primaryetc etc <br>
2.- si se pueden dividir/particionar los archivos de una base de datos <br>
3.- saber mas sobre estas tablas a detalles
```
select * from  sys.filegroups
select * from sys.data_spaces 
select * from  sys.master_files --- obtener las rutas pysica de la base de datos
```

### Cambiar los estados de la base de datos
```
******* MODO OFFLINE Y ONLINE *******
use master 
ALTER DATABASE new_dba_test24 SET OFFLINE;
ALTER DATABASE new_dba_test24 SET ONLINE;

******* MODO WRITE Y READ ONLY *******
ALTER DATABASE [new_dba_test24] SET READ_WRITE WITH NO_WAIT;

******* PARÁMETROS *******
EMERGENCY: Este estado se utiliza cuando la base de datos está en un estado de emergencia. Usualmente se usa para recuperación crítica.
RESTRICTED_USER: Limita el acceso a la base de datos solo a usuarios con roles específicos.
SINGLE_USER: Permite acceso a un solo usuario. Otros usuarios no pueden conectarse a la base de datos.
READ_WRITE: Modo de lectura/escritura normal
READ_ONLY: Modo lectura en la base de datos
OFFLINE_SECONDARY: Se utiliza en grupos de disponibilidad Always On para deshabilitar temporalmente una réplica secundaria.
```

### tener descripcion generica de la base de datos 
    sp_helpfile

### Consutar las base de datos que existen:
    select name,is_read_only,state_desc FROM sys.databases

### Crear una base de datos:
******* **CONCEPTOS** ******* <BR>
**`MDF (Primary Data File):`**  extensión por defecto, almacenan los datos principales y las estructuras de las tablas, índices, procedimientos almacenados y otros objetos. <BR>
**`NDF (Secondary Data File):`**   archivos de datos secundarios asociados a filegroups ,  Estos archivos también almacenan datos, y se pueden utilizar para organizar y distribuir los datos <BR>
**`LDF (Log Data File):`** registro de transacciones, almacenan la secuencia de operaciones de la base de datos, como las transacciones, cambios en los datos y operaciones de recuperación, esenciales para garantizar la consistencia y la recuperación en caso de fallo del sistema.


```
CREATE DATABASE NombreBaseDatos ON 
PRIMARY (
    NAME = 'DatosPrimarios',
    FILENAME = 'C:\dba\RutaArchivoDatosPrimarios.mdf',
    SIZE = 100MB,   -- Tamaño inicial del archivo de datos primarios
    MAXSIZE = UNLIMITED,  -- Tamaño máximo del archivo de datos primarios, puedes especificar el numero y se interpreta en megas ejemplo solo poner 50, que son cincuenta megas 
    FILEGROWTH = 20MB  -- Crecimiento automático del archivo de datos primarios
),
FILEGROUP GrupoSecundario1 (
    NAME = 'GrupoSecundario1',
    FILENAME = 'C:\dba\RutaArchivoSecundario1.ndf',
    SIZE = 50MB,   -- Tamaño inicial del archivo del filegroup secundario
    MAXSIZE = UNLIMITED,  -- Tamaño máximo del filegroup secundario
    FILEGROWTH = 10MB  -- Crecimiento automático del filegroup secundario
),
FILEGROUP GrupoSecundario2 (
    NAME = 'GrupoSecundario2',
    FILENAME = 'C:\dba\RutaArchivoSecundario2.ndf',
    SIZE = 50MB,   -- Tamaño inicial del archivo del filegroup secundario
    MAXSIZE = UNLIMITED,  -- Tamaño máximo del filegroup secundario
    FILEGROWTH = 10MB  -- Crecimiento automático del filegroup secundario
)
LOG ON (
    NAME = 'LogTransacciones',
    FILENAME = 'C:\dba\RutaArchivoLog.ldf',
    SIZE = 50MB,  -- Tamaño inicial del archivo de registro de transacciones
    MAXSIZE = 1GB,  -- Tamaño máximo del archivo de registro de transacciones
    FILEGROWTH = 20%  -- Crecimiento automático del archivo de registro de transacciones, puedes ponerlo 5 MB
)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT;
```

### Ver la ruta de archivos  MDF, NDF, LDF  donde se guarda las base de datos 
```
SELECT a.name as name_file  , physical_name AS RutaArchivo, a.database_id,b.name as name_database
FROM sys.master_files a
left join sys.databases  b  on a.database_id = b.database_id order by b.name
```

### Cambiar el nombre a una base de datos:
    ALTER DATABASE my_db_old Modify Name = my_db_new ;

### Saber la base de datos en la que estoy conectado
```
select * from sys.databases where database_id=  DB_ID(); 

SELECT DB_NAME()
```

### Saber la rutas donde se guardan las base de datos 
```
select * from sys.sysaltfiles ;
select * from sys.master_files;
```

### Elimina una base de datos 
```
    EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SQLTestDB'
GO

USE [master];
GO
DROP DATABASE [SQLTestDB];
GO
```

### poner en estado online o offline 
    ALTER DATABASE NombreDeLaBaseDeDatos SET ONLINE;
    ALTER DATABASE NombreDeLaBaseDeDatos SET OFFLINE;


###  Ver el limite de conexiones que se permiten por Base de datos:

```
select  @@MAX_CONNECTIONS -- maximo conexiones

SELECT COUNT(*) AS 'Cantidad de Conexiones Activas' FROM sys.dm_exec_connections;
```

### Ver el tamaño de la base de datos:
```
--- Procedimiento almacenado 
sp_helpdb

---- este te dice en general cuanto pesa toda la base de datos 
SELECT 
      database_name = DB_NAME(database_id)
    , log_size_mb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2)) 
    , row_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2)) 
    , total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2)) 
FROM sys.master_files WITH(NOWAIT)
where database_id > 4 --- skip system databases 
GROUP BY database_id

---- este te dice cuanto pesa cada archivo data y log
SELECT db.[database_id] AS 'Id_Bd',
af.[filename] AS 'Ubicacion',
db.[name] AS 'Base de datos',
af.[name] AS 'Nombe Logico',
CONVERT(numeric(15,2),((((CONVERT(numeric(15,2),SUM(size)) * (SELECT low FROM master.dbo.spt_values (NOLOCK) WHERE number = 1 
AND type = 'E')) / 1024.)/1024.))) AS 'Tamaño en MB',
CONVERT(numeric(15,2),((((CONVERT(numeric(15,2),SUM(af.size)) * (SELECT low FROM master.dbo.spt_values (NOLOCK) WHERE number = 1 
AND type = 'E')) / 1024.)/1024.)/1024.)) AS 'Tamaño en GB'
FROM sys.databases db INNER JOIN sys.sysaltfiles af ON db.database_id = af.dbid
WHERE [fileid] in (1,2) GROUP BY db.[database_id] , db.[name], af.[name], af.[filename]
Order by [Base de datos]



```

### Saber la base de datos, sizedata y sizelog y que unidad estan
```
select * from 
  (select name , ( select filename from sys.sysaltfiles where dbid= database_id and fileid=1 ) as sqldata,
  ( select filename from sys.sysaltfiles where dbid= database_id and fileid=2 ) as sqllog,
  ( select LEFT(filename, 1)  from sys.sysaltfiles where dbid= database_id and fileid=1 ) as discodata,
  ( select LEFT(filename, 1)  from sys.sysaltfiles where dbid= database_id and fileid=2 ) as discolog
  from sys.databases where  database_id > 4 )a
  where     discodata in('E','F','G','H')  and discolog  in('E','F','G','H')
  order by name
  ```


### saber el tipo de encoding
    SELECT name, collation_name  FROM sys.databases

### Saber el tamaño de los archivos de la base de datos
```
SELECT name, size/128.0 FileSizeInMB,
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 
   AS EmptySpaceInMB
FROM sys.database_files;
```
### Info extra
```
 sys.dm_os_volume_stats(f.database_id, f.file_id)
```

### Bibliografía 
```
2) Crear una base de datos:
https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=sql-server-ver16&tabs=sqlpool

3) Cambiar el nombre de la db
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql?view=sql-server-ver16&tabs=sqlpool

```
