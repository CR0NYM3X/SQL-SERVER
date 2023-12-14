SET NOCOUNT ON;

/* 
		Consulta: BPD-Fragmentacion_indices
La ejecución muestra el listado de los indices que se encuentran fragmentados, derivado a los constantes movimientos 
que existen en la operacion dentro de la base de datos, consultando unicamente la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Script_Fragmentacion
- Tabla
- Registros
- Porcentaje_Fragmentacion		

*/

DECLARE @temp table (id int, 
objeto int, 
Indice varchar(256), 
Tabla varchar(256), 
Registros bigint )
DECLARE @query1 nvarchar(max) 
DECLARE @query2 nvarchar(max) 
DECLARE @st datetime 
Declare @database_id INT 


set @database_id = DB_ID()
SET @st = getdate() 
INSERT INTO @temp 
select i.index_id as id, o.object_id as objeto,i.name as Indice, o.name as Nombre_Tabla, SUM(row_count) as Registros 
from sys.indexes as i with(nolock) 
join sys.objects as o with(nolock) on i.object_id=o.object_id 
join sys.dm_db_partition_stats as p with(nolock) on p.object_id=o.object_id 
where i.name is not NULL 
and o.type = 'U' and 
(p.index_id=0 or p.index_id=1) 
group by o.name, i.name, o.object_id, i.object_id, i.index_id 
ORDER BY Registros ASC 

--REORGANIZE O REBUILD
SELECT 'ALTER INDEX '  +Indice+  ' ON ['+ OBJECT_SCHEMA_NAME(objeto)+'].['+Tabla+'] REORGANIZE'+  '    --' + CAST(Registros AS CHAR(20)) 
as Script_Fragmentacion, Tabla, Registros, CAST(a.avg_fragmentation_in_percent AS CHAR(20)) as Porcentaje_Fragmentacion 
FROM @temp 
join sys.dm_db_index_physical_stats (@database_id, NULL, NULL, NULL, NULL) as a on object_id=objeto and a.index_id=id 
where a.avg_fragmentation_in_percent between 5 and 100 
order by Registros asc