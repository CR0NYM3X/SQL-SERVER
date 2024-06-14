

# Modo de Compatibilidad Versión de SQL Server
```SQL
/********* Consultar la compatibilidad ************/
SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'NombreDeTuBaseDeDatos';

/********* Cambiar el modo de compatibilidad ************/
ALTER DATABASE NombreDeTuBaseDeDatos
SET COMPATIBILITY_LEVEL = 140;

/*********  tipos de compatibilidad  ************/
60	SQL Server 6.0
65	SQL Server 6.5
70	SQL Server 7.0
80	SQL Server 2000
90	SQL Server 2005
100	SQL Server 2008
110	SQL Server 2012
120	SQL Server 2014
130	SQL Server 2016
140	SQL Server 2017
150	SQL Server 2019
160	SQL Server 2022 (a partir de CTP 1.3)
```

### Consutar las base de datos que existen:
```SQL
select name,is_read_only,state_desc, recovery_model_desc FROM sys.databases
```

# saber todos los objetos que hay 
```SQL
select * from  sys.all_objects
```

# Cambiar de compatiblidad o version 
Esto sirve si cuantas con funciones que son de version mas antiguas y quieres que sean compatibles con tu sql server
```SQL
ALTER DATABASE [new_dba_test24] SET COMPATIBILITY_LEVEL = 100
SELECT compatibility_level,* FROM sys.databases
```

### funciones 
```SQL
select   DB_ID()
select   DB_NAME(5)
select   SCHEMA_NAME(2)
```

# falta por investigar más sobre: 
1.- los tipos de creacion de base de datos como el tema de primaryetc etc <br>
2.- si se pueden dividir/particionar los archivos de una base de datos <br>
3.- saber mas sobre estas tablas a detalles
```SQL
select * from  sys.filegroups
select * from sys.data_spaces 
select * from  sys.master_files --- obtener las rutas pysica de la base de datos
select * from  sys.sysaltfiles
select * FROM sys.database_files;
```

### Cambiar los estados de la base de datos
```SQL
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


### Crear una base de datos:
******* **CONCEPTOS** ******* <BR>
**`MDF (Primary Data File):`**  extensión por defecto, almacenan los datos principales y las estructuras de las tablas, índices, procedimientos almacenados y otros objetos. <BR>
**`NDF (Secondary Data File):`**   archivos de datos secundarios asociados a filegroups ,  Estos archivos también almacenan datos, y se pueden utilizar para organizar y distribuir los datos <BR>
**`LDF (Log Data File):`** registro de transacciones, almacenan la secuencia de operaciones de la base de datos, como las transacciones, cambios en los datos y operaciones de recuperación, esenciales para garantizar la consistencia y la recuperación en caso de fallo del sistema.

**`[NOTA]`** El campo **FILEGROWTH** es relevante/inutil si se asigno un tamaño maximo en el campo (MAXSIZE). por ejemplo, si se asigno como maximo 100GB y colocasque que icrementara 1GB en el campo FILEGROWTH, esto no va funcionar , no va incrementar la dba, esto solo funciona cuando se coloca como MAXSIZE ilimitado.

```SQL
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
    FILEGROWTH = 10MB  -- Crecimiento automático del filegroup secundario | tambien puedes usar % porcentajes
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
COLLATE   Latin1_General_CI_AS;
```
# Modificar el collate de una base de datos 
```sql
ALTER DATABASE MyOptionsTest  
COLLATE French_CI_AS ;  
```

### Saber el tamaño utilizado de los archivos MDF, NDF y LDF de todas las base de datos
```SQL
-- ******* OPCION #1 *******
/* CREAMOS LA TABLA TEMPORAL DONDE SE INSERTARAN LOS REGISTROS DE TODAS LAS BASES DE DATOS */

  CREATE TABLE #Temp_DBA_SPACE (
    [Nombre de la base de datos] NVARCHAR(255),
    [Nombre logico] NVARCHAR(255),
    [Tamaño total del archivo (MB)] DECIMAL(20, 2),
    [Crecimiento (MB)] DECIMAL(20, 2),
    MaxSize NVARCHAR(20),
    [Espacio utilizado (MB)] DECIMAL(20, 2),
	[Porcentaje % Espacio utilizado] DECIMAL(20, 2),
    [Espacio disponible (MB)] DECIMAL(20, 2),
	[Porcentaje % Espacio disponible]  DECIMAL(20, 2),
    [Ruta física] NVARCHAR(500),
    unidad_disco NVARCHAR(1),
    [Tipo archivo] NVARCHAR(3)
);

