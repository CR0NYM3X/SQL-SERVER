### SABER INDEX DE UNA TABLA
SP_HELPINDEX 'TABLA' 

#  index faltantes que se deben de crear 
https://www.mssqltips.com/sqlservertip/1634/find-sql-server-missing-indexes-with-dmvs/

## Saber los indices y las columnas y si tiene algun  filtro where
```sql

 SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName,
    ic.key_ordinal AS ColumnOrder,
    ic.is_included_column AS IsIncludedColumn,
	i.filter_definition AS FilterDefinition
FROM
    sys.indexes AS i
    INNER JOIN sys.index_columns AS ic
        ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns AS c
        ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE
    i.object_id = OBJECT_ID('cenMaestroCodigo')
ORDER BY
    i.name,
    ic.key_ordinal;
```


## saber los indices faltantes 
```sql
SELECT
    migs.avg_total_user_cost * migs.avg_user_impact AS ImprovementMeasure,
    mid.[statement] AS TableName,
    mid.equality_columns AS EqualityColumns,
    mid.inequality_columns AS InequalityColumns,
    mid.included_columns AS IncludedColumns,
    migs.user_seeks,
    migs.user_scans,
    migs.last_user_seek,
    migs.last_user_scan
FROM
    sys.dm_db_missing_index_group_stats AS migs
    INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS mid
        ON mig.index_handle = mid.index_handle
WHERE
    mid.[statement] LIKE '%NombreTuTabla%'
ORDER BY
    ImprovementMeasure DESC;



SELECT
    'CREATE INDEX IDX_EQ_' + REPLACE(REPLACE(REPLACE(mid.[statement], '[', ''), ']', ''), ' ', '_') + '_' + CAST(mig.index_handle AS VARCHAR) + 
    ' ON ' + REPLACE(REPLACE(mid.[statement], '[', ''), ']', '') +
    ' (' + ISNULL(mid.equality_columns, '') + ')' +
    CASE WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' ELSE '' END AS CreateEqualityIndexStatement,
    
    'CREATE INDEX IDX_INEQ_' + REPLACE(REPLACE(REPLACE(mid.[statement], '[', ''), ']', ''), ' ', '_') + '_' + CAST(mig.index_handle AS VARCHAR) + 
    ' ON ' + REPLACE(REPLACE(mid.[statement], '[', ''), ']', '') +
    ' (' + ISNULL(mid.inequality_columns, '') + ')' +
    CASE WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' ELSE '' END AS CreateInequalityIndexStatement,
    
    migs.avg_total_user_cost * migs.avg_user_impact AS ImprovementMeasure,
    mid.[statement] AS TableName,
    mid.equality_columns AS EqualityColumns,
    mid.inequality_columns AS InequalityColumns,
    mid.included_columns AS IncludedColumns,
    migs.user_seeks,
    migs.user_scans,
    migs.last_user_seek,
    migs.last_user_scan
FROM
    sys.dm_db_missing_index_group_stats AS migs
    INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS mid
        ON mig.index_handle = mid.index_handle
WHERE
    mid.[statement] LIKE '%cenMaestroFamilias%'
ORDER BY
    ImprovementMeasure DESC;

 

ImprovementMeasure: Calcula una medida de mejora potencial multiplicando el costo total promedio del usuario por el impacto promedio del usuario. Esto te da una idea de cuánto podría mejorar el rendimiento si se implementa el índice faltante.
TableName: Muestra el nombre de la tabla donde se sugiere el índice faltante.
EqualityColumns: Lista las columnas que se utilizan en las condiciones de igualdad (=) en las consultas que podrían beneficiarse del índice.
InequalityColumns: Lista las columnas que se utilizan en las condiciones de desigualdad (<, >, !=, etc.) en las consultas que podrían beneficiarse del índice.
IncludedColumns: Muestra las columnas que se incluirían en el índice para cubrir las consultas, mejorando así el rendimiento sin necesidad de acceder a la tabla base.
user_seeks: Indica el número de veces que se ha buscado el índice faltante.
user_scans: Indica el número de veces que se ha escaneado el índice faltante.
last_user_seek: Muestra la última vez que se buscó el índice faltante.
last_user_scan: Muestra la última vez que se escaneó el índice faltante.



    ```
    

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
cuando tienes un index NONCLUSTERED y realizas una consulta usando la columna que tiene el index, en las estadistica sys.dm_db_index_usage_stats la columna user_seeks es la que se va ir llenando 
cuando tienes un NONCLUSTERED COLUMNSTORE  y realizas una consulta usando  mas de 2 o 3  columna que tiene el index, en las estadistica sys.dm_db_index_usage_stats la columna user_scans es la que se va ir llenando 

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

Índice sin INCLUDE: El primer índice mejora el rendimiento de la consulta al filtrar y ordenar por CustomerID y OrderDate. Sin embargo, si la consulta necesita otras columnas (OrderID, TotalAmount), SQL Server tendrá que acceder a la tabla base para obtener esos datos.


SELECT OrderID, OrderDate, TotalAmount FROM Orders WHERE CustomerID = 123 ORDER BY OrderDate;
CREATE INDEX IDX_Orders_CustomerID_OrderDate ON Orders (CustomerID, OrderDate) INCLUDE (OrderID, OrderDate, TotalAmount);
Índice con INCLUDE: El  índice cubre todas las columnas necesarias (OrderID, OrderDate, TotalAmount), lo que significa que SQL Server puede obtener todos los datos necesarios directamente del índice sin acceder a la tabla base, mejorando así el rendimiento.

