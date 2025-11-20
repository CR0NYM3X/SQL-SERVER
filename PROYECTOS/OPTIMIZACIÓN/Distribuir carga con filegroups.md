
### **Objetivo del Manual**

Proporcionar una guía práctica y detallada para **migrar tablas entre filegroups en SQL Server**, asegurando la integridad de los datos y la correcta configuración de índices, constraints, permisos y dependencias. El laboratorio permitirá comprender:

*   Cómo identificar el tamaño total de una tabla, separando datos e índices.
*   Cómo determinar si una tabla está particionada y en qué filegroup reside.
*   Las consideraciones técnicas y de integridad necesarias antes de mover datos.
*   Procedimientos para mover tablas con o sin índice clustered al filegroup deseado.
*   Validación posterior para garantizar consistencia y rendimiento.
 

# Laboratorio 

###  **1. Crear tabla con 1000 registros e índices**

```sql
USE Northwind;
GO

CREATE TABLE dbo.ClientesTest (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100),
    Ciudad VARCHAR(100),
    Pais VARCHAR(50)
);
GO

-- Insertar 5000 registros
INSERT INTO dbo.ClientesTest (Nombre, Ciudad, Pais)
SELECT TOP 5000
    'Cliente_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'Ciudad_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'Pais_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))
FROM
    (SELECT 1 AS n FROM sys.all_objects) a
CROSS JOIN
    (SELECT 1 AS n FROM sys.all_objects) b;
GO

-- Índice no clustered
CREATE NONCLUSTERED INDEX IX_ClientesTest_Nombre ON dbo.ClientesTest(Nombre);
GO

```
 
###  **2. Crear nuevo filegroup y agregar dos .ndf**

```sql
ALTER DATABASE Northwind ADD FILEGROUP FG_DatosNuevo;
GO

ALTER DATABASE Northwind ADD FILE (
    NAME = Northwind_Data_E,
    FILENAME = 'E:\SQLDATA2019\Northwind_Data_E.ndf',
    SIZE = 500MB,
    FILEGROWTH = 100MB
) TO FILEGROUP FG_DatosNuevo;
GO

ALTER DATABASE Northwind ADD FILE (
    NAME = Northwind_Data_F,
    FILENAME = 'F:\SQLLOG2019\Northwind_Data_F.ndf',
    SIZE = 500MB,
    FILEGROWTH = 100MB
) TO FILEGROUP FG_DatosNuevo;
GO
```

###  **3. Validar Tamaño de tabla,index y FileGROUP con sus FILES**
Validar y comparar una vez se mueva la información a los NDF 
```sql
-- Validar en qué filegroup está la tabla y su tamaño
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
WHERE OBJECT_NAME(p.object_id) = 'ClientesTest'
GROUP BY s.name, t.name, fg.name;



--  Validar filegroup de índices y tamaño
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

--- Ver el Tamaño del nuevo filegroup y FILES NDF
SELECT 
    f.name AS FileName,
    f.physical_name AS Ruta,
    size * 8 / 1024 AS Tamaño_MB,
    CAST(FILEPROPERTY(f.name, 'SpaceUsed') * 8  AS INT) AS Usado_KB,
    (size - FILEPROPERTY(f.name, 'SpaceUsed')) * 8  AS Disponible_KB
FROM sys.filegroups fg
JOIN sys.database_files f ON fg.data_space_id = f.data_space_id;
```




###  **4. Mover la tabla al nuevo filegroup**
- Al reconstruir el Clustered Index y especificar el nuevo Filegroup, SQL Server moverá toda la información de la tabla a ese nuevo espacio,  porque el índice agrupado define la estructura física de la tabla.
- Al eliminas el índice clustered, la tabla no se borra; simplemente pasa a ser un heap. Los datos siguen existiendo, pero la organización física cambia.
- El índice clustered no es un índice adicional como los nonclustered; es la estructura principal que contiene las filas de la tabla.

**Consideraciones**
  
```sql
ALTER TABLE dbo.ClientesTest DROP CONSTRAINT PK__Clientes__71ABD0A7BECEB27D;
 
ALTER TABLE dbo.ClientesTest
ADD CONSTRAINT PK_ClientesTest PRIMARY KEY CLUSTERED (ClienteID)
ON FG_DatosNuevo;
GO
```

Ahora la tabla y sus datos están en los .ndf.


###  **5.  Validar Tamaño de tabla,index y FileGROUP con sus FILES**

