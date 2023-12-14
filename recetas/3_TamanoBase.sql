SET NOCOUNT ON;
/* 
		Consulta: BPD-Tamaño_BD
La ejecución muestra el listado de Bases de Datos que se encuentran dentro de la instancia, consultando unicamente 
la capa de información propia de ésta. La consulta extrae la siguiente informacion: 
- Nombre de la base de datos
- Tamaño (en megas)
- Fecha de creacion

*/

select d.name Nombre_BD, str((sum(convert(dec(17,2),a.size)))/1024 / 128,10,2) Tamano_GB, convert(nvarchar(11), d.crdate) Fecha_Creacion, @@VERSION as Version
from sys.master_files a 
inner join master.dbo.sysdatabases d on (a.database_id = d.dbid)
group by d.dbid, d.name, d.crdate