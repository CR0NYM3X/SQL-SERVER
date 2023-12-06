
### Buscar tablas :
```
    select * from INFORMATION_SCHEMA.TABLES  where table_name like '%my_tabla%'
    
    select object_id, name,create_date, modify_date from sys.tables where name like '%my_tabla%' --
```

### Saber la cantidad de filas/tuplas de una tabla
```
-- Opcion #1
SELECT
    t.name AS tabla,
    p.rows AS cnt_tuplas
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.name IN ('my_tabla');

-- Opcion #2
EXEC sp_spaceused N'my_tabla_test';

-- Opcion #3
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

### Crear una tabla temporal:
```
CREATE TABLE #tempEmpleados (
    empleado_id INT,
    nombre VARCHAR(50),
    salario DECIMAL(10, 2)
);

--- Esta tabla se borra al cerrar la sesion  y solo puede ser consultada por la sesion que la creo
SELECT columna1, columna2 INTO #tempTablaGlobal FROM TuTablaExistente WHERE condición;

--- Esta tabla se borra al cerrar la sesion  y solo puede ser consultada por todas sesiones 
SELECT columna1, columna2 INTO ##tempTablaGlobal FROM TuTablaExistente WHERE condición;


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
alter table banprefijos add id_cli int NOT NUL
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

# info extra
```
EXEC sys.sp_addextendedproperty @name = N'MiDescripcion', 
                                @value = 'Esta es una tabla de ejemplo',
                                @level0type = N'SCHEMA', 
                                @level0name = 'dbo', 
                                @level1type = N'TABLE', 
                                @level1name = N'MiTabla';
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