```sql
-- Validar en qué filegroup está la tabla y su tamaño
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
WHERE OBJECT_NAME(p.object_id) = 'ClientesTest'
GROUP BY s.name, t.name, fg.name;



--  Validar filegroup de índices y tamaño
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

--- Ver el Tamaño del nuevo filegroup y FILES NDF de la DB

SELECT 
    f.name AS FileName,
    f.physical_name AS Ruta,
    size * 8 / 1024 AS Tamaño_MB,
    CAST(FILEPROPERTY(f.name, 'SpaceUsed') * 8  AS INT) AS Usado_KB,
    (size - FILEPROPERTY(f.name, 'SpaceUsed')) * 8  AS Disponible_KB
FROM sys.filegroups fg
JOIN sys.database_files f ON fg.data_space_id = f.data_space_id; 
```

###  **6. Borrar el laboratorio**
```sql



-- En caso de querer borrar los NDF  y contiene informacion marcara el siguiente error "The file 'Northwind_Data_E' cannot be removed because it is not empty."
-- Mover los datos que estaban en el los FILES NDF  al FILEGROUP PRIMARY
ALTER TABLE dbo.ClientesTest DROP CONSTRAINT PK_ClientesTest;
 
ALTER TABLE dbo.ClientesTest
ADD CONSTRAINT PK_ClientesTest PRIMARY KEY CLUSTERED (ClienteID)
ON [PRIMARY];


-- Mover los datos al filegroup `PRIMARY` u otro:
ALTER DATABASE northwind REMOVE FILE Northwind_Data_E;
ALTER DATABASE northwind REMOVE FILE Northwind_Data_F;

-- borrar el fileGroup
ALTER DATABASE Northwind REMOVE FILEGROUP FG_DatosNuevo

-- En caso de querer borrar la tabla 
DROP TABLE dbo.ClientesTest ; 

```



# Datos extras 


## Mover tabla sin index Clustered y sus consideraciones
En caso de tener una tabla sin index Clustered es un reto Mover datos de una tabla a otra (aunque sea para cambiar de filegroup) implica varias consideraciones importantes para evitar pérdida de información, problemas de integridad y afectaciones al rendimiento. Aquí están las más relevantes:

```SQL
-- Crear una tabla nueva en el filegroup y mover los datos
CREATE TABLE dbo.ClientesTest_New
(
    ID INT NOT NULL,
    Nombre VARCHAR(100),
    -- demás columnas
)
ON [NuevoFileGroup];

INSERT INTO dbo.ClientesTest_New
SELECT * FROM dbo.ClientesTest;

DROP TABLE dbo.ClientesTest;

EXEC sp_rename 'dbo.ClientesTest_New', 'ClientesTest';
```


### ✅ **1. Integridad referencial**

*   Si la tabla tiene **llaves foráneas** (FK) hacia otras tablas, al recrearla debes volver a definir esas relaciones.
*   Si otras tablas apuntan a esta tabla, deberás actualizar sus referencias.
 

### ✅ **2. Índices y constraints**

*   Todos los **índices** (clustered, nonclustered, únicos) y **constraints** (PRIMARY KEY, UNIQUE, CHECK, DEFAULT) deben recrearse en la nueva tabla.
*   Si no los recreas, el rendimiento y la lógica pueden verse afectados.
 

### ✅ **3. Triggers y permisos**

*   Si la tabla tiene **triggers**, deben migrarse.
*   Los **permisos** (GRANT, DENY) asignados a usuarios/roles también deben aplicarse en la nueva tabla.

 

### ✅ **4. Identidad y secuencias**

*   Si la tabla tiene una columna **IDENTITY**, asegúrate de copiar el valor actual del contador (`DBCC CHECKIDENT`) para que no se reinicie.
*   Si usa **secuencias**, verifica su estado.

 
### ✅ **5. Datos y tipos especiales**

*   Columnas con **LOB** (TEXT, IMAGE, VARCHAR(MAX), VARBINARY(MAX)) pueden requerir manejo especial.
*   Si hay **FILESTREAM** o **FILETABLE**, el proceso es más complejo.
 

### ✅ **6. Espacio y rendimiento**

*   Copiar datos grandes puede bloquear la base por mucho tiempo.
*   Considera hacerlo en **bloques** (`INSERT ... SELECT` con TOP o usando `BULK INSERT`) para evitar transacciones enormes.

 
### ✅ **7. Transacciones y logs**

*   El movimiento genera muchas escrituras en el **transaction log**.
*   Si la tabla es muy grande, podrías necesitar aumentar el tamaño del log o usar **modo BULK\_LOGGED** para reducir impacto.
 

### ✅ **8. Dependencias externas**

*   Vistas, procedimientos almacenados, funciones que referencian la tabla deben revisarse.
*   Si cambias el nombre, actualiza dependencias.

 

### ✅ **9. Validación**

*   Después de mover, valida:
    *   Conteo de filas (`COUNT(*)`).
    *   Checksums o hash para asegurar integridad.
    *   Constraints y triggers funcionando.


 
