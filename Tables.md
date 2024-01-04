
### Realizar consultas de una tabla bloqueada

- Ventajas:  <br>
se realiza una lectura sin esperar que los recursos bloqueados por otras transacciones se liberen. Esto puede proporcionar una respuesta más rápida a la consulta, ya que no espera la finalización de las transacciones 

- Desventajas <br>
1.-  los datos podrían cambiar mientras se está realizando la lectura, lo que puede llevar a inconsistencias o a leer datos que ya no son válidos.<br>
2.- Posibles datos incorrectos<br>
3.- Puede leer datos que aún no se han confirmado o que están en proceso de modificación por otra transacción.

- Test de funcionamiento :<br>
puedes generar un BEGIN TRANSACTION; despues realizar un update de un registro y despues intentar consultarlo con nolock veras que te va traer la infomación como se modifico en el update y eso que no han finalizado el begin con un commit, despues validamos el mismo registro pero sin el lock y te aparecera bloqueado y no de va dejar consultarlo

```SQL
SELECT * FROM ARTICULOS(NOLOCK) where precio=29
SELECT * FROM ARTICULOS  with(nolock) where precio=29

**** OTROS PARAMETROS *********
"NOWAIT " se utiliza para indicar que una consulta debe ejecutarse inmediatamente sin esperar a que los recursos
necesarios estén disponibles. Si los recursos requeridos están bloqueados por otras operaciones, la consulta generará
 un error indicando que no pudo adquirir los recursos necesarios en ese momento.

```

### Reiniciar el incrementable IDENTITY
```
 DBCC CHECKIDENT ('Credito.dbo.CatCiudad', RESEED, 0)
```

### Crear sinonimos para tablas 
```
CREATE SYNONYM MiCliente FOR dbo.Clientes;

SELECT * FROM MiCliente;
```

### Buscar tablas :
```
    select * from INFORMATION_SCHEMA.TABLES  where table_name like '%my_tabla%'
    
    select object_id, name,create_date, modify_date from sys.tables where name like '%my_tabla%' --
```

### ver todas las descripcion de una tabla 
sp_help 'mytabla'

### Saber la cantidad de filas/tuplas de una tabla
```
****** Opcion #1 ******
select   OBJECT_NAME(object_id) as name_Tabla ,row_count
      ,SUM(used_page_count) * 8 / 1024 AS 'Tamaño en MB'   
		from sys.dm_db_partition_stats    
where OBJECT_NAME(object_id)   in('my_tabla_1')
group by  object_id,row_count order by row_count desc

****** Opcion #2 ******
select   OBJECT_NAME(object_id),row_count from sys.dm_db_partition_stats    where OBJECT_NAME(object_id)  
IN('my_tabla1', 'my_tabla2')
group by  object_id,row_count order by row_count desc

****** Opcion #3 ******
EXEC sp_spaceused N'my_tabla_test';

****** Opcion #4 ******
select count(*) from my_tabla




```


### Saber el Tamaño de las tablas :
```
---- una descripcion muy generica, pedes saber la cantidad de filas que tiene 
EXEC sp_spaceused N'my_tabla_test';

---- un reporte mas completo del tamaño 
SELECT 
    t.name AS TableName,
    s.name AS SchemaName,
    p.rows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
	mf.physical_name AS FilePathDB,
	LEFT(mf.physical_name, 1) letter /* ,
	f.name AS FileGroupName,
    mfgroup.physical_name AS FilePath */
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

/* --- En caso de que la base de datos use grupos de archivos se puede usar esto
INNER JOIN 
    sys.filegroups f ON i.data_space_id = f.data_space_id
INNER JOIN 
    sys.master_files mfgroup ON f.data_space_id = mfgroup.data_space_id
*/	

WHERE 
    t.name NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.object_id > 255
	and t.name  LIKE '%MY_TABLA%'  ------ AQUÍ COLOCAS LA TABLA QUE BUSCAS 
GROUP BY 
    t.name, s.name, p.rows , mf.physical_name  --, f.name,  mfgroup.physical_name 
ORDER BY 
    TotalSpaceMB DESC, t.name


```