```
 

### Para borrar un índice  

```sql
DROP INDEX [CONCURRENTLY] [IF EXISTS] nombre_del_indice [CASCADE | RESTRICT];
DROP INDEX idx_Combinado ON DESCRIPCION_ARTICULO;
```

- **CONCURRENTLY**: Permite eliminar el índice sin bloquear las operaciones concurrentes de selección, inserción, actualización y eliminación en la tabla del índice.
- **IF EXISTS**: Evita errores si el índice no existe.
- **CASCADE**: Elimina automáticamente los objetos que dependen del índice.
- **RESTRICT**: Impide la eliminación del índice si hay objetos que dependen de él (es la opción predeterminada).





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

user_seeks: Esta columna indica el número de veces que se ha buscado en el índice utilizando una operación de búsqueda específica.
Una búsqueda ocurre cuando se busca un valor específico en el índice utilizando una cláusula WHERE o una cláusula JOIN.

user_scans: Esta columna indica el número de veces que se ha escaneado el índice completo para recuperar datos. Un escaneo de índice
ocurre cuando SQL Server lee todo el índice para recuperar los datos necesarios, lo que puede ocurrir, por ejemplo, cuando no se
puede usar una búsqueda o cuando la cardinalidad de la consulta sugiere que un escaneo sería más eficiente que múltiples búsquedas individuales.

user_lookups: Esta columna indica el número de operaciones de búsqueda realizadas en una tabla después de que se ha realizado una
 búsqueda en el índice. Ocurre cuando la consulta necesita recuperar columnas adicionales que no están cubiertas por el índice y,
por lo tanto, necesita buscar en la tabla base.

user_updates: Esta columna indica el número de veces que se ha realizado una operación de actualización (INSERT, UPDATE, DELETE)
en la tabla y ha afectado al índice. Esto incluye tanto actualizaciones de datos en las columnas indexadas como cambios en las claves de los índices.
```

### Ver tamaño de indices 
```sql

------------ OPCION #1 -----------
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



# Identify SQL Server Indexes With Duplicate Columns 
```


select t1.tablename,t1.indexname,t1.columnlist,t2.indexname,t2.columnlist from
   (select distinct object_name(i.object_id) tablename,i.name indexname,
             (select distinct stuff((select ', ' + c.name
                                       from sys.index_columns ic1 inner join 
                                            sys.columns c on ic1.object_id=c.object_id and 
                                                             ic1.column_id=c.column_id
                                      where ic1.index_id = ic.index_id and 
                                            ic1.object_id=i.object_id and 
                                            ic1.index_id=i.index_id
                                      order by index_column_id FOR XML PATH('')),1,2,'')
                from sys.index_columns ic 
               where object_id=i.object_id and index_id=i.index_id) as columnlist
       from sys.indexes i inner join 
    	    sys.index_columns ic on i.object_id=ic.object_id and 
                                    i.index_id=ic.index_id inner join
            sys.objects o on i.object_id=o.object_id 
      where o.is_ms_shipped=0) t1 inner join
   (select distinct object_name(i.object_id) tablename,i.name indexname,
             (select distinct stuff((select ', ' + c.name
                                       from sys.index_columns ic1 inner join 
                                            sys.columns c on ic1.object_id=c.object_id and 
                                                             ic1.column_id=c.column_id
                                      where ic1.index_id = ic.index_id and 
                                            ic1.object_id=i.object_id and 
                                            ic1.index_id=i.index_id
                                      order by index_column_id FOR XML PATH('')),1,2,'')
                from sys.index_columns ic 
               where object_id=i.object_id and index_id=i.index_id) as columnlist
       from sys.indexes i inner join 
    	    sys.index_columns ic on i.object_id=ic.object_id and 
                                    i.index_id=ic.index_id inner join
            sys.objects o on i.object_id=o.object_id 
 where o.is_ms_shipped=0) t2 on t1.tablename=t2.tablename and 
       substring(t2.columnlist,1,len(t1.columnlist))=t1.columnlist and 
       (t1.columnlist<>t2.columnlist or 
         (t1.columnlist=t2.columnlist and t1.indexname<>t2.indexname))

https://www.mssqltips.com/sqlservertip/3604/identify-sql-server-indexes-with-duplicate-columns/
https://www.sqlservercentral.com/articles/finding-and-eliminating-duplicate-or-overlapping-indexes-1

```
#  Unused Indexes
```sql
use test_db
--- Índices que no se usan 

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    u.user_seeks,
    u.user_scans,
    u.user_lookups,
    u.user_updates
FROM 
    sys.indexes AS i
    LEFT JOIN sys.dm_db_index_usage_stats AS u ON i.object_id = u.object_id AND i.index_id = u.index_id AND u.database_id = DB_ID()
WHERE 
    i.is_primary_key = 0 AND i.is_unique = 0
    AND (u.user_seeks IS NULL AND u.user_scans IS NULL AND u.user_lookups IS NULL) 
        and  OBJECT_NAME(i.object_id)  in('test_table'
                        )
ORDER BY 
    OBJECT_NAME(i.object_id), i.name;
	
	
	https://www.mssqltips.com/sqlservertutorial/256/discovering-unused-indexes/
	https://www.mssqltips.com/sqlservertip/1545/deeper-insight-into-used-and-unused-indexes-for-sql-server/

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

 


