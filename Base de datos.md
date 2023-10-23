

### Consutar las base de datos que existen:
    select name FROM sys.databases

### Crear una base de datos:
```
CREATE DATABASE Sales ON
(NAME = Sales_dat, --- este especificamos el nombre como se va guardar la data
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\saledat.mdf',
    SIZE = 10, ---Especifica el tamaño inicial del archivo de datos en megabytes. En este ejemplo, se inicia con 10 MB.
    MAXSIZE = 50, --- tamaño maximo  
    FILEGROWTH = 5) -- -Indica cómo crecerá el archivo de registro automáticamente.
LOG ON
(NAME = Sales_log, --- este especificamos el nombre  donde se va guarda los log de la dba
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\salelog.ldf',
    SIZE = 5 MB, 
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
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
    DROP DATABASE databasename;

### poner en estado online o offline 
    ALTER DATABASE NombreDeLaBaseDeDatos SET ONLINE;
    ALTER DATABASE NombreDeLaBaseDeDatos SET OFFLINE;


###  Ver el limite de conexiones que se permiten por Base de datos:


### Ver el tamaño de la base de datos:
```
SELECT 
      database_name = DB_NAME(database_id)
    , log_size_mb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2)) 
    , row_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2)) 
    , total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2)) 
FROM sys.master_files WITH(NOWAIT)
where database_id > 4 --- skip system databases 
GROUP BY database_id
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


### Bibliografía 
```
2) Crear una base de datos:
https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=sql-server-ver16&tabs=sqlpool

3) Cambiar el nombre de la db
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql?view=sql-server-ver16&tabs=sqlpool

```