### Ver el nombre, descripcion y type de las columnas de una tabla:
```
SELECT ORDINAL_POSITION,COLUMN_NAME,IS_NULLABLE,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION,COLLATION_NAME as encoding
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'my_tabla' order by ORDINAL_POSITION


select  top 10 * from sys.columns where object_id in(select object_id  from sys.tables where name like '%my_tabla%')  order by column_id  ;
```

### Saber que columna es la llave primario
```
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_NAME), 'IsPrimaryKey') = 1
AND TABLE_NAME = 'my_tabla';
```


### Crear una tabla :
```
CREATE TABLE Cliente (
    ClienteID INT PRIMARY KEY,
    Nombre NVARCHAR(100),
    Direccion NVARCHAR(255),
    Telefono NVARCHAR(20)
);
```

### Hacer particiones 

link: https://learn.microsoft.com/es-es/sql/relational-databases/partitions/create-partitioned-tables-and-indexes?view=sql-server-ver16
```

*********** EJEMPLO #1 ***********
CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))  
    AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01') ;  
GO  

CREATE PARTITION SCHEME myRangePS1  
    AS PARTITION myRangePF1  
    ALL TO ('PRIMARY') ;  
GO  

CREATE TABLE dbo.PartitionTable (col1 datetime2(0) PRIMARY KEY, col2 char(10))  
    ON myRangePS1 (col1) ;  
GO



*********** EJEMPLO #2 ***********


CREATE PARTITION FUNCTION [ParticionadoCuenta](bigint) AS RANGE RIGHT FOR VALUES (1, 2, 3, 4)
GO

CREATE PARTITION SCHEME [ParticionadoCuenta] AS PARTITION [ParticionadoCuenta_Particion] TO ([PRIMARY], [CuentaNOSE], [CuentaPARAOTROS], [CuentaNUEVAS], [CuentaACUMULADAS])
```

### Crear una tabla temporal:
```
********* OPCIÓN #1 ********* 
DECLARE @LogInfo TABLE (LogDate DATETIME,ProcessInfo VARCHAR(100),txt VARCHAR(max))

********* OPCIÓN #2 ********* 
CREATE TABLE #tempEmpleados (
    empleado_id INT,
    nombre VARCHAR(50),
    salario DECIMAL(10, 2)
);

********* OPCIÓN #3 ********* 
--- Esta tabla se borra al cerrar la sesion  y solo puede ser consultada por la sesion que la creo
SELECT columna1, columna2 INTO #tempTablaGlobal FROM TuTablaExistente WHERE condición;

********* OPCIÓN #4 ********* 
--- Esta tabla se borra al cerrar la sesion  y solo puede ser consultada por todas sesiones 
SELECT columna1, columna2 INTO ##tempTablaGlobal FROM TuTablaExistente WHERE condición;

********* OPCIÓN #5 ********* 
----- Esta temporal CTE  solo existe en la consulta, al finalizar la consulta se borran las tablas temporales 
WITH tmpTabla1 AS (
     SELECT * from my_Tabla1 where column1='maria'
),
tmpTabla2 AS (
    SELECT * from my_Tabla2 where column1='pedro'
)
select * from tmpTabla1 inner join tmpTabla2 on tmpTabla1.column1=tmpTabla2.column1
```

### Insertar información en una tabla:
```
INSERT my_tabla (column_2) VALUES ('Row #2');

INSERT into mytabla select 'Row #2'
```

### Actualizar la información de una tabla:
```
UPDATE Cities  
SET telefono = "2255469875"
WHERE Name = 'roberto';  
```


### Cambiar de esquema
```
ALTER SCHEMA NuevoEsquema TRANSFER EsquemaActual.MiTabla;
```

### Renombrar una tabla:
```
EXEC sp_rename 'table_old', 'table_new';
```

### Renomabrar una columna 
```
EXEC sp_rename 'clientes.nombre', 'nombre2', 'COLUMN';
```

### Agregar una columna 
```
alter table banprefijos add id_cli int -- no permite poner el not null eso se hace modificando la columna 
```

### cambiar el tipo de una columna 
```
ALTER TABLE bandatosempleados 
ALTER COLUMN empleado  char(10) not null
```

