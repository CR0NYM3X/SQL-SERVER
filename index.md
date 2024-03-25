######  ejemplos  de uso
```
-- Crear la tabla Clientes
CREATE TABLE Clientes (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50),
    Apellido NVARCHAR(50),
    Email NVARCHAR(100),
    Telefono NVARCHAR(20)
);

-- Crear el índice no agrupado en la columna Email
CREATE INDEX IX_Clientes_Email ON Clientes (Email);

-- Insertar algunos registros en la tabla
INSERT INTO Clientes (Nombre, Apellido, Email, Telefono) VALUES
('Juan', 'Pérez', 'juan@example.com', '123-456-7890'),
('María', 'Gómez', 'maria@example.com', '456-789-0123'),
('Pedro', 'Martínez', 'pedro@example.com', '789-012-3456');
```

### Recomendaciones para el uso de index

1.- Eliminar indices duplicados o Redundantes, indices que usen las mismas columnas  <br>
2.- No usar mas indices que columnas <br>
3.- Evitar tablas sin indices clustered/agrupados  o almenos un indice unico<br>
4.- Mantener actualizadas las estadisticas <br>
5.- limitar la fragmentacion de indices <br>
6.- no usar SET NOCOUNT ON <br>
7.-  usar Database Tuning Advisor (DETA) 

### Forzar a un cliente usar index 
```sql
select *from Clientes  
 WITH (INDEX(IX_Clientes_Email))
where
email='juan@example.com';
```

### Cosas importantes de los Index  
```sql
Páginas (Pages): En SQL Server, los datos de la tabla y los índices se organizan en páginas. Una página es una unidad de almacenamiento básica que contiene un número fijo de bytes (normalmente 8 KB).

Filas (Rows): Además de las páginas, los datos de los índices también se almacenan en filas, especialmente en índices de clúster, donde las filas de datos se organizan directamente según el orden del índice.


---- estructura de árbol utilizada para almacenar los datos del índice en el disco.
Árbol B: Un árbol B es una estructura de datos en la que cada nodo puede tener varios hijos y cada hijo está asociado con un rango de valores de índice. En un índice B, las hojas del árbol contienen las claves del índice y los punteros a las ubicaciones físicas de los datos en la tabla. Este tipo de estructura de árbol permite búsquedas eficientes en un rango de valores, lo que es útil para consultas que utilizan operaciones de comparación como mayor que o menor que.

Árbol B+: Un árbol B+ es una variación del árbol B en el que todas las claves del índice se almacenan en las hojas del árbol, mientras que los nodos internos solo contienen punteros a las claves de los hijos. Esto permite un acceso más rápido a las claves del índice, ya que las búsquedas solo necesitan atravesar las hojas del árbol. Además, los árboles B+ suelen estar optimizados para la lectura, lo que los hace ideales para los índices de SQL Server.

```

### Tipos de index 
```sql
El índice HEAP, de identifican como indexID = 0  y no tienen nombre se utiliza cuando no se define ningún índice en la tabla o cuando no hay una clave primaria o clave única definida en la tabla
, las filas se almacenan en cualquier orden en las páginas de datos de la tabla. desventajas :
No hay ordenamiento específico:
endimiento de lectura y escritura: 
Espacio de almacenamiento
Fragmenación

Indice de clúster (Clustered Index): Este tipo de índice ordena físicamente las filas de la tabla en función de los valores de la(s) columna(s) clave del índice. Cada tabla puede tener solo un índice de clúster, ya que determina el orden físico de los datos en la tabla misma.

Índice no agrupado (Non-clustered Index): A diferencia del índice de clúster, el índice no agrupado no afecta el orden físico de las filas en la tabla. En cambio, crea una estructura de índice separada que contiene las claves del índice y los punteros a las filas de datos correspondientes.

Índice único (Unique Index): Este tipo de índice garantiza que los valores de las columnas incluidas en el índice sean únicos en toda la tabla. Puede ser un índice de clúster o no agrupado.

Índice de texto completo (Full-Text Index): Este tipo de índice se utiliza para buscar texto completo dentro de columnas de caracteres grandes (como VARCHAR o TEXT). Proporciona capacidades de búsqueda avanzadas, incluida la búsqueda de palabras clave, frases y sinónimos.

Índice espacial (Spatial Index): Se utiliza para optimizar consultas que involucran datos espaciales, como coordenadas geográficas o polígonos. Estos índices permiten realizar operaciones espaciales eficientes, como búsquedas por proximidad o análisis de áreas geográficas.

Índice filtrado (Filtered Index): Este tipo de índice se crea con una cláusula WHERE para filtrar las filas que se incluirán en el índice. Pueden mejorar el rendimiento de las consultas al reducir el tamaño del índice y enfocarse en un subconjunto específico de datos.

Índice de columnas incluidas (Included Column Index): Este tipo de índice permite incluir columnas adicionales (no claves) en el índice para cubrir consultas y mejorar el rendimiento sin agregarlas a la clave del índice.
```

