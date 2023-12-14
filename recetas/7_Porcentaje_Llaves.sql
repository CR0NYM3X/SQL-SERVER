SET NOCOUNT ON;

/* 
		Consulta: BPD-Porcentaje_Llaves
La ejecución muestra el porcentaje sobre el total del numero de llaves, el porcentaje de tablas que si se tienen y los que
no, consultando unicamente la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Total_tablas_BD
- Tablas_sin_Llave
- Porcentaje_Sin_Llaves

*/

select tot_tab.A as 'Total_tablas_BD',
		Tablas_sin_FK.B 'Tablas_sin_Llave',
       round(((Tablas_sin_FK.B * 100)/ tot_tab.A),3) as  'Porcentaje_Sin_Llaves', 'Llave Foranea' as Tipo
from (select count(*) A
        from sys.tables 
		where name not in (select name
		                     from sys.system_objects
							where type = 'U')
		and schema_id <> 4 )tot_tab,
     (select count(*) B
        from sys.tables 
       where name not in (select name
		                     from sys.system_objects
							where type = 'U')
		 and schema_id <> 4
	     and object_id not in (select parent_object_id
                                 from sys.foreign_key_columns))Tablas_sin_FK
union all
select  tot_tab.A, Tablas_sin_PK.B,
       round(((Tablas_sin_PK.B * 100)/ tot_tab.A),3) as 'Porcentaje', 'Llave Primaria' as Tipo
from (select count(*) A
        from sys.tables
	   where name not in (select name
		                    from sys.system_objects
						   where type = 'U')
		 and schema_id <> 4)tot_tab,
     (select count(distinct tab.name) B
        from sys.tables tab
       where tab.object_id not in (select c.parent_obj 
                                     from sys.sysobjects c
			         			    where c.xtype = 'PK')
         and tab.name not in (select name
                                from sys.system_objects
	    		      	       where type = 'U')
         and schema_id <> 4)Tablas_sin_PK
union all
select tot_tab.A, Tablas_sin_idx.B,
	   round(((Tablas_sin_idx.B * 100)/ tot_tab.A),3) as 'Porcentaje', 'Indices' as Tipo
from (select count(*) A
        from sys.tables
	   where name not in (select name
		                    from sys.system_objects
						   where type = 'U') 
		 and schema_id <> 4)tot_tab,
     (select count(object_id) B
from sys.objects o
where o.type = 'U'
and schema_name(schema_id) not like 'sys%'
and object_id not in (select id.object_id
                        from sys.indexes id
                       where id.is_primary_key = 0))Tablas_sin_idx;