### Eliminar una columna 
ALTER TABLE banprefijos DROP COLUMN keyx;


### Eliminar una tabla
```
DROP TABLE NombreDeTabla;
```

### Eliminar la informacion de una tabla
```
truncate table my_tabla_old --- borra toda la informacion 
```


### saber los filgroups de cada tabla
```
SELECT 
    OBJECT_NAME(p.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    ds.name AS FilegroupName
FROM 
    sys.indexes AS i
INNER JOIN 
    sys.filegroups AS ds ON i.data_space_id = ds.data_space_id
INNER JOIN 
    sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
--WHERE     OBJECT_NAME(p.object_id) = 'NombreDeTuTabla';
order by p.object_id
```

# info extra
**agregar descripcion en las tablas **
```
EXEC sys.sp_addextendedproperty @name = N'MiDescripcion', 
                                @value = 'Esta es una tabla de ejemplo',
                                @level0type = N'SCHEMA', 
                                @level0name = 'dbo', 
                                @level1type = N'TABLE', 
                                @level1name = N'MiTabla';
```

### encriptar columnas 
```
SELECT * FROM sys.column_encryption_keys;
SELECT * FROM sys.column_master_keys;


CREATE CERTIFICATE HumanResources037  
   WITH SUBJECT = 'Employee Social Security Numbers';  
GO  

CREATE SYMMETRIC KEY SSN_Key_01  
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE HumanResources037;  
GO  

USE [AdventureWorks2022];  
GO  

-- Create a column in which to store the encrypted data.  
ALTER TABLE HumanResources.Employee  
    ADD EncryptedNationalIDNumber varbinary(128);   
GO  

-- Open the symmetric key with which to encrypt the data.  
OPEN SYMMETRIC KEY SSN_Key_01  
   DECRYPTION BY CERTIFICATE HumanResources037;  

-- Encrypt the value in column NationalIDNumber with symmetric   
-- key SSN_Key_01. Save the result in column EncryptedNationalIDNumber.  
UPDATE HumanResources.Employee  
SET EncryptedNationalIDNumber = EncryptByKey(Key_GUID('SSN_Key_01'), NationalIDNumber);  
GO  

-- Verify the encryption.  
-- First, open the symmetric key with which to decrypt the data.  
OPEN SYMMETRIC KEY SSN_Key_01  
   DECRYPTION BY CERTIFICATE HumanResources037;  
GO  

-- Now list the original ID, the encrypted ID, and the   
-- decrypted ciphertext. If the decryption worked, the original  
-- and the decrypted ID will match.  
SELECT NationalIDNumber, EncryptedNationalIDNumber   
    AS 'Encrypted ID Number',  
    CONVERT(nvarchar, DecryptByKey(EncryptedNationalIDNumber))   
    AS 'Decrypted ID Number'  
    FROM HumanResources.Employee;  
GO
```

# Enmascarar columnas  / Dynamic Data Masking
```SQL
link: https://www.geopits.com/blog/dynamic-data-masking-in-sql-server.html

EXECUTE AS USER = 'test2';
	select * from PasswordEnvioMensajeria
REVERT;

 Alter table [Table Name] ALTER [Column Name] ADD MASKED WITH (FUNCTION = 'default()')
---
DEFAULT: Oculta los datos reemplazándolos con una máscara predeterminada según el tipo de datos.
EMAIL(): Muestra solo los primeros caracteres del correo electrónico y oculta el resto.
PARTIAL(X,Y): Muestra los primeros X caracteres y los últimos Y caracteres, ocultando el resto.
RANDOM(X,Y): Reemplaza el valor original con un valor aleatorio entre X e Y.


GRANT unmask   TO test2;
revoke unmask   TO test2;
```



### Crear tablas con foring key, primary key  y su index