/* INSERTAMOS LOS REGISTROS DE  TODAS LAS BASES DE DATOS */
  execute SYS.sp_MSforeachdb 'use [?]; INSERT INTO  #Temp_DBA_SPACE 
SELECT
     DB_NAME(database_id) AS ''Nombre de la base de datos''
    ,name AS ''Nombre del archivo''
    ,CAST(CAST(size AS decimal(20,2)) * 8 / 1024 AS decimal(20,2)) AS ''Tamaño total del archivo (MB)''
    ,CAST(growth / 128.0 AS DECIMAL(20, 2)) AS ''Crecimiento (MB)''
    ,CASE WHEN max_size = -1 THEN ''Unlimited'' ELSE CAST(CAST(max_size * 8.0 / 1024 AS DECIMAL(20, 2)) as NVARCHAR(20)) + '' MB'' END AS MaxSize
   ,CAST(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS DECIMAL(20, 2))  * 8 / 1024 AS DECIMAL(20, 2))  AS ''Espacio utilizado (MB)''
   ,CAST( ( CAST(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS DECIMAL(20, 2))  * 8 / 1024 AS DECIMAL(20, 2))) * 100 / CAST(CAST(size AS decimal(20,2)) * 8 / 1024 AS decimal(20,2))  AS DECIMAL(20, 2))  as ''Porcentaje % Espacio utilizado''
   ,CAST(CAST(size AS decimal(20,2)) * 8 / 1024 AS decimal(20,2)) -  CAST(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS DECIMAL(20, 2))  * 8 / 1024 AS DECIMAL(20, 2))  as ''Espacio disponible (MB)''
 -- , CAST((CAST(CAST(size AS decimal(20,2)) * 8 / 1024 AS decimal(20,2)) -  CAST(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS DECIMAL(20, 2))  * 8 / 1024 AS DECIMAL(20, 2)) ) *100 / (CAST(CAST(size AS decimal(20,2)) * 8 / 1024 AS decimal(20,2))) AS decimal(20,2)) as ''Porcentaje % Espacio disponible''
    ,100.00 - (CAST( ( CAST(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS DECIMAL(20, 2))  * 8 / 1024 AS DECIMAL(20, 2))) * 100 / CAST(CAST(size AS decimal(20,2)) * 8 / 1024 AS decimal(20,2))  AS DECIMAL(20, 2))) as ''Porcentaje % Espacio disponible'' 
    ,physical_name AS ''Ruta física''
    ,LEFT(physical_name, 1) unidad_disco  
	,UPPER(RIGHT(physical_name, 3)) AS ''Tipo archivo''
   -- INTO ##TMP_DATA3
FROM sys.master_files
	  where database_id =  DB_ID()
ORDER BY LEFT(physical_name, 1) asc, database_id ;'
 
/* CONSULTAMOS LA INFO DE TODAS LAS BASES DE DATOS */
SELECT * FROM #Temp_DBA_SPACE ORDER BY   [porcentaje % espacio utilizado] desc


/* BORRAMOS LA TABLA */
DROP TABLE #Temp_DBA_SPACE


-- ******* OPCION #2 *******
SELECT name, size/128.0 FileSizeInMB,
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 
   AS EmptySpaceInMB
FROM sys.database_files;

