SET NOCOUNT ON;

/* 
		Consulta: BPD-Detalle_Constraints
La ejecución muestra el listado de los contraints y el nombre de la tabla a la que pertenece y su relacion con las otras tablas, consultando unicamente 
la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Nombre_Esquema
- Nombre_Constraint
- Tabla_PK
- Columna_PK		
- Tabla_PK
- Columna_FK		
*/

SELECT t3.name AS Nombre_Esquema, t1.name AS Nombre_Constraint, t2.name AS Tabla_FK, t4.name AS Columna_FK, t5.name AS Tabla_PK, t6.name AS Columna_PK
FROM sys.foreign_key_columns t0
INNER JOIN sys.objects t1 ON t0.constraint_object_id = t1.object_id
INNER JOIN sys.tables t2 ON t0.parent_object_id = t2.object_id 
INNER JOIN sys.schemas t3 ON t2.schema_id = t3.schema_id
INNER JOIN sys.columns t4 ON t4.column_id = parent_column_id AND t4.object_id = t2.object_id
INNER JOIN sys.tables t5 ON t0.referenced_object_id = t5.object_id
INNER JOIN sys.columns t6 ON t6.column_id = referenced_column_id AND t6.object_id = t5.object_id
ORDER BY 1