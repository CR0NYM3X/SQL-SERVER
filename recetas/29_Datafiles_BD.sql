/* ****************************************************************************
**
** ************************************************************************* */

select
	db.name as BaseDatos
	,fg.name as FileGroup
	,mf.name as ArchivoLogico
	,mf.physical_name as ArchivoFisico
	,mf.type_desc as TipoArchivo
	,mf.state_desc as EstatusArchivo
	,(mf.size/1024) as MB
from sys.databases db
inner join sys.master_files mf on mf.database_id = db.database_id
left join sys.data_spaces ds on ds.data_space_id = mf.data_space_id
left join sys.filegroups fg on fg.data_space_id = ds.data_space_id