 ### ✅ Este laboratorio incluye:

✔ Creación de función y esquema de partición.  
✔ Tabla particionada por fecha mensual.  
✔ Inserción masiva de 10,000 registros con fechas aleatorias.  
✔ Validación de distribución y tamaño por partición.


***

##  **Ver si existen tablas particionadas**
```sql
 
-- las tablas ,  PartitionSchema y Partitionfunction
SELECT
    Distinct 
    s.name AS SchemaName,
    t.name AS TableName,
    ps.name AS PartitionScheme,
    pf.name AS PartitionFunction,
    ds.name AS FileGroup
FROM sys.tables AS t
JOIN sys.schemas AS s ON t.schema_id = s.schema_id
JOIN sys.indexes AS i ON t.object_id = i.object_id
JOIN sys.partition_schemes AS ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
JOIN sys.destination_data_spaces AS dds ON ps.data_space_id = dds.partition_scheme_id
JOIN sys.filegroups AS ds ON dds.data_space_id = ds.data_space_id
WHERE i.index_id IN (0,1)  -- heap o índice clustered
ORDER BY t.name;

---- Ver tamaño total de la tabla y su indice
 SELECT
    TOP 10
    s.name AS SchemaName,
    t.name AS TableName,
    fg.name AS FileGroupName,
    -- Tamaño total (datos + índices)
    CAST(SUM(a.total_pages) * 8.0 AS DECIMAL(18,2)) AS TotalSizeKB,
    -- Solo datos (heap o índice clustered)
    CAST(SUM(CASE WHEN i.type IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS DataSizeKB,
    -- Solo índices (nonclustered, XML, spatial, etc.)
    CAST(SUM(CASE WHEN i.type NOT IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS IndexSizeKB,
    CASE 
        WHEN COUNT(DISTINCT p.partition_number) > 1 THEN 'Sí'
        ELSE 'No'
    END AS IsPartitioned,
    COUNT(DISTINCT p.partition_number) AS PartitionCount,
    SUM(ps.row_count) AS TotalRows
FROM sys.tables AS t
LEFT JOIN sys.schemas AS s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
LEFT JOIN sys.filegroups AS fg ON i.data_space_id = fg.data_space_id 
LEFT JOIN sys.dm_db_partition_stats AS ps ON p.partition_id = ps.partition_id
GROUP BY s.name, t.name, fg.name
having COUNT(DISTINCT p.partition_number) > 1 ;



---- Ver tamaño por partición de la tabla y sus índices
 SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    fg.name AS FileGroupName,
    p.partition_number AS PartitionNumber,
    CAST(SUM(a.total_pages) * 8.0 AS DECIMAL(18,2)) AS TotalSizeKB,
    CAST(SUM(CASE WHEN i.type IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS DataSizeKB,
    CAST(SUM(CASE WHEN i.type NOT IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS IndexSizeKB,
    SUM(ps.row_count) AS TotalRows
FROM sys.tables AS t
LEFT JOIN sys.schemas AS s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
LEFT JOIN sys.data_spaces ds ON i.data_space_id = ds.data_space_id
LEFT JOIN sys.filegroups fg ON ds.data_space_id = fg.data_space_id
LEFT JOIN sys.dm_db_partition_stats AS ps ON p.partition_id = ps.partition_id
WHERE t.name = 'ClientesTest'
GROUP BY s.name, t.name, fg.name, p.partition_number
ORDER BY p.partition_number;


 --- Ver los indices de la tabla 
SELECT
    i.name AS Indice,
    i.type_desc AS TipoIndice,  -- Clustered o Nonclustered
    fg.name AS Filegroup,
    SUM(a.total_pages) * 8 AS Tamaño_KB
FROM sys.indexes i
LEFT JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE OBJECT_NAME(i.object_id) = 'ClientesTest'
GROUP BY i.name, i.type_desc, fg.name;


```

---

## ✅ **Objetivo del laboratorio**

Aprender a crear una tabla particionada por fecha mensual en SQL Server, asignar las particiones a un esquema de partición y una función de partición, y realizar inserciones masivas para validar la distribución de datos.

## **1. Crear la función de partición**

Esta función divide los datos por rangos mensuales:
RANGE LEFT significa que el límite es Menor o igual a la partición izquierda.