-- ******* OPCION #3 *******
DBCC SQLPERF(logspace);
```


###  cambiar el name del mdf o ldf 
```sql
ALTER DATABASE [MY_dba_TEST]
MODIFY FILE (
    NAME = 'NOMBRE_MDF',
    NEWNAME= 'NUEVO_NOMBRE_MDF'
);
```sql

###  AUMENTAR EL TAMAÑO DE LA BASE DE DATOS
> [!IMPORTANT]
> Esta opción no sirve para hacer más pequeño el tamaño de los archivos la base de datos, sólo sirve para hacer más grande el tamaño de los archivos MDF,LDF o NDF

```sql
*********** PARA BUSCAR EL NOMBRE DEL ARCHIVO ***********
select name,physical_name from  sys.master_files where database_id =  DB_ID()

*********** HACER LA MODIFICACIÓN ***********
ALTER DATABASE [MY_dba_TEST]
MODIFY FILE (
    NAME = 'NOMBRE_DE_FILEGROUP',
 -- SIZE = 5GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 100MB
 -- FILENAME = 'F:\NuevoDirectorio\NombreArchivo.mdf'
);
```

### Reducir el tamaño de una base de datos 


```SQL
*********** PARA BUSCAR EL NOMBRE DEL ARCHIVO A REDUCIR ***********
select name,physical_name from  sys.master_files where database_id =  DB_ID()

******  Reduce el tamaño de archivos  LDF,NDF,MDF especifico ******
1.- Valida el tipo de recovery que tiene la dba 
SELECT name, recovery_model_desc FROM sys.databases where database_id = DB_ID()

2.- si esta en modo full cambiar a modo simple
ALTER DATABASE [my_dba_test] SET RECOVERY SIMPLE;

3.- Reducir el tamaño 
DBCC SHRINKFILE ('MibaseDeDatos_log', 1024); -- 1024 es el nuevo tamaño en MB

4.- Regresar al modo recovery como estaba
ALTER DATABASE [my_dba_test] SET RECOVERY full;

******  se utiliza para reducir el tamaño de todos los archivos de datos de una base de datos. *****
DBCC SHRINKDATABASE (NombreDeTuBaseDeDatos, 5000);

```



### Cambiar el nombre a una base de datos:
    ALTER DATABASE my_db_old Modify Name = my_db_new ;

### Saber la base de datos en la que estoy conectado
```SQL
select * from sys.databases where database_id=  DB_ID(); 

SELECT DB_NAME()
```

### Saber la rutas donde se guardan las base de datos 
```SQL
select * from sys.sysaltfiles ;
select * from sys.master_files;
```

### Elimina una base de datos 
```SQL
    EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SQLTestDB'
GO

USE [master];
GO
DROP DATABASE [SQLTestDB];
GO
```

### poner en estado online o offline 
```SQL
    ALTER DATABASE NombreDeLaBaseDeDatos SET ONLINE;
    ALTER DATABASE NombreDeLaBaseDeDatos SET OFFLINE;
```

###  Ver el limite de conexiones que se permiten por Base de datos:

```SQL
select  @@MAX_CONNECTIONS -- maximo conexiones

SELECT COUNT(*) AS 'Cantidad de Conexiones Activas' FROM sys.dm_exec_connections;
```

### saber el tamaño total/completo de la base de datos:
```SQL
/* ** Cuanto pesa total cada  base de datos usando Procedimiento almacenado  ** */
CREATE TABLE #sp_helpdb_tmp (
 name   VARCHAR(255),
db_size  VARCHAR(255), 
owner  VARCHAR(255) ,
dbid VARCHAR(255),
created VARCHAR(255),
status VARCHAR(max),
compatibility_leve INT);

INSERT INTO #sp_helpdb_tmp EXEC  sp_helpdb

select name
,cast(cast(REPLACE(db_size, 'MB', '')  AS DECIMAL(20,2))/1024AS DECIMAL(20,2))  db_size_GB  
,owner     from #sp_helpdb_tmp order by db_size desc 


/* ** Cuanto pesa en total cada  base de datos  ** */
 SELECT 
      database_name = DB_NAME(database_id)
    , LDF_size_GB = CAST((SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 )/1024 AS DECIMAL(20,2)) 
    , MDF_size_GB = CAST((SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024)/1024 AS DECIMAL(20,2)) 
    , total_size_GB = CAST((SUM(size) * 8. / 1024)/1024 AS DECIMAL(20,2)) 