```SQL


/* ---------------- DESCRIPCION ----------------
--->  Las restricciones para una clave primaria (primary key) en SQL son las siguientes:

1.- No se permiten registros nulos en los primary key
2.- Son valores únicos y no se pueden duplicar y por lo que funciona como un identificador y estos se
pueden colocar auto  incrementar 
*/

-- Crear tabla DESCRIPCION_ARTICULO
CREATE TABLE DESCRIPCION_ARTICULO (
    ID_Articulo_2 INT PRIMARY KEY,
    ID_Descripcion INT,
    Detalles NVARCHAR(50)
) ;


/* ---------------- DESCRIPCION ----------------
--->  Las restricciones para una  clave foránea (foreign key)
1.- Las tablas que tengan claves foraneas se crean al final, ya que primero tiene que crearse la tabla a la que hará referencia 
2.- no se permiten registros nulos


[Nota] si intentas crear primero la tabla ARTICULOS sin antes crear la tabla DESCRIPCION_ARTICULO te saldra el siguiente error 
"Foreign key 'FK_Articulo_Descripcion' references invalid table 'DESCRIPCION_ARTICULO'."
*/

CREATE TABLE ARTICULOS (
    ID_Articulo INT PRIMARY KEY,
    Nombre NVARCHAR(100),
    Precio  INT,  --DECIMAL(10, 2),
    CONSTRAINT FK_Articulo_Descripcion FOREIGN KEY (ID_Articulo) REFERENCES   DESCRIPCION_ARTICULO(ID_Articulo_2)
);


/* ---------------- DESCRIPCION índice compuesto ----------------
--->  Las restricciones para crear index
1.- Tipo de datos y longitud: no se pueden crear índices en columnas de tipo text, ntext , image o varchar(max) ya que saldra el
error "Column 'Detalles' in table 'DESCRIPCION_ARTICULO' is of a type that is invalid for use as a key column in an index."

2.- Número de índices: Existe un límite en la cantidad de índices que se pueden crear por tabla. 
3.- Uso de memoria y espacio en disco:  consumen recursos como la memoria y el espacio en disco. Crear un gran número de índices
puede afectar el rendimiento y el almacenamiento.
4.- Operaciones de mantenimiento:    requieren mantenimiento, lo que implica cierto tiempo adicional durante las operaciones
5.- Índices compuestos: Al crear un índice compuesto (índice que abarca múltiples columnas), es fundamental considerar el orden
de las columnas en el índice para optimizar las consultas.
*/
 
---- es lo mismo 
CREATE INDEX idx_Combinado ON DESCRIPCION_ARTICULO (ID_Articulo_2 desc ) INCLUDE (Detalles desc );
CREATE INDEX idx_Combinado ON DESCRIPCION_ARTICULO (ID_Articulo_2, Detalles);

CREATE INDEX idx_DosColumnas2 ON DESCRIPCION_ARTICULO ( ID_Articulo_2 desc);


INSERT INTO DESCRIPCION_ARTICULO (ID_Articulo_2, ID_Descripcion, Detalles) VALUES (1, 1, 'Camisa de algodón en varios colores.');
INSERT INTO DESCRIPCION_ARTICULO (ID_Articulo_2, ID_Descripcion, Detalles) VALUES (2, 1, 'Pantalón vaquero con bolsillos.');
INSERT INTO DESCRIPCION_ARTICULO (ID_Articulo_2, ID_Descripcion, Detalles) VALUES (3, 1, 'Zapatos de cuero elegantes.');
INSERT INTO DESCRIPCION_ARTICULO (ID_Articulo_2, ID_Descripcion, Detalles) VALUES (4, 1, 'Sombrero de ala ancha para el sol.');
INSERT INTO DESCRIPCION_ARTICULO (ID_Articulo_2, ID_Descripcion, Detalles) VALUES (5, 1, 'Bufanda suave y abrigada para el invierno.');


INSERT INTO ARTICULOS (ID_Articulo, Nombre, Precio) VALUES (1, 'Camisa', 29.99); 
INSERT INTO ARTICULOS (ID_Articulo, Nombre, Precio) VALUES (2, 'Pantalón', 39.99);
INSERT INTO ARTICULOS (ID_Articulo, Nombre, Precio) VALUES (3, 'Zapatos', 59.99);
INSERT INTO ARTICULOS (ID_Articulo, Nombre, Precio) VALUES (4, 'Sombrero', 19.99);
INSERT INTO ARTICULOS (ID_Articulo, Nombre, Precio) VALUES (5, 'Bufanda', 14.99);

/*
Consultar la informacion  y forzar una consulta que utilice un index, lo cual te mostrada los datos como tu lo guardaste
*/

SELECT * FROM DESCRIPCION_ARTICULO WITH (INDEX = idx_DosColumnas2) 
SELECT * FROM ARTICULOS


/* ---------------- DESCRIPCION ----------------
Si intentas hacer un drop o truncate  la tabla que hace referencia el foring key en este ejemplo es "DESCRIPCION_ARTICULO"   te va aparecer los sigueintes errores
"Could not drop object 'DESCRIPCION_ARTICULO' because it is referenced by a FOREIGN KEY constraint.
Cannot truncate table 'DESCRIPCION_ARTICULO' because it is being referenced by a FOREIGN KEY constraint."

*/

--- La solucion es  Eliminar el foring key, despues realizar el drop o truncate y despues agregarlo el foring key:
ALTER TABLE ARTICULOS DROP CONSTRAINT FK_Articulo_Descripcion;  

truncate table DESCRIPCION_ARTICULO
DROP TABLE DESCRIPCION_ARTICULO 

 ALTER TABLE ARTICULOS
ADD  CONSTRAINT FK_Articulo_Descripcion FOREIGN KEY (ID_Articulo) REFERENCES   DESCRIPCION_ARTICULO(ID_Articulo_2)


DROP TABLE ARTICULOS
drop index idx_Combinado  ON DESCRIPCION_ARTICULO 
 
 

 --- Guía de diseño y de arquitectura de índices de SQL Server y Azure SQL --- 
 https://learn.microsoft.com/es-es/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver16



```

