 

## ✅ **Objetivo del laboratorio**

Aprender a crear una tabla particionada por fecha mensual en SQL Server, asignar las particiones a un esquema de partición y una función de partición, y realizar inserciones masivas para validar la distribución de datos.

***

## **1. Crear la función de partición**

Esta función divide los datos por rangos mensuales:

```sql
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
SELECT
    $PARTITION.pfClientesTest(Fecha) AS PartitionNumber,
    COUNT(*) AS TotalRows
FROM dbo.ClientesTest
GROUP BY $PARTITION.pfClientesTest(Fecha)
ORDER BY PartitionNumber;
GO

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

### ✅ Este laboratorio incluye:

✔ Creación de función y esquema de partición.  
✔ Tabla particionada por fecha mensual.  
✔ Inserción masiva de 10,000 registros con fechas aleatorias.  
✔ Validación de distribución y tamaño por partición.

***

¿Quieres que ahora te redacte **el objetivo, alcance, requisitos previos y pasos del laboratorio en formato profesional para tu manual**?  
¿O prefieres que también agregue **una sección de cómo mover esta tabla particionada a otro filegroup** como parte del laboratorio?



-----------------


### ✅ **Caso 1: Tabla con índice clustered**

Puedes mover el índice clustered (que contiene los datos) al nuevo filegroup:

```sql
CREATE CLUSTERED INDEX IX_ClientesTest_ID
ON dbo.ClientesTest(ID)
WITH (DROP_EXISTING = ON)
ON [NuevoFileGroup];
```

*   `DROP_EXISTING = ON` → Reorganiza el índice existente sin cambiar el esquema.
*   Esto mueve **los datos** al filegroup indicado.




----------------------------------------------------------

### ✅  General para índice en tabla particionada:
debes especificar la función de partición y el esquema de partición en la cláusula ON
```sql
--  General para índice en tabla particionada
CREATE NONCLUSTERED INDEX IX_ClientesTest_Ciudad
ON dbo.ClientesTest (Ciudad)
ON psClientesTest(Fecha);  -- psClientesTest es el esquema de partición
```


select * from sys.schemas

SELECT name AS PartitionSchemeName,* FROM sys.partition_schemes;


SELECT 
       DISTINCT 
       ps.name AS PartitionScheme,
       pf.name AS PartitionFunction,
       ds.name AS FileGroup
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
INNER JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id
INNER JOIN sys.filegroups ds ON dds.data_space_id = ds.data_space_id;


SELECT
    t.name AS TableName,
    i.name AS IndexName,
    p.partition_number,
    --p.rows AS RowCount,
    au.total_pages * 8 AS SizeKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units au ON p.partition_id = au.container_id
WHERE t.name = 'ClientesTest'
ORDER BY p.partition_number;




-- consultar la información de una particion en especifico 
SELECT *
FROM dbo.ClientesTest
WHERE $PARTITION.pfClientesTest(Fecha) = 13
