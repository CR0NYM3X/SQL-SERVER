SET NOCOUNT ON;

/* 
		Consulta: BPD-Tamaño_Tablas
La ejecución muestra el listado de todas las tablas que se encuentran dentro de la Base de Datos, consultando unicamente 
la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Nombre_Esquema
- Nombre_Tabla
- Numero_Registros
- MB_Totales		

*/

SELECT
s.Name AS Nombre_Esquema,
t.Name AS Nombre_Tabla,
p.rows AS Numero_Registros,
CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS MB_Totales
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
GROUP BY t.Name, s.Name, p.Rows
ORDER BY s.Name, t.Name