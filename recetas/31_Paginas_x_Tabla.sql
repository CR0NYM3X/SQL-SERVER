SELECT t.name as Tabla , p.partition_id as ID_Particion, p.partition_number as Numero_Particion, p.rows as Filas,
	au.type_desc as Tipo_Pagina, au.total_pages as Total_Paginas, au.used_pages as Paginas_Usadas, au.data_pages as Paginas_Con_Datos
FROM sys.allocation_units au
join sys.partitions  p on p.partition_id =au.container_id
join sys.tables t on t.object_id = p.object_id
where SCHEMA_NAME(t.schema_id) <> 'sys'