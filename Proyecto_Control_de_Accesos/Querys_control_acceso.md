
# Objetivo:
Es obtener todos los usuarios con privilegios elevados que puedan realizar algún daño a las base de datos, y presentar esta información a los dueños del servidor y soliciten la degradación de los usuarios 

```SQL
/*********************************************************************
******************* # DATOS DEL SERVIDOR #****************************
*** @ Objetivo -> Obtener las característica del servidor como ******
***			IP, hostname, versión, Edicion, cnt_db				******
**********************************************************************/

select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER, @@SERVERNAME hostname, (SELECT SUBSTRING(@@version, 1, CHARINDEX( CHAR(10), @@version) - 1) ) version, SERVERPROPERTY('Edition') Edicion , (select count(*)  from sys.databases where database_id > 4 ) cnt_db






/***************************************************************************************************************
******************* 		PERMISOS PREDIFINIDOS, ROLES NIVEL SERVIDOR         	********************************

 @Columnas: IP_SERVER, name, is_disabled ,sysadmin ,securityadmin ,serveradmin ,setupadmin ,processadmin 
 ,diskadmin ,dbcreator ,bulkadmin
 
 @Descripción: Estos permisos son a nivel servidor y manera global, otorga permisos para la administración del servidor 
 como la creacion de base de datos , modificación de usuarios o login , hacer monitoreo del servidor
 
 1.- sysadmin: Este rol otorga los máximos privilegios a nivel de servidor, permitiendo a los usuarios realizar 
 cualquier acción en el servidor. Este rol incluye todos los demás roles de servidor.
 
 2.- securityadmin: Este rol se enfoca en la administración de la seguridad, permitiendo a los usuarios agregar
 y quitar inicios de sesión, roles y permisos de usuario. Otorgar este rol a un usuario no considerado podría 
 resultar en cambios indebidos en la seguridad.
 
 3.- serveradmin: Este rol tiene permisos para configurar opciones del servidor y realizar tareas administrativas 
 a nivel de servidor, pero no tiene todos los privilegios del "sysadmin". Puede ser riesgoso si se otorga a 
 usuarios no considerados, ya que aún pueden realizar cambios significativos.

 4.- setupadmin: Este rol tiene la capacidad de gestionar la instalación y configuración del servidor. Otorgar 
 este permiso a un usuario no considerado podría resultar en cambios no deseados en la configuración del servidor.

 5.- processadmin: Los miembros de este rol pueden terminar procesos en el servidor. Otorgar este permiso a 
 usuarios no confiables podría afectar negativamente el rendimiento del servidor si se terminan procesos importantes.

 6.- dbcreator: Este rol tiene la capacidad de crear, modificar y eliminar bases de datos en el servidor. Otorgar
 este permiso a un usuario no considerado podría resultar en la creación inadvertida o eliminación de bases de datos esenciales.
 
 7.- diskadmin: Los miembros de este rol tienen permisos para gestionar archivos y directorios en el disco duro.
 Esto incluye la capacidad de agregar o quitar archivos de bases de datos y cambiar ubicaciones de archivos. 
 Otorgar este rol a un usuario no considerado podría afectar negativamente la estructura y la integridad de 
 los archivos de la base de datos.

 8.- bulkadmin: Este rol permite a los usuarios realizar operaciones de carga masiva de datos. Conceder este 
 permiso a usuarios no confiables podría resultar en la manipulación masiva de datos.
 

****************************************************************************************************************/

select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER, a.name,b.is_disabled 
,a.sysadmin
,a.securityadmin
,a.serveradmin
,a.setupadmin
,a.processadmin
,a.diskadmin
,a.dbcreator
,a.bulkadmin
from sys.syslogins as a
inner join master.sys.server_principals as b on a.name = b.name
where a.name not like '##%' and a.name not like 'NT %' and a.name not in ('sa') /*Aqui agregan los usuarios que no quieren escanear*/
and a.sysadmin = 1 
or a.securityadmin = 1
 or a.serveradmin = 1 
 or a.setupadmin = 1 
 or a.processadmin = 1 
 or a.diskadmin = 1 
 or a.dbcreator = 1 
 or a.bulkadmin = 1 
order by a.name 
	
	



/*******************************************************************************************************************
******************* 		PERMISOS PREDIFINIDOS, ROLE NIVEL BASE DE DATOS    	 	********************************

  @Columnas: IP_SERVER ,db  ,usuario, is_disabled  , db_accessadmin ,db_backupoperator ,db_datareader 	
   ,db_datawriter 	,db_ddladmin ,db_owner ,db_securityadmin 

  @Descripción: Estos permisos son a nivel base de datos, contienen permisos que permiten la manipulación 
  de los objetos (Tablas,Funciones, Procedimientos, Vistas) especificamente en la base de datos que se otroge 
  este permiso. 
 
  1.- db_accessadmin: Los miembros de este rol tienen permisos para gestionar el acceso a la base de datos.
  Pueden agregar o quitar inicios de sesión y roles de la base de datos.
  
  2.- db_backupoperator: Este rol permite a los usuarios realizar operaciones de copia de seguridad de 
  la base de datos. Pueden realizar copias de seguridad y restauraciones, pero no tienen 
  control total sobre la base de datos.
  
  3.- db_datareader: Los usuarios de este rol pueden leer cualquier dato en todas las tablas de la base de datos. 
  Sin embargo, no pueden realizar modificaciones en los datos.

  4.- db_datawriter: Los miembros de este rol pueden realizar operaciones de escritura, como agregar, 
  modificar o eliminar datos en todas las tablas de la base de datos.

  5.- db_ddladmin: Este rol proporciona permisos para realizar operaciones de definición de datos (DDL), 
  como crear, modificar o eliminar objetos de la base de datos. Los usuarios con este rol pueden, por ejemplo,
  crear o eliminar tablas y procedimientos almacenados.

 
  6.- db_owner: Los miembros de este rol tienen control total sobre la base de datos. Pueden realizar cualquier acción, 
  incluyendo la modificación de la estructura de la base de datos, la adición o eliminación de objetos y 
  la asignación de permisos.
 
  7.- db_securityadmin: Los miembros de este rol tienen la capacidad de gestionar roles de seguridad y permisos en 
  la base de datos. Pueden asignar permisos a otros usuarios y roles, lo que les otorga un control considerable 
  sobre la seguridad a nivel de base de datos.


********************************************************************************************************************/


CREATE TABLE #userpriv (
	IP_SERVER VARCHAR(200),
	db VARCHAR(200),
    usuario VARCHAR(200),
    db_accessadmin BIT
	,db_backupoperator BIT
	,db_datareader BIT
	,db_datawriter BIT
	,db_ddladmin BIT
--	,db_denydatareader BIT
--	,db_denydatawriter BIT
	,db_owner BIT
	,db_securityadmin BIT
);



execute SYS.sp_MSforeachdb 'use [?];
 insert into  #userpriv 
select * from 
(select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER, db , usuario , sum(db_accessadmin)  db_accessadmin ,sum(db_backupoperator) db_backupoperator,sum(db_datareader )	db_datareader,sum(db_datawriter) db_datawriter	,sum(db_ddladmin) db_ddladmin /* ,sum(db_denydatareader)  db_denydatareader ,sum(db_denydatawriter) db_denydatawriter*/,sum(db_owner) db_owner,sum(db_securityadmin ) db_securityadmin   from (SELECT 
DB_NAME() db,
    p.name AS Usuario,
	CASE WHEN r.name = ''db_accessadmin''  THEN 1 ELSE 0 END as db_accessadmin,
	CASE WHEN r.name = ''db_backupoperator'' THEN 1 ELSE 0 END as db_backupoperator,
	CASE WHEN r.name = ''db_datareader'' THEN 1 ELSE 0 END as db_datareader,
	CASE WHEN r.name = ''db_datawriter'' THEN 1 ELSE 0 END as db_datawriter,
	CASE WHEN r.name = ''db_ddladmin'' THEN 1 ELSE 0 END as db_ddladmin,
/*  CASE WHEN r.name = ''db_denydatareader'' THEN 1 ELSE 0 END as db_denydatareader,
	CASE WHEN r.name = ''db_denydatawriter'' THEN 1 ELSE 0 END as db_denydatawriter,*/
	CASE WHEN r.name = ''db_owner'' THEN 1 ELSE 0 END as db_owner,
	CASE WHEN r.name = ''db_securityadmin'' THEN 1 ELSE 0 END as db_securityadmin
FROM sys.database_role_members m
INNER JOIN sys.database_principals r ON m.role_principal_id = r.principal_id 
INNER JOIN sys.database_principals p ON m.member_principal_id = p.principal_id and p.type_desc != ''DATABASE_ROLE'')a group by   db , usuario ) as a'


 
select 	IP_SERVER ,db  ,usuario, ISNULL( is_disabled,0) is_disabled  , db_accessadmin ,db_backupoperator 	,db_datareader 	,db_datawriter 	,db_ddladmin ,db_owner ,db_securityadmin  from #userpriv a 
left join sys.server_principals b on a.usuario=b.name
where db != 'temporales' and
 usuario NOT LIKE 'NT AUTHORITY%'
    AND usuario NOT LIKE 'NT SERVICE%'
	AND usuario NOT LIKE 'public'
	AND usuario NOT LIKE '##%'
	AND usuario NOT LIKE 'msa'
	AND usuario NOT LIKE 'dbo' /*Aqui agregan los usuarios que no quieren escanear*/
	and (db_accessadmin != 0 or db_backupoperator != 0  or db_datawriter != 0 or db_ddladmin != 0  /*or db_denydatareader != 0 or db_denydatawriter != 0*/ or db_owner != 0 or db_securityadmin != 0)
 order by  db,usuario
	 
drop table #userpriv



	


/*****************************************************************************************************
******************* PERMISOS GRANT DE ADMINISTRADOR QUE SE HACEN EN LA DBA MASTER  *******************

   @Descripción: Estos permisos son a nivel  servidor y se ejecutan en la base de datos MASTER y otorga permisos que te 
   permiten configurar ciertas opciones de manera global. 


 1.- ADMINISTER BULK OPERATIONS: Este permiso permite al usuario ejecutar operaciones masivas, 
 como la importación y exportación de datos a granel utilizando herramientas como BCP (Bulk Copy Program)
 o el comando INSERT ... BULK.

 2.- ALTER ANY SERVER AUDIT: Con este permiso, un usuario puede modificar cualquier configuración de 
 auditoría a nivel de servidor, incluyendo la creación, modificación y eliminación de auditorías.

 3.- ALTER ANY CREDENTIAL: Permite al usuario alterar cualquier credencial almacenada en el servidor. 
 Las credenciales se utilizan para almacenar información de inicio de sesión que puede ser utilizada por proxy.

 4.- ALTER ANY CONNECTION: Este permiso otorga la capacidad de modificar cualquier conexión a 
 nivel de servidor, incluyendo la capacidad de cerrar conexiones existentes.

 5.- ALTER ANY DATABASE: Con este permiso, un usuario puede realizar cambios en cualquier base de datos
 del servidor, como modificar propiedades de la base de datos, cambiar la propiedad de propiedad de 
 propiedad única del usuario o eliminar bases de datos.

 6.- ALTER ANY EVENT NOTIFICATION: Permite al usuario modificar cualquier notificación de evento en el
 servidor, incluyendo sus propiedades y configuraciones.

 7.- ALTER ANY ENDPOINT: Otorga la capacidad de modificar cualquier extremo (endpoint) en el servidor. 
 Los extremos son puntos de conexión utilizados para la comunicación.

 8.- ALTER ANY LOGIN: Este permiso permite al usuario realizar cambios en cualquier inicio de sesión 
 en el servidor, como cambiar la contraseña, desbloquear cuentas, etc.

 9.- ALTER ANY LINKED SERVER: Permite al usuario modificar cualquier configuración relacionada con 
 servidores vinculados, que son conexiones a otros servidores de bases de datos.

 10.- ALTER RESOURCES: Otorga la capacidad de realizar cambios en los recursos del sistema, 
 como configuraciones de afinidad de CPU.

 11.- ALTER SERVER STATE: Este permiso permite al usuario realizar cambios en el estado del servidor,
 como ponerlo en modo de usuario único o detener y reiniciar el servidor.

 12.- ALTER SETTINGS: Permite al usuario realizar cambios en las configuraciones del servidor, 
 como configuraciones de opción de configuración avanzada.
 
 13.- ALTER TRACE: Otorga la capacidad de modificar o detener eventos de seguimiento que están en ejecución.
 
 14.- AUTHENTICATE SERVER: Permite al usuario autenticar el servidor, normalmente utilizado para
 autenticación en modo mixto (modo de autenticación de SQL Server y de Windows).
 
 15.- CONTROL SERVER: Este permiso confiere al usuario control total sobre el servidor, similar 
 al rol de servidor "sysadmin".
 
 16.- CREATE ANY DATABASE: Permite al usuario crear nuevas bases de datos en el servidor, 
 independientemente de las restricciones de propiedad.
 
 17.- CREATE DDL EVENT NOTIFICATION: Otorga la capacidad de crear notificaciones de eventos 
 DDL (Data Definition Language) para detectar cambios en la estructura de la base de datos.
 
 18.- CREATE ENDPOINT: Permite al usuario crear nuevos extremos en el servidor.
 
 19.- CREATE TRACE EVENT NOTIFICATION: Permite al usuario crear notificaciones de eventos de 
 seguimiento para detectar cambios en eventos específicos de seguimiento.
 
 20.- SHUTDOWN: Este permiso permite al usuario apagar el servidor de base de datos.
 
 21.- EXTERNAL ACCESS ASSEMBLY: Con este permiso, el usuario puede crear ensamblajes externos, 
 que son bibliotecas de código que pueden ser utilizadas por SQL Server.
 
 22.- UNSAFE ASSEMBLY: Permite al usuario crear y ejecutar ensamblajes no seguros, que pueden 
 contener código que no está sujeto a las restricciones habituales de seguridad.


******************************************************************************************************/


select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,username,a1 as ADMINISTER_BULK_OPERATIONS ,a2  as ALTER_ANY_SERVER_AUDIT ,a3  as ALTER_ANY_CREDENTIAL ,a4  as ALTER_ANY_CONNECTION ,a5  as ALTER_ANY_DATABASE ,a6  as ALTER_ANY_EVENT_NOTIFICATION ,a7  as ALTER_ANY_ENDPOINT ,a8  as ALTER_ANY_LOGIN ,a9  as ALTER_ANY_LINKED_SERVER ,a10 as ALTER_RESOURCES ,a11 as ALTER_SERVER_STATE ,a12 as ALTER_SETTINGS ,a13 as ALTER_TRACE ,a14 as AUTHENTICATE_SERVER ,a15 as CONTROL_SERVER /*,a16 as CONNECT_SQL*/ ,a17 as CREATE_ANY_DATABASE ,a18 as CREATE_DDL_EVENT_NOTIFICATION ,a19 as CREATE_ENDPOINT ,a20 as CREATE_TRACE_EVENT_NOTIFICATION ,a21 as SHUTDOWN_ ,a22 as EXTERNAL_ACCESS_ASSEMBLY ,a23 as UNSAFE_ASSEMBLY  from  
(select * from 
(select username, sum(a1)  a1 , sum(a2)  a2 , sum(a3)  a3 , sum(a4)  a4 , sum(a5)  a5 , sum(a6)  a6 , sum(a7)  a7 , sum(a8)  a8 , sum(a9)  a9 , sum(a10) a10, sum(a11) a11, sum(a12) a12, sum(a13) a13, sum(a14) a14, sum(a15) a15/*, sum(a16) a16*/, sum(a17) a17, sum(a18) a18, sum(a19) a19, sum(a20) a20, sum(a21) a21, sum(a22) a22, sum(a23) a23 from
(SELECT
    dp.name AS [username],
	CASE WHEN permission_name = 'ADMINISTER BULK OPERATIONS'  THEN 1 ELSE 0 END as 'a1' ,
	CASE WHEN permission_name = 'ALTER ANY SERVER AUDIT'  THEN 1 ELSE 0 END as 'a2' ,
	CASE WHEN permission_name = 'ALTER ANY CREDENTIAL'  THEN 1 ELSE 0 END as 'a3' ,
	CASE WHEN permission_name = 'ALTER ANY CONNECTION'  THEN 1 ELSE 0 END as 'a4' ,
	CASE WHEN permission_name = 'ALTER ANY DATABASE'  THEN 1 ELSE 0 END as 'a5' ,
	CASE WHEN permission_name = 'ALTER ANY EVENT NOTIFICATION'  THEN 1 ELSE 0 END as 'a6' ,
	CASE WHEN permission_name = 'ALTER ANY ENDPOINT'  THEN 1 ELSE 0 END as 'a7' ,
	CASE WHEN permission_name = 'ALTER ANY LOGIN'  THEN 1 ELSE 0 END as 'a8' ,
	CASE WHEN permission_name = 'ALTER ANY LINKED SERVER'  THEN 1 ELSE 0 END as 'a9' ,
	CASE WHEN permission_name = 'ALTER RESOURCES'  THEN 1 ELSE 0 END as 'a10' ,
	CASE WHEN permission_name = 'ALTER SERVER STATE'  THEN 1 ELSE 0 END as 'a11' ,
	CASE WHEN permission_name = 'ALTER SETTINGS'  THEN 1 ELSE 0 END as 'a12' ,
	CASE WHEN permission_name = 'ALTER TRACE'  THEN 1 ELSE 0 END as 'a13' ,
	CASE WHEN permission_name = 'AUTHENTICATE SERVER'  THEN 1 ELSE 0 END as 'a14' ,
	CASE WHEN permission_name = 'CONTROL SERVER'  THEN 1 ELSE 0 END as 'a15' ,
	--CASE WHEN permission_name = 'CONNECT SQL'  THEN 1 ELSE 0 END as 'a16' ,
	CASE WHEN permission_name = 'CREATE ANY DATABASE'  THEN 1 ELSE 0 END as 'a17' ,
	CASE WHEN permission_name = 'CREATE DDL EVENT NOTIFICATION'  THEN 1 ELSE 0 END as 'a18' ,
	CASE WHEN permission_name = 'CREATE ENDPOINT'  THEN 1 ELSE 0 END as 'a19' ,
	CASE WHEN permission_name = 'CREATE TRACE EVENT NOTIFICATION' THEN 1 ELSE 0 END as 'a20',
	CASE WHEN permission_name = 'SHUTDOWN'  THEN 1 ELSE 0 END as 'a21' ,
	CASE WHEN permission_name = 'EXTERNAL ACCESS ASSEMBLY'  THEN 1 ELSE 0 END as 'a22' ,
	CASE WHEN permission_name = 'UNSAFE ASSEMBLY' THEN 1 ELSE 0 END as 'a23'
FROM sys.server_permissions sp
INNER JOIN sys.server_principals dp ON sp.grantee_principal_id = dp.principal_id
where state_desc=  'GRANT' and
permission_name in('ADMINISTER BULK OPERATIONS' ,'ALTER ANY SERVER AUDIT' ,'ALTER ANY CREDENTIAL' ,'ALTER ANY CONNECTION' ,'ALTER ANY DATABASE' ,'ALTER ANY EVENT NOTIFICATION' ,'ALTER ANY ENDPOINT' ,'ALTER ANY LOGIN' ,'ALTER ANY LINKED SERVER' ,'ALTER RESOURCES' ,'ALTER SERVER STATE' ,'ALTER SETTINGS' ,'ALTER TRACE' ,'AUTHENTICATE SERVER' ,'CONTROL SERVER' ,'CONNECT SQL' ,'CREATE ANY DATABASE' ,'CREATE DDL EVENT NOTIFICATION' ,'CREATE ENDPOINT' ,'CREATE TRACE EVENT NOTIFICATION' ,'SHUTDOWN' ,'EXTERNAL ACCESS ASSEMBLY' ,'UNSAFE ASSEMBLY') and
	dp.name NOT LIKE 'NT AUTHORITY%'
    AND dp.name NOT LIKE 'NT SERVICE%'
	AND dp.name NOT LIKE 'public'
	AND dp.name NOT LIKE '##%'   /*Aqui agregan los usuarios que no quieren escanear*/
	AND dp.name NOT LIKE 'msa'
	AND dp.name NOT LIKE 'dbo')a 
	group by username )a
	where (a1!=0  or a2!=0  or a3!=0  or a4!=0  or a5!=0  or a6!=0  or a7!=0  or a8!=0  or a9!=0  or a10!=0 or a11!=0 or a12!=0 or a13!=0 or a14!=0 or a15!=0 /*or a16!=0*/ or a17!=0 or a18!=0 or a19!=0 or a20!=0 or a21!=0 or a22!=0 or a23!=0 )	)a
	








/********************************************************************************************************************* 
******************* PERMISOS LOGICOS/GRANULARES NIVEL BASE DE DATOS (INSERT,DELETE, UPDATE, ALTER, EXECUTE)   ********

   @Columnas: IP_SERVER , db , a.name, is_disabled , a.type_desc ,INSERT_ ,DELETE_ ,UPDATE_ ,EXECUTE_ ,CONTROL_ ,BACKUP_ ,ALTER_ ,CREATE_

   @Descripción: Estos permisos son a nivel base de datos y se otorgan en la base de datos donde quieres que 
   se aplique el permiso, y pueden servir para la modificación de la información en las tablas o 
   creación o modificación de tablas.

	1.- INSERT: Permite agregar nuevos registros a una tabla en una base de datos.

	2.- DELETE: Permite eliminar registros de una tabla en una base de datos.

	3.- UPDATE: Permite modificar registros existentes en una tabla en una base de datos.

	4.- ALTER: Proporciona la capacidad de realizar cambios en la estructura de los 
	objetos de la base de datos, como tablas y vistas.

	5.- EXECUTE: Permite ejecutar procedimientos almacenados y funciones en una base de datos.

	6.- CONTROL: Este permiso otorga el control total sobre el objeto al que se aplica, lo 
	que incluye todos los permisos mencionados anteriormente. Es un permiso muy amplio y 
	debe ser otorgado con precaución.

	7.- BACKUP: Permite realizar operaciones de copia de seguridad en la base de datos, lo que 
	incluye la capacidad de realizar copias de seguridad completas o incrementales.

	8.- CREATE: Proporciona la capacidad de crear nuevos objetos en una base de datos, como 
	tablas, vistas, índices, procedimientos almacenados, etc.
   
**********************************************************************************************************************/

CREATE TABLE #userpriv_grant (
	IP_SERVER VARCHAR(200),
	db VARCHAR(200),
    name VARCHAR(200),
	type_desc VARCHAR(200),
    INSERT_ int
	,DELETE_ int
	,UPDATE_ int
--	,ALTER_ int
	,EXECUTE_ int
	,CONTROL_ int
	,BACKUP_ int
	,ALTER_ int
	,CREATE_ int
);


execute SYS.sp_MSforeachdb 'use [?];
  insert into  #userpriv_grant  
 select * from 
(select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,
	    DB_NAME() db,
		Usuario,
		type_desc,
		sum(INSERT_ ) INSERT_,
		sum(DELETE_ ) DELETE_,
		sum(UPDATE_ ) UPDATE_,
--      sum(ALTER_  ) ALTER_,
		sum(EXECUTE_) EXECUTE_,
		sum(CONTROL_) CONTROL_,
		sum(BACKUP_) BACKUP_,
		sum(ALTER_) ALTER_,
		sum(CREATE_) CREATE_
		from 
( SELECT	
    USER_NAME(grantee_principal_id) AS Usuario,
	b.type_desc,
    CASE WHEN permission_name = ''INSERT''  THEN 1 ELSE 0 END as ''INSERT_'' ,
	CASE WHEN permission_name = ''DELETE''  THEN 1 ELSE 0 END as ''DELETE_'' ,
	CASE WHEN permission_name = ''UPDATE''  THEN 1 ELSE 0 END as ''UPDATE_'' ,
--	CASE WHEN permission_name = ''ALTER''  THEN 1 ELSE 0 END as ''ALTER_'' ,
	CASE WHEN permission_name = ''EXECUTE''  THEN 1 ELSE 0 END as ''EXECUTE_'' ,
	CASE WHEN permission_name like ''%CONTROL%''  THEN 1 ELSE 0 END as ''CONTROL_'',
	CASE WHEN permission_name like ''%BACKUP%''  THEN 1 ELSE 0 END as ''BACKUP_'',
	CASE WHEN permission_name like ''%ALTER%''  THEN 1 ELSE 0 END as ''ALTER_'',
	CASE WHEN permission_name like ''%CREATE%''  THEN 1 ELSE 0 END as ''CREATE_''
	/*CASE WHEN permission_name = ''CONNECT''  THEN 1 ELSE 0 END as ''CONNECT'' ,*/
FROM sys.database_permissions a 
left join sys.database_principals b on b.principal_id=a.grantee_principal_id
where state_desc = ''GRANT'' 
and permission_name in(''INSERT'',''DELETE'', ''UPDATE'',''ALTER'', ''EXECUTE'' /*,''CONNECT''*/ )  
OR (permission_name like ''%BACKUP%'' OR permission_name like ''%ALTER%'' OR permission_name like ''%CREATE%'' OR permission_name like ''%CONTROL%'' )
)a
group by Usuario,type_desc )a
 '





select IP_SERVER , db , a.name, ISNULL( is_disabled,0) is_disabled , a.type_desc ,INSERT_ ,DELETE_ ,UPDATE_ ,EXECUTE_ ,CONTROL_ ,BACKUP_ ,ALTER_ ,CREATE_ from #userpriv_grant a
left join sys.server_principals b on b.name=a.name
where  db != 'temporales' and
 a.name NOT LIKE 'NT AUTHORITY%'
    AND a.name NOT LIKE 'NT SERVICE%'
	AND a.name NOT LIKE 'public'
	AND a.name NOT LIKE '##%' 
	AND a.name NOT LIKE 'msa'  /*Aqui agregan los usuarios que no quieren escanear*/
	AND a.name NOT LIKE 'dbo'
	AND a.name not in('TargetServersRole'
	,'PolicyAdministratorRole'
	,'RSExecRole'
	,'ServerGroupAdministratorRole'
	,'SQLAgentOperatorRole'
	,'SQLAgentUserRole'
	,'DatabaseMailUserRole'
	,'db_ssisadmin'
	,'db_ssisltduser'
	,'db_ssisoperator'
	,'dc_admin'
	,'dc_operator'
	,'dc_proxy'
	,'UtilityCMRReader'
	,'UtilityIMRReader'
	,'UtilityIMRWriter','public')
 order by db,a.name
	 
	 
	 
--drop table #userpriv_grant





/**************************************************************************************************************
******************* PERMISOS PERSONALIZADO, ROLES NIVEL SERVIDOR Y NIVEL DBA  Y SUS MIEMBROS    *************** 

   @Descripción: Estos permisos son de roles nivel servidor, base de datos y que herendan sus permisos
   a usuarios 

   @Columnas: ip_server,db, type_rol, rolname,username,  user_is_disabled


***************************************************************************************************************/
 




 CREATE TABLE #roles (
	IP_SERVER VARCHAR(max),
	DB VARCHAR(max),
	Type_ROL VARCHAR(max),
	Rolname VARCHAR(max),
	username VARCHAR(max)
);


/* ROLES NIVEL SERVIDOR  */
insert into #roles  select 
	(SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,
	'master' db,
	'SERVER_ROLE' Type_ROL,
	rm.name Rolname,
	r.name username	
from sys.server_role_members AS p
JOIN sys.server_principals AS rm ON rm.principal_id = p.role_principal_id 
JOIN sys.server_principals AS r ON r.principal_id = p.member_principal_id
 where not rm.name in('sysadmin' ,'securityadmin' ,'serveradmin' ,'setupadmin' ,'processadmin' ,'diskadmin' ,'dbcreator' ,'bulkadmin')

 /* ROLES NIVEL BASE DE DATOS  */
execute SYS.sp_MSforeachdb 'use [?];

insert into #roles   select  
	(SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,
	DB_NAME() db,
	''DATABASE_ROLE'' Type_ROL,
    r.name as Rolname,
	p.name AS username	
FROM sys.database_role_members m
INNER JOIN sys.database_principals r ON m.role_principal_id = r.principal_id 
INNER JOIN sys.database_principals p ON m.member_principal_id = p.principal_id and p.type_desc != ''DATABASE_ROLE''
WHERE 
not r.name in(''public'',''db_owner'' ,''db_accessadmin'' ,''db_securityadmin'' ,''db_ddladmin'' ,''db_backupoperator'' ,''db_datareader'' ,''db_datawriter'' ,''db_denydatareader'' ,''db_denydatawriter'')
and p.name != ''dbo'' '




select ip_server,db, type_rol, rolname,username,ISNULL( is_disabled,0) user_is_disabled from #roles  b
left join sys.server_principals a on b.username=a.name
where  db != 'temporales' and username NOT LIKE 'NT AUTHORITY%'
    AND username NOT LIKE 'NT SERVICE%'
	AND username NOT LIKE 'public'
	AND username NOT LIKE '##%'
	AND username NOT LIKE 'msa'
	AND username NOT LIKE 'dbo' /*Aqui agregan los usuarios que no quieren escanear*/
	AND NOT username = 'MS_DataCollectorInternalUser'
	AND NOT username = 'TargetServersRole'
	and Rolname in(select name from #userpriv_grant where  /* Agregando los roles o usuarios con permisos elevados*/
 name NOT LIKE 'NT AUTHORITY%'
    AND name NOT LIKE 'NT SERVICE%'
	AND name NOT LIKE 'public'
	AND name NOT LIKE '##%'
	AND name NOT LIKE 'msa'
	AND name NOT LIKE 'dbo'
	AND name not in('TargetServersRole'
	,'PolicyAdministratorRole'
	,'RSExecRole'
	,'ServerGroupAdministratorRole'
	,'SQLAgentOperatorRole'
	,'SQLAgentUserRole'
	,'DatabaseMailUserRole'
	,'db_ssisadmin'
	,'db_ssisltduser'
	,'db_ssisoperator'
	,'dc_admin'
	,'dc_operator'
	,'dc_proxy'
	,'UtilityCMRReader'
	,'UtilityIMRReader'
	,'UtilityIMRWriter','public')) order by DB, username


 
 
 drop table #roles
 
 
 
 
 




/***************************************************************************************************
******************* saber los owner de  LAS BASE DE DATOS , ESQUEMAS y OBJETOS   *******************

	@Descripción: Te muestra los owner de las base de datos,esquemas y objetos 
	
	@Columnas: IP_SERVER ,DB ,type_owner ,a.name ,owner ,  owner_is_disabled

****************************************************************************************************/



 CREATE TABLE #owners (
	IP_SERVER VARCHAR(max),
	DB VARCHAR(max),
	type_owner VARCHAR(max),
	name VARCHAR(max),
    owner VARCHAR(max),
);

 /* OWNER DE LAS BASE DE DATOS   */ 
insert into  #owners   SELECT  (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,name db,
 'DBA' as type_owner ,name as [Name], suser_sname(owner_sid) as [Owner]  FROM sys.databases 
 
 
execute SYS.sp_MSforeachdb 'use [?];
 /*  OWNER DE LOS ESQUEMAS   */ 
 insert into  #owners SELECT (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,DB_NAME() db,''SCHEMA'' as type_owner, schema_name as name, schema_owner [Owner] FROM information_schema.schemata where 
 not SCHEMA_NAME in(''db_owner'' ,''db_accessadmin'' ,''db_securityadmin'' ,''db_ddladmin'' ,''db_backupoperator'' ,''db_datareader'' ,''db_datawriter'' ,''db_denydatareader'' ,''db_denydatawriter'')
 and not schema_owner in(''guest'',''dbo'',''INFORMATION_SCHEMA'',''sys'',''RSExecRole'',''sa'',''NT AUTHORITY\SYSTEM'');

 /* OWNER DE LOS OBJETOS   */ 
 insert into  #owners SELECT (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER, DB_NAME() db,type_desc, name  ,USER_NAME(principal_id) AS [Owner]  FROM sys.objects where principal_id is not null; '

 
 
 select IP_SERVER ,DB ,type_owner ,a.name ,owner ,ISNULL( is_disabled,0) owner_is_disabled from #owners  a 
 left join sys.server_principals b on a.owner=b.name
 
 where not owner  in ('sa')  /*Aqui agregan los usuarios que no quieren escanear*/
 and owner NOT LIKE '%adminbd%' and not db in('master','msdb', 'model') and db != 'temporales'  order by db,type_owner



 DROP TABLE  #owners 
 ```