### Borrar indices 
```sql
DROP INDEX idx_Combinado ON DESCRIPCION_ARTICULO;
```

####  saber la fragmentacion de los index y el uso de los index  
```sql

SELECT 
    OBJECT_NAME(s.[object_id]) AS [Object Name],
    i.name AS [Index Name],
    i.index_id AS [Index ID],
	i.type_desc,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
	ps.avg_fragmentation_in_percent AS Fragmentacion_Porcentaje
FROM 
    sys.dm_db_index_usage_stats s
INNER JOIN 
    sys.indexes i ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
LEFT JOIN  sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ps ON ps.[object_id] = s.[object_id] AND ps.index_id = s.index_id
WHERE 
    OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
    AND s.database_id = DB_ID()
   -- and i.type_desc not in('CLUSTERED','HEAP') --- estos no se deben de dejar ya que heap es porque la tabla no tiene index y el clustered nunca se elimina 
   -- AND (s.user_seeks = 0 or  s.user_scans= 0 or s.user_lookups = 0   ) 
ORDER BY 
    s.user_updates DESC;



Ref: https://www.mssqltips.com/sqlservertip/1239/how-to-get-index-usage-information-in-sql-server/ 
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-usage-stats-transact-sql?view=sql-server-ver16

user_scans: el número de escaneos realizados por la consulta del usuario.
user_seeks: el número de búsquedas realizadas por la consulta del usuario.
user_lookups: el número de búsquedas de marcadores realizadas por la consulta del usuario.
user_updates: el número de actualizaciones realizadas por la consulta del usuario. Esto representa la cantidad de inserciones, eliminaciones y actualizaciones en lugar de la cantidad real de filas afectadas. Por ejemplo, si elimina 1000 filas en una declaración, este recuento se incrementa en 1.


user_seeks: número de búsquedas de índice
user_scans: número de escaneos de índice
user_lookups: número de búsquedas de índice
user_updates: número de operaciones de inserción, actualización o eliminación
```

### Ver tamaño de indices 
```sql

------------ OPCION #1 -----------
SELECT 
	s.object_id as  idx_obj_id,
	db_name() db,
	OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
	OBJECT_NAME(i.OBJECT_ID) AS TableName,
	COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
	i.[name] AS IndexName,
	i.type_desc AS IndexType,
	i.index_id AS IndexID,
	SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id] AND s.[index_id] = i.[index_id]
	LEFT JOIN  sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
where  i.name is not null    -- and  OBJECT_NAME(i.OBJECT_ID) = 'clientes'
GROUP BY i.[name],s.object_id,i.OBJECT_ID,i.index_id , ic.column_id , ic.object_id , i.type_desc   

------------ OPCION #2 -----------
SELECT
OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
OBJECT_NAME(i.OBJECT_ID) AS TableName,
i.name AS IndexName,
i.is_primary_key ,
i.index_id AS IndexID,
8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
where i.name is not null and i.is_primary_key  = 0 and i.name = 'idx_iNum_Empleado' 
GROUP BY i.OBJECT_ID,i.index_id,i.name, i.is_primary_key  
ORDER BY OBJECT_NAME(i.OBJECT_ID),i.index_id 
```

###  saber los update,delete, insert de una tabla 
```sql



SELECT
	db_name (a.database_id),
    OBJECT_NAME(a.object_id) AS Nombre_Tabla,
	index_type_desc,
   leaf_insert_count AS Total_Inserts,
   leaf_delete_count AS Total_Updates,
   leaf_update_count AS Total_Deletes
   ,ps.avg_fragmentation_in_percent AS Fragmentacion_Porcentaje
 
FROM 
    sys.dm_db_index_operational_stats(DB_id(), NULL, NULL, NULL) a
LEFT JOIN  sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ps ON ps.[object_id] = a.[object_id] AND ps.index_id = a.index_id
	where    OBJECT_NAME(a.object_id) = 'ropa'
group by  a.database_id , a.object_id , leaf_insert_count , leaf_delete_count  , leaf_update_count   ,ps.avg_fragmentation_in_percent ,	index_type_desc
```