FROM sys.master_files WITH(NOWAIT)
where database_id > 4 --- skip system databases 
GROUP BY database_id ORDER BY total_size_mb desc

```

### Saber la base de datos, sizedata y sizelog y que unidad estan
```SQL
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


### CREAR PARTICIONES Y FILEGROUPS 
```SQL
 CREATE TABLE Personas (
    PersonaID INT PRIMARY KEY,
    Nombre NVARCHAR(50),
    FechaNacimiento DATE,
    Ciudad NVARCHAR(50)
); 

Select * from Personas 


1.- ********** Agregar un filegroups a una base de datos **********

ALTER DATABASE [new_dba_test24]
ADD FILEGROUP FILEGROUP_1;

2.-  ********** Ver si se agrego ********** 
SELECT * FROM sys.filegroups

4.- ********** Generar el archivo fisico del ndf y agregarlo al filegroups ********** 
 ALTER DATABASE [new_dba_test24]   
ADD FILE   
(  
    NAME = FILEGROUP_1_dat,  
    FILENAME = 'F:\SQLLOG\new_dba_test_FILEGROUP.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP FILEGROUP_1;

5.-  ********** Ver si se agrego a la base de datos  ********** 
select * from FROM sys.master_files


6.- **********  Create a Partition Function ********** 
create PARTITION FUNCTION fun_particion_personas(int)  -- date 
    AS RANGE LEFT /*RIGHT*/ FOR VALUES (1, 100, 1000);
GO
 

7.-   ********** Ver si se creo la funcion  ********** 
SELECT * FROM sys.partition_functions;



8.-  ********** Create a Partition Scheme ********** 
CREATE PARTITION SCHEME partition_schema_test  
    AS PARTITION fun_particion_personas  
    TO (FILEGROUP_1, FILEGROUP_2, FILEGROUP_3, FILEGROUP_4);  
GO

9.-  ********** Ver si se creo la particion de esquema ********** 
SELECT * FROM sys.partition_schemes;



10.- **********  Create the Partitioned Table ********** 
CREATE TABLE Movies (
    MovieId int IDENTITY PRIMARY KEY, 
    MovieName varchar(60)
    )  
    ON particion_personas(MovieId);  
GO


11.- **********  ver la información de la tabla ********** 
SELECT name FROM OtherDb.dbo.Movies;

12.- **********  Ver las tablas que tienen particiones  ********** 
SELECT 
    object_schema_name(i.object_id) AS [Schema],
    object_name(i.object_id) AS [Object],
    i.name AS [Index],
    s.name AS [Partition Scheme]
    FROM sys.indexes i
    INNER JOIN sys.partition_schemes s ON i.data_space_id = s.data_space_id;



13.-  ********** ver las cantidades de tuplas/ filas que tiene cada particion  ********** 
SELECT partition_number,row_count FROM sys.dm_db_partition_stats WHERE object_id = OBJECT_ID('dbo.Movies');



************* VER CONFIGURACIÓN DE LAS PARTICIONES *************

SELECT FN.name, FN.fanout, VL.boundary_id, VL.value 
FROM sys.partition_functions FN
INNER JOIN sys.partition_range_values VL
ON FN.function_id = VL.function_id


SELECT
	 t.name tabla
--	,FILEGROUP_NAME(i.data_space_id)
	,t.type_desc tipo_tb 
	,i.name index_
	,i.type_desc tipo_index
	,is_primary_key
	,f.name filegroup_
	,f.type_desc filegroup_type 
	,rows 
	,partition_number
	,z.name,physical_name 
FROM SYS.tables t
INNER JOIN      
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
	sys.data_spaces  f on  i.data_space_id = f.data_space_id
INNER JOIN 
	sys.partitions g ON t.object_id = g.object_id and  i.index_id = g.index_id
left JOIN 
	sys.master_files z ON  z.data_space_id = f.data_space_id and z.type_desc = 'ROWS' and database_id= DB_ID()
	order by t.name, partition_number desc 


********
SELECT *, $PARTITION.pfDatos(FECHA) [Partition] FROM dbo.Movies 

/////////////////////////// BIBLIOGRAFÍA ///////////////////////////

FilesGrups
https://www.mssqltips.com/sqlservertip/5832/move-sql-server-tables-to-different-filegroups/

Particiones 
https://www.sqlservertutorial.net/sql-server-administration/sql-server-table-partitioning/
https://www.sqlservertutorial.net/sql-server-administration/sql-server-partition-existing-table/
https://database.guide/create-a-partitioned-table-in-sql-server-t-sql/

https://www.gpsos.es/2019/04/particionamiento-de-tablas-e-indices-t-sql-en-sql-server/
https://www.guillesql.es/Articulos/Particionamiento_tablas_indices_SQLServer_Partitioning.html

```



