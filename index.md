### Recomendaciones para el uso de index

1.- Eliminar indices duplicados o Redundantes, indices que usen las mismas columnas  <br>
2.- No usar mas indices que columnas <br>
3.- Evitar tablas sin indices clustered/agrupados  o almenos un indice unico<br>
4.- Mantener actualizadas las estadisticas <br>
5.- limitar la fragmentacion de indices <br>
6.- no usar SET NOCOUNT ON <br>
7.-  usar Database Tuning Advisor (DETA) 

#### Obtener indices que no se usan 
```sql
SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
         I.[NAME] AS [INDEX NAME], 
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 /*se excluyan las tablas del sistema.*/



SELECT 
    OBJECT_NAME(s.[object_id]) AS [Object Name],
    i.name AS [Index Name],
    i.index_id AS [Index ID],
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM 
    sys.dm_db_index_usage_stats s
INNER JOIN 
    sys.indexes i ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
WHERE 
    OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
    AND s.database_id = DB_ID()
    AND (s.user_seeks = 0 or  s.user_scans= 0 or s.user_lookups = 0   ) 
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

 


