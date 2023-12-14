SET NOCOUNT ON;

/* 
		Consulta: Inventario Objetos
La ejecución del inventario de objetos son lecturas que extraen informacion de la estructura de la Base de Datos 
consultando la capa de información propia de ésta. La consulta extrae la siguiente informacion: 
- Esquema
- Nombre (nombre del objeto)
- Tipo_Objeto
- Descripcion_Tipo_Objeto
- Fecha_Creacion
- Fecha_Modificacion
- Parametros (de las funciones/procedimientos)
*/


declare @Tabla table(Esquema varchar(MAX), Nombre varchar(MAX), Tipo varchar(MAX), Descripcion_Tipo_Objeto varchar(MAX), Fecha_Creacion datetime, Fecha_Modificacion datetime, Parametros varchar(MAX))

insert into @Tabla
select SCHEMA_NAME(schema_id) as Esquema, name Nombre, type Tipo_Objeto, 
type_desc Descripcion_Tipo_Objeto, create_date Fecha_Creacion, modify_date Fecha_Modificacion,
STUFF
((SELECT        '; ' + t2.name+' '+t3.name+'('+convert(varchar,t2.max_length)+')'
from sys.parameters t2 inner join sys.types t3 on t0.object_id = t2.OBJECT_ID and t2.system_type_id = t3.system_type_id  FOR XML PATH('')), 1, 1, '') AS Parametros
from sys.objects t0
where SCHEMA_NAME(schema_id) <> 'sys'
order by 1, 2;

insert into @Tabla
SELECT 'dbo', isnull(msdb.dbo.backupset.name, 'SN') AS Nombre_Backup, 'BK', 'BACKUP', msdb.dbo.backupset.backup_start_date Fecha_Inicio, 
msdb.dbo.backupset.backup_finish_date Fecha_Termino, NULL
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
order by 1, 2;

insert into @Tabla
select 'dbo', REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name,CHaR(10),' ') ,CHaR(13),' ') ,' ',' '),'          ', ' '),',',';'), 'JOB', 'JOB', date_created, date_modified, NULL from msdb.dbo.sysjobs
order by 1, 2;

select * from @Tabla