### VEr los indices que existen y los primari key
```sql
SELECT 
    i.name AS IndexName,
	 OBJECT_NAME( i.object_id) OBJETO,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    c.name AS ColumnName,
	ic.is_descending_key AS IsDescending
FROM 
    sys.indexes i
INNER JOIN 
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN 
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
INNER JOIN 
	 sys.tables f on f.object_id = i.object_id
-- WHERE  i.object_id = OBJECT_ID('DESCRIPCION_ARTICULO')  

```



# tipos de indices 

```SQL
/* 1.- Indices Agrupados : Cada tabla puede tener solo un índice agrupado y se recomiendo que la columna sea un id auto incremental, es importante
indicar que cuando en una tabla se asigna un primary key esto genera en automatico un indice agrupado, por lo que ya no se puede generar otro, si quieres  intentar  tendras este error:
"Cannot create more than one clustered index on table 'DESCRIPCION_ARTICULO'. Drop the existing clustered index 'PK__DESCRIPC__38BC645844CA3770' before creating another." */

CREATE CLUSTERED INDEX IX_IndiceAgrupado ON EjemploTabla(ID);


/* 2.- Indices filtrados: */
CREATE  INDEX idx_DosColumnas2 ON DESCRIPCION_ARTICULO(ID_Descripcion) where id_articulo_2 = 1 ;


/* 3.- Indices no agrupados */ 
CREATE  INDEX idx_Combinado ON DESCRIPCION_ARTICULO (ID_Articulo_2 desc ) INCLUDE (Detalles desc );
SELECT Detalles FROM DESCRIPCION_ARTICULO WHERE ID_Articulo_2 = 'valor_buscado';

/* Este tipo de índice se conoce como un índice combinado o multicolumna,
lo que significa que se indexarán ambas columnas y se utilizarán para optimizar consultas que involucren esas columnas. */
CREATE  INDEX idx_Combinado ON DESCRIPCION_ARTICULO (ID_Articulo_2, Detalles);
SELECT * FROM DESCRIPCION_ARTICULO WHERE ID_Articulo_2 = 'valor_1' AND Detalles = 'detalle_buscado';

/* 4.-  índice de almacén de columnas no agrupado:
 organiza los datos por columnas en lugar de por filas
*/ 
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_ColumnStore_Ventas ON Ventas (Fecha, ProductoID, Monto);

SELECT ProductoID, SUM(Monto) FROM Ventas WHERE Fecha BETWEEN '2023-01-01' AND '2023-12-31' GROUP BY ProductoID;



https://learn.microsoft.com/es-es/sql/relational-databases/indexes/indexes?view=sql-server-ver16
https://javiersql.wordpress.com/2017/12/04/sql-server-tipos-de-indices-en-sql-server/
```

https://soportesql.wordpress.com/2016/07/29/columnstore-indexes-en-sql-server/ <br>
https://learn.microsoft.com/es-es/sql/relational-databases/indexes/columnstore-indexes-overview?view=sql-server-ver16<br>
https://learn.microsoft.com/es-es/sql/t-sql/statements/create-columnstore-index-transact-sql?view=sql-server-ver16<br>

# Bibliografías  

**Recomendaciones de indices**<br>
https://es.stackoverflow.com/questions/34214/cual-es-la-mejor-pr%C3%A1ctica-para-crear-un-index-en-sql-server  <br>
https://www.datanumen.com/es/Blogs/indexing-best-practices-sql-server-cartilla/<br>
https://dbadixit.com/10-consejos-practicos-indices-sql-server/<br>

`Optimización del mantenimiento de índices para mejorar el rendimiento de las consultas y reducir el consumo de recursos:` https://learn.microsoft.com/es-es/sql/relational-databases/indexes/reorganize-and-rebuild-indexes?view=sql-server-ver16<br>
https://denissecalderon.com/blog/sql-server-cuales-son-buenas-practicas-en-consultas-sql-para-desarrolladores/<br>

**Funcionamiento de los indices:**<br> https://dbadixit.com/indices-cluster-en-sql-server/

 


