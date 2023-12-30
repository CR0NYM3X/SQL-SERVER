### Recomendaciones para el uso de index

1.- Eliminar indices duplicados o Redundantes, indices que usen las mismas columnas  <br>
2.- No usar mas indices que columnas <br>
3.- Evitar tablas sin indices clustered/agrupados  o almenos un indice unico<br>
4.- Mantener actualizadas las estadisticas <br>
5.- limitar la fragmentacion de indices <br>
6.- no usar SET NOCOUNT ON <br>
7.-  usar Database Tuning Advisor (DETA) 



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

### Crear indices 

```sql
CREATE  INDEX idx_Combinado ON DESCRIPCION_ARTICULO (ID_Articulo_2 desc ) INCLUDE (Detalles desc );
CREATE  INDEX idx_Combinado ON DESCRIPCION_ARTICULO (ID_Articulo_2, Detalles);

CREATE CLUSTERED INDEX idx_DosColumnas2 ON DESCRIPCION_ARTICULO ( ID_Articulo_2 desc);

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_ColumnStore_Ventas
ON Ventas (Fecha, ProductoID, Monto);

```
https://soportesql.wordpress.com/2016/07/29/columnstore-indexes-en-sql-server/ <br>
https://learn.microsoft.com/es-es/sql/relational-databases/indexes/columnstore-indexes-overview?view=sql-server-ver16<br>
https://learn.microsoft.com/es-es/sql/t-sql/statements/create-columnstore-index-transact-sql?view=sql-server-ver16<br>


# tipos de indices 

```
1.- Indices Agrupados : Cada tabla puede tener solo un índice agrupado y se recomiendo que la columna sea un id auto incremental, es importante
indicar que cuando en una tabla se asigna un primary key esto genera en automatico un indice agrupado, por lo que ya no se puede generar otro, si quieres  intentar  tendras este error:
"Cannot create more than one clustered index on table 'DESCRIPCION_ARTICULO'. Drop the existing clustered index 'PK__DESCRIPC__38BC645844CA3770' before creating another."

CREATE CLUSTERED INDEX IX_IndiceAgrupado ON EjemploTabla(ID);


2.- Indices filtrados: 

CREATE  INDEX idx_DosColumnas2 ON DESCRIPCION_ARTICULO(ID_Descripcion) where id_articulo_2 = 1 ;

```

# Bibliografías  

**Recomendaciones de indices**<br>
https://es.stackoverflow.com/questions/34214/cual-es-la-mejor-pr%C3%A1ctica-para-crear-un-index-en-sql-server  <br>
https://www.datanumen.com/es/Blogs/indexing-best-practices-sql-server-cartilla/<br>
https://dbadixit.com/10-consejos-practicos-indices-sql-server/<br>

`Optimización del mantenimiento de índices para mejorar el rendimiento de las consultas y reducir el consumo de recursos:` https://learn.microsoft.com/es-es/sql/relational-databases/indexes/reorganize-and-rebuild-indexes?view=sql-server-ver16<br>
https://denissecalderon.com/blog/sql-server-cuales-son-buenas-practicas-en-consultas-sql-para-desarrolladores/<br>

**Funcionamiento de los indices:**<br> https://dbadixit.com/indices-cluster-en-sql-server/

 


