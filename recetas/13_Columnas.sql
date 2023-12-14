SET NOCOUNT ON;

/* 
		Consulta: BPD-Columnas
La ejecución extrae el detalle de cada columna que se encuentra dentro de la Base de Datos, consultando unicamente 
la capa de información propia de ésta. La consulta extrae la siguiente informacion: 
- Esquema
- Tabla	
- Columna	
- Llave_Primaria	
- Llave_Foranea	
- Indices	
- Contraints	
- Tipo_Dato	
- Longitud	
- Valor_Default	
- Acepta_Nulo	
- Column_id
*/

select distinct SCHEMA_NAME(t0.schema_id) as Esquema, t0.name as Tabla, t1.name as Columna
,isnull(t3.name,'') as Llave_Primaria
,isnull(t5.name,'') as Llave_Foranea

,isnull(STUFF ((SELECT '; ' + tb.name from sys.index_columns ta
inner join sys.indexes tb on ta.index_id = tb.index_id and t0.object_id = ta.object_id and t0.object_id = tb.object_id and t1.column_id = ta.column_id
where tb.is_primary_key = 0 and tb.is_unique_constraint = 0 FOR XML PATH('')), 1, 1, ''),'') AS Indices

,isnull(STUFF ((SELECT '; ' + tc.name from sys.check_constraints tc where t0.object_id = tc.parent_object_id and t1.column_id = tc.parent_column_id  
FOR XML PATH('')), 1, 1, '') ,'') +
isnull(STUFF ((SELECT '; ' + te.name from sys.index_columns td
inner join sys.key_constraints te on td.index_id = te.unique_index_id and t0.object_id = td.object_id and t0.object_id = te.parent_object_id and t1.column_id = td.column_id
where te.type <> 'pk' FOR XML PATH('')), 1, 1, ''),'') AS Contraints
,t6.DATA_TYPE as Tipo_Dato
,t6.CHARACTER_MAXIMUM_LENGTH as Longitud
,replace(t6.COLUMN_DEFAULT, ',', ';') as Valor_Default
,case when t6.IS_NULLABLE = 'YES' then 'SI' else 'NO' end as Acepta_Nulo
,t1.column_id
from sys.tables t0
inner join sys.columns t1 on t0.object_id = t1.object_id
left join sys.index_columns t2 on t0.object_id = t2.object_id and t1.column_id = t2.column_id and t2.index_id = 1
left join sys.indexes t3 on t3.is_primary_key = 1 and t0.object_id = t3.object_id and t2.index_id = t3.index_id
left join sys.foreign_key_columns t4 on t0.object_id = t4.parent_object_id and t1.column_id = t4.parent_column_id
left join sys.foreign_keys t5 on t0.object_id = t5.parent_object_id and t5.object_id = t4.constraint_object_id
inner join INFORMATION_SCHEMA.COLUMNS t6 on SCHEMA_NAME(t0.schema_id) = t6.TABLE_SCHEMA and t0.name = t6.TABLE_NAME and t1.name = t6.COLUMN_NAME
order by 1, 2, t1.column_id