```sql
-- Partición 1: valores <= '2025-02-01'
-- Partición 2: valores > '2025-02-01' AND <= '2025-03-01'

-- Crear función de partición por mes
CREATE PARTITION FUNCTION pfClientesTest (DATE)
AS RANGE LEFT FOR VALUES (
    '2025-01-31', '2025-02-28', '2025-03-31', '2025-04-30', '2025-05-31',
    '2025-06-30', '2025-07-31', '2025-08-31', '2025-09-30', '2025-10-31',
    '2025-11-30', '2025-12-31'
);
GO
```

***

## **2. Crear el esquema de partición**

Asigna las particiones a un filegroup (puedes usar `PRIMARY` para todas si no tienes otros):

```sql
-- Crear esquema de partición
CREATE PARTITION SCHEME psClientesTest
AS PARTITION pfClientesTest
ALL TO ([PRIMARY]);  -- Puedes cambiar a otros filegroups si los tienes
GO
```

***

## **3. Crear la tabla particionada**

Incluye la columna `Fecha` para la partición:

```sql
-- DROP TABLE  dbo.ClientesTest 
CREATE TABLE dbo.ClientesTest (
    ID INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100),
    Ciudad VARCHAR(100),
    Pais VARCHAR(100),
    Fecha DATE NOT NULL,
    PRIMARY KEY CLUSTERED (ID ASC, Fecha ASC)
) ON psClientesTest(Fecha);
GO
```

***

## **4. Insertar 10,000 registros distribuidos por meses**

Generamos datos con fechas aleatorias dentro de 2025:

```sql
-- Insertar 10,000 registros con fechas aleatorias en 2025
INSERT INTO dbo.ClientesTest (Nombre, Ciudad, Pais, Fecha)
SELECT TOP 10000
    'Cliente_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'Ciudad_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'Pais_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2025-01-01')  -- Fecha aleatoria en 2025
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;
GO
```

***

## **5. Validar la distribución por partición**
Consulta para ver cuántos registros hay en cada partición:

```sql

--  Cantidad de filas por particion
SELECT
    $PARTITION.pfClientesTest(Fecha) AS PartitionNumber,
    COUNT(*) AS TotalRows
FROM dbo.ClientesTest
GROUP BY $PARTITION.pfClientesTest(Fecha)
ORDER BY PartitionNumber;
GO

-- ver las fechas de cada particion 
SELECT
    $PARTITION.pfClientesTest(Fecha) AS PartitionNumber,
    MIN(Fecha) AS MinDate,
    MAX(Fecha) AS MaxDate,
    COUNT(*) AS RowsCount
FROM dbo.ClientesTest
GROUP BY $PARTITION.pfClientesTest(Fecha)
ORDER BY PartitionNumber;



SELECT  TOP 100 *   FROM dbo.ClientesTest 
```

***

## **6. Validar tamaño por partición**

```sql
SELECT
    p.partition_number,
    CAST(SUM(a.total_pages) * 8.0 AS DECIMAL(18,2)) AS SizeKB
FROM sys.partitions AS p
INNER JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
WHERE p.object_id = OBJECT_ID('dbo.ClientesTest')
GROUP BY p.partition_number
ORDER BY p.partition_number;
GO
```

***



## **7. Borrar laboratorio**
```SQL
 drop TABLE dbo.ClientesTest;
 drop PARTITION SCHEME psClientesTest;
 drop PARTITION FUNCTION pfClientesTest;
```

--- 

# Info Extra 

###   Generar índice NONCLUSTERED en tabla particionada:
debes especificar el esquema de partición en la cláusula ON
```sql
--  General para índice en tabla particionada
CREATE NONCLUSTERED INDEX IX_ClientesTest_Ciudad
ON dbo.ClientesTest (Ciudad)
ON psClientesTest(Fecha);  -- psClientesTest es el esquema de partición
```


### Agregar un rango más 
```SQL 
ALTER PARTITION FUNCTION pfClientesTest()
SPLIT RANGE ('2026-01-01');
```


### Consultar la información de una particion en especifico 
```SQL
SELECT *
FROM dbo.ClientesTest
WHERE $PARTITION.pfClientesTest(Fecha) = 13;
```

 


 