### Bloques en  tablas DE SQL Server debido a varias situaciones:
**`Bloqueo explícito:`** Cuando se ejecuta una transacción que modifica datos y se utiliza un bloqueo explícito como BEGIN TRANSACTION y COMMIT TRANSACTION, otras transacciones pueden ser bloqueadas para acceder a esos datos hasta que se complete la transacción actual.

**`Bloqueo implícito:`** Las operaciones de escritura como UPDATE, DELETE o INSERT pueden bloquear una tabla o filas dentro de ella mientras se realizan, impidiendo que otras transacciones modifiquen esos mismos datos simultáneamente.

**`Bloqueo de lectura:`** Las transacciones de lectura (SELECT) también pueden bloquear recursos en ciertas condiciones, como cuando se utilizan ciertos niveles de aislamiento de transacciones.

```SQL

/* 
SIRVE PARA VER LOS BLOQUEAS QUE HAY ACTUALMENTE 
*/
 
 SELECT
 TL.resource_associated_entity_id,
    TL.resource_type,
	TL.request_type,
    DB_name(TL.resource_database_id) db,
    TL.resource_associated_entity_id,
    TL.request_mode,
    TL.request_session_id,
    ER.blocking_session_id,
    ES.login_name,
    ES.host_name,
    ES.program_name,
    ER.command,
    ER.status,
    ER.wait_type,
	OBJ.name AS object_name,
    SCHEMA_NAME(OBJ.schema_id) AS schema_name
FROM sys.dm_tran_locks TL
JOIN sys.dm_exec_requests ER ON TL.request_session_id = ER.session_id
JOIN sys.dm_exec_sessions ES ON ER.session_id = ES.session_id
LEFT JOIN sys.objects OBJ ON TL.resource_associated_entity_id = OBJ.object_id
 

```

### Bibliografia :
```

1) Crear tabla
https://learn.microsoft.com/es-es/sql/t-sql/statements/create-table-transact-sql?view=sql-server-ver16

2) insertar en tabla
https://learn.microsoft.com/es-es/sql/t-sql/statements/insert-transact-sql?view=sql-server-ver16

3) Rename columns
https://learn.microsoft.com/en-us/sql/relational-databases/tables/rename-columns-database-engine?view=sql-server-ver16

4) tamaño de tablas
https://stackoverflow.com/questions/7892334/get-size-of-all-tables-in-database

```