# Info extra
```SQL
 sys.dm_os_volume_stats(f.database_id, f.file_id)
```

### DIFERENCIA DE Filegroups Y Particiones
```
- Filegroups:
Son conjuntos lógicos de archivos de base de datos.
Permiten distribuir y administrar la ubicación física de los datos en la base de datos.
Pueden ayudar a mejorar el rendimiento, ya que permiten colocar objetos específicos en diferentes discos o unidades de almacenamiento.
Se pueden realizar copias de seguridad y restauraciones de un filegroup específico, lo que facilita la gestión de datos.

- Ejemplo de uso de Filegroups:
 Supongamos que se tiene una base de datos con tablas grandes y tablas más pequeñas. Para mejorar el rendimiento, se podrían asignar filegroups separados para las tablas grandes y las tablas pequeñas. De esta manera, los datos de las tablas grandes podrían residir en discos rápidos, mientras que los de las tablas más pequeñas podrían estar en discos más económicos.

- Particiones:
Dividen tablas o índices en secciones más pequeñas y manejables.
Facilitan la administración y el mantenimiento de grandes volúmenes de datos al dividirlos en partes más pequeñas y lógicas.
Se pueden basar en una columna específica (columna particionada) y así organizar los datos en función de valores de esa columna.

- Ejemplo de uso de Particiones:
En una tabla de registros históricos con datos que se extienden a lo largo de varios años, se podría utilizar particiones basadas en la fecha. Por ejemplo, se pueden crear particiones mensuales o anuales para organizar los datos. Esto facilitaría la gestión y el mantenimiento, así como la realización de consultas específicas sobre intervalos de tiempo con mayor eficiencia.

```


###  bases de datos independientes
Las bases de datos independientes en SQL Server están diseñadas para mejorar la portabilidad y la gestión de la seguridad al permitir que todas las configuraciones de seguridad necesarias se almacenen y gestionen dentro de la propia base de datos. Esto facilita el movimiento de bases de datos entre diferentes instancias de SQL Server, simplifica la gestión de usuarios y permisos y proporciona un mejor aislamiento de seguridad. Este enfoque es especialmente útil en entornos donde las bases de datos necesitan ser movidas o replicadas frecuentemente, como en el desarrollo, pruebas y despliegues de producción.
<br> 

```
USE master;
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'contained database authentication', 1;  -- Esto permite a las bases de datos ser autosuficientes en términos de gestión de usuarios y roles, sin depender de los inicios de sesión a nivel de servidor.
RECONFIGURE;

ALTER DATABASE Test
SET containment=partial

USE Test;  
GO 

CREATE USER Carlo  
WITH PASSWORD='Enterpwdhere*'  


--- Bibliografía --
https://learn.microsoft.com/es-es/sql/relational-databases/security/contained-database-users-making-your-database-portable?view=sql-server-ver16

```



### Bibliografía 
```
2) Crear una base de datos:
https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=sql-server-ver16&tabs=sqlpool

3) Cambiar el nombre de la db
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql?view=sql-server-ver16&tabs=sqlpool

```
