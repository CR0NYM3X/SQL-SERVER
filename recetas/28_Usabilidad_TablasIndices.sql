/* ****************************************************************************
** Script que obtiene la operaciones de lecura sobre tablas e indices de una 
** base de datos. Esto permite conocer la usabilidad que de dichos objetos.
** ************************************************************************* */

select 
	(select	sqlserver_start_time from sys.dm_os_sys_info)	as Hora_Inicio_Instancia,
	DB_NAME(st.database_id)		as Base_Datos,
    OBJECT_NAME(st.object_id)	as Objecto, 
	i.name						as Indice,
	i.type_desc					as Tipo_Indice,
	st.user_seeks				as Total_Consultas_Busqueda,
	st.user_scans				as Total_Consultas_Recorrido,
	st.user_lookups				as Total_Busques_Sistema,
	st.user_updates				as Total_consultas_Actualizacion,
	st.last_system_seek			as Hora_Ultima_Busqueda,
	st.last_system_scan			as Hora_ultima_recorrido,
	st.last_user_lookup			as Hora_ultima_buscqueda_sistema,
	st.last_system_update		as Hora_ultimo_Actualizacion
from sys.dm_db_index_usage_stats st
join sys.indexes i on i.index_id = st.index_id and i.object_id = st.object_id
where st.database_id = db_id();