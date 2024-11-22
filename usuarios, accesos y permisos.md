
# Objetivo:
Es lograr administrar los usuarios de manera necesaria para llevar acabo las actividades  laborales y entender un poco la estructura de los usuarios

### Niveles de Permisos: 
En SQL server existen los permisos 

**Nivel servidor:**  Estos permisos están asociados con la administración y control general del servidor, por ejemplo  la creacion de login de  usuarios , la creacion base de datos, la creacion  SQL <br><br>
**Nivel base de datos :** Estos permisos se aplican a objetos específicos dentro de una base de datos.  por ejemplo la creación, eliminación , la modificación o inserción de los objetos o datos  <br><br>
- 1  **Permisos especificos/ Granulares:** Este le especificas que permiso quieres para un objeto o varios objetos, como por ejemplos los permisos select, insert, update etc, etc
- 2  **Permisos globales:**  Con los permisos globales, se usan roles predifinidos como un rol de puro lecutra y esos permisos se heredan a un usuario 

**permisos de administrador :** Estos son permisos que permiten realizar actividades muy especificas que un usuario comun no utiliza, por ejemplo respaldos, el copiado de información, la modificacion de un link server o eventos de auditoria 

 [nota] cuando a un usuarios se asigna un permiso grant y al final tiene esto "WITH GRANT OPTION" y tiene la capacidad de otorgar esos mismos permisos a otros usuarios o roles.

### Conceptos Básicos 

![usuarios](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/media/typesofusers.png?view=sql-server-ver16)

`Login :` permite que te conectes al servidor sql server     <br>
`Usuario :` este sirve para asociar un usuario con una base de datos,  **tipos de usuarios:**  WINDOWS_USER y SQL_USER <br>
`Role :` este es un grupo de permisos que se pueden otrogar a un o más de un usuario      <br>
`connect :`  otorga permiso de conexión pero este se crea automaticamente al crear el login y asociar un usuario con una base de datos   <br>


> [!CAUTION]
> **`sa`**   "System Administrator"   Es el usuario predeterminado del sistema y tiene privilegios máximos en el servidor. Este usuario tiene todos los permisos y puede realizar cualquier acción en todas las bases de datos del servidor. Por esta razón, se considera un usuario con derechos elevados y se recomienda usarlo con precaución. Por motivos de seguridad, se recomienda cambiar la contraseña predeterminada del usuario "sa" y evitar su uso cotidiano o buena práctica bloquear el acceso al usuario "sa"  


 **`REVOKE:`**  elimina el acceso otorgado previamente al objeto de la base de datos.  los usuarios o roles que anteriormente tenían acceso al objeto ya no tendrán ese acceso después de que se ejecute REVOKE

 **`DENY:`**   Cuando se niega un permiso con DENY, se bloquea el acceso al objeto de la base de datos para el usuario o rol especificado, incluso si ese usuario o rol tiene el permiso otorgado a través de otros roles o permisos implícitos

# Ejemplos de uso :

```SQL
select SUSER_SNAME() -- saber el usuario que estas usando actualmente
select SUSER_ID()	-- saber el id del usuario que estas usando actualmente
select USER_NAME(grantee_principal_id) -- saber que usuario tiene un id
select CONNECTIONPROPERTY('local_net_address') --- ver la ip que usa tu usuario 
SELECT * FROM sys.dm_exec_connections WHERE session_id = @@SPID ---  ver la ip que usa tu usuario

OBJECT_NAME(major_id) AS object_name

SELECT name, is_disabled FROM sys.server_principals WHERE sid = 0x01; -- Verifica el estado del usuario sa

```


### Buscar un usuario, login o role:

**SQL_LOGIN** ->  son aquellos usuarios que cuando se crearon se les epecifico una contraseña 
**WINDOWS_LOGIN** -> son aquellos usuarios que se autentican con las contraseñas que estan de un active directory

```SQL
--- Con estas querys puedes ver cuando se crearon y se modificaron los usuarios

--- [Recomendada para buscar] Esta query te muestra a nivel servidor todos  los roles, usuarios sql y windows login y grupos  que existen:
select * from sys.server_principals where type_desc in('WINDOWS_LOGIN', 'SQL_LOGIN',  'SERVER_ROLE' , 'WINDOWS_GROUP') order by type_desc,name 

--- Esta query te muestra a nivel de base de datos todo solo los usuarios sql y windows user que se asociaron a una base de datos en especifica 
select * from sys.database_principals where  type_desc in('WINDOWS_USER', 'SQL_USER' ,  'DATABASE_ROLE','WINDOWS_GROUP') order by type_desc,name  

--- Esta query puede ver el hash del password los SQL_USER 
SELECT name,password_hash,default_database_name, is_expiration_checked, is_policy_checked  FROM sys.sql_logins order by name

---  
 select * from sys.syslogins



 SELECT uid,name,hasdbaccess,islogin,isntname,isntgroup,isntuser,issqluser,isaliased,issqlrole,isapprole
FROM sysusers

SELECT * FROM master.sys.sysusers WHERE islogin = 1

```

### ver hash password de todos login sql, no de los windows login, para pasar a otro server
```SQL
exec sp_help_revlogin

https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/security/transfer-logins-passwords-between-instances

```
### Saber quien es owner 
```SQL
SELECT suser_sname(owner_sid),name FROM sys.databases
```

### Creacion y eliminar un login :
Al crear el Login le especificamos de que forma se va conectar el servidor , que es con que nombre y contraseña 

```SQL
*******  CREAR *******
CREATE LOGIN [MYDOMINIO\miusuario] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [jose-mecanico] WITH PASSWORD=N'123123' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

********* PARÁMETROS******
MUST_CHANGE : LE INDICAS QUE LA PRIMERA VEZ QUE INICIE SESION LE PIDA CAMBIAR LA CONTRASEÑA
CHECK_EXPIRATION : VALIDA SI LA PASSWORD EXPIRA DESPUES DE 90 días


******* ELIMINAR *******
DROP LOGIN [MYDOMINIO\miusuario] 
```

### crear un usuario o eliminar:
El crear un usuario, estas especificando que el usuario, que puede abrir la base de datos en la que creaste el usuario 
[Doc. Oficial](https://learn.microsoft.com/es-es/sql/t-sql/statements/create-user-transact-sql?view=sql-server-ver16)

```SQL
use mi_dba_test
go

-- agregar usuarios las dos querys sirven para lo mismo 
EXEC sp_grantdbaccess 'my_user_123','my_user_123'; 
CREATE USER [my_user_123] FOR LOGIN [my_user_123] WITH DEFAULT_SCHEMA=[dbo]

-- eliminar usuarios de base de datos 
DROP USER [alex]
EXEC sp_revokedbaccess  'my_user_123','my_user_123'; 
```

### Crear un role o eliminar

[Doc. Oficial](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-server-role-transact-sql?view=sql-server-ver16)
```SQL
/* crear roles nivel base de datos, a estos roles solo se le pueden dar permisos granulares  */ 
CREATE ROLE test_role;

/* crear roles nivel servidor [Nota] no se puede en versiones de 2008 y solo se le da permisos de
grant de administrador, como por ejemplo "ADMINISTER BULK OPERATIONS" ,
no se puede dar permisos granulares como los select o update */
CREATE SERVER ROLE testers 

/* Asignarle permisos basicos al rol*/ 
GRANT select    TO test_role;

/* Asignar un usuario a un rol  */ 
EXEC sp_addrolemember 'test_role', 'My_user';
ALTER ROLE [test_role] ADD MEMBER [My_user]
ALTER SERVER ROLE test_rol_server  ADD MEMBER TEST1711;

/* Validar los roles nivel servidor  */
select * from sys.server_principals where type_desc like '%rol%'

/* Validar los roles nivel base de datos */
select * from sys.database_principals where type_desc like '%rol%'

--- Eliminar roles
DROP ROLE  desarolladores;
DROP SERVER ROLE  testers;



```

### Asignar permisos  Nivel servidor
```SQL
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'bulkadmin'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'dbcreator'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'diskadmin'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'processadmin'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'securityadmin'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'serveradmin'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'setupadmin'
EXEC master..sp_addsrvrolemember @loginame = N'my_user_test', @rolename = N'sysadmin'
```

**Crear reporte de permisos  Nivel servidor**
```SQL
select   CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR(100)) IP_SERVER,UserName,sum(sysadmin) sysadmin ,sum(securityadmin) securityadmin ,sum(serveradmin ) serveradmin ,sum(setupadmin ) setupadmin ,sum(processadmin ) processadmin ,sum(diskadmin ) diskadmin ,sum(dbcreator) dbcreator ,sum(bulkadmin) bulkadmin from
(SELECT
    p.name AS UserName,
    CASE WHEN r.name = 'sysadmin' THEN 1 ELSE 0 END as sysadmin,
	CASE WHEN r.name = 'securityadmin' THEN 1 ELSE 0 END as securityadmin,
	CASE WHEN r.name = 'serveradmin' THEN 1 ELSE 0 END as serveradmin,
	CASE WHEN r.name = 'setupadmin' THEN 1 ELSE 0 END as setupadmin,
	CASE WHEN r.name = 'processadmin' THEN 1 ELSE 0 END as processadmin,
	CASE WHEN r.name = 'diskadmin' THEN 1 ELSE 0 END as diskadmin,
	CASE WHEN r.name = 'dbcreator' THEN 1 ELSE 0 END as dbcreator,
	CASE WHEN r.name = 'bulkadmin' THEN 1 ELSE 0 END as bulkadmin
FROM sys.server_principals AS p
JOIN sys.server_role_members AS rm ON p.principal_id = rm.member_principal_id 
JOIN sys.server_principals AS r ON rm.role_principal_id = r.principal_id
where p.name NOT LIKE 'NT AUTHORITY%'
    AND p.name NOT LIKE 'NT SERVICE%'
	AND p.name NOT LIKE 'public'
	AND p.name NOT LIKE '##%'
	AND p.name NOT LIKE 'dbo'
	)a
	group by UserName
```


### Asignar permisos de administrador 
Estos son permisos que se asignan en la base de datos **master** y permite realizar actividades muy especificas que un usuario comun no utiliza, por ejemplo respaldos, el copiado de información, la modificacion de un link server o eventos de auditoria 
```SQL
GRANT ADMINISTER BULK OPERATIONS TO [my_user_test]
GRANT ALTER ANY CONNECTION TO [my_user_test]
GRANT ALTER ANY CREDENTIAL TO [my_user_test]
GRANT ALTER ANY DATABASE TO [my_user_test]
GRANT ALTER ANY ENDPOINT TO [my_user_test]
GRANT ALTER ANY EVENT NOTIFICATION TO [my_user_test]
GRANT ALTER ANY LINKED SERVER TO [my_user_test]
GRANT ALTER ANY LOGIN TO [my_user_test]
GRANT ALTER ANY SERVER AUDIT TO [my_user_test]
GRANT ALTER RESOURCES TO [my_user_test]
GRANT ALTER SERVER STATE TO [my_user_test]
GRANT ALTER SETTINGS TO [my_user_test]
GRANT ALTER TRACE TO [my_user_test]
GRANT AUTHENTICATE SERVER TO [my_user_test]
GRANT CONNECT SQL TO [my_user_test]
GRANT CONTROL SERVER TO [my_user_test]
GRANT CREATE ANY DATABASE TO [my_user_test]
GRANT CREATE DDL EVENT NOTIFICATION TO [my_user_test]
GRANT CREATE ENDPOINT TO [my_user_test]
GRANT CREATE TRACE EVENT NOTIFICATION TO [my_user_test]
GRANT EXTERNAL ACCESS ASSEMBLY TO [my_user_test]
GRANT SHUTDOWN TO [my_user_test]
GRANT UNSAFE ASSEMBLY TO [my_user_test]
GRANT VIEW ANY DATABASE TO [my_user_test]
GRANT VIEW ANY DEFINITION TO [my_user_test]
GRANT VIEW SERVER STATE TO [my_user_test]
```

### Crear un Reporte para ver quien tiene permisos de administrador
```SQL
select CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR(100))  IP_SERVER,username,a1 as ADMINISTER_BULK_OPERATIONS ,a2  as ALTER_ANY_SERVER_AUDIT ,a3  as ALTER_ANY_CREDENTIAL ,a4  as ALTER_ANY_CONNECTION ,a5  as ALTER_ANY_DATABASE ,a6  as ALTER_ANY_EVENT_NOTIFICATION ,a7  as ALTER_ANY_ENDPOINT ,a8  as ALTER_ANY_LOGIN ,a9  as ALTER_ANY_LINKED_SERVER ,a10 as ALTER_RESOURCES ,a11 as ALTER_SERVER_STATE ,a12 as ALTER_SETTINGS ,a13 as ALTER_TRACE ,a14 as AUTHENTICATE_SERVER ,a15 as CONTROL_SERVER /*,a16 as CONNECT_SQL*/ ,a17 as CREATE_ANY_DATABASE ,a18 as CREATE_DDL_EVENT_NOTIFICATION ,a19 as CREATE_ENDPOINT ,a20 as CREATE_TRACE_EVENT_NOTIFICATION ,a21 as SHUTDOWN_ ,a22 as EXTERNAL_ACCESS_ASSEMBLY ,a23 as UNSAFE_ASSEMBLY  from  
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
	AND dp.name NOT LIKE '##%'
	AND dp.name NOT LIKE 'dbo')a 
	group by username )a
	
	--- si quieres validar solo los usuarios que tienen estos privilegios entonces descomenta el where
	/*where (a1!=0  or a2!=0  or a3!=0  or a4!=0  or a5!=0  or a6!=0  or a7!=0  or a8!=0  or a9!=0  or a10!=0 or a11!=0 or a12!=0 or a13!=0 or a14!=0 or a15!=0 /*or a16!=0*/ or a17!=0 or a18!=0 or a19!=0 or a20!=0 or a21!=0 or a22!=0 or a23!=0   )*/	
	)a
```


### Asignar permisos  Nivel base de datos  
**Permisos globales:**  Con los permisos globales, se usan roles predifinidos como un rol de puro lecutra, escritura, etc y esos permisos se heredan a un usuario,   Estos permisos se asigna a una base de datos especifica, pero al asignarle un permiso, se agrega de manera global para todos sus objetos, por ejemplo al asignar el rol db_datareader sólo te da permisos de lectura en todos los objetos 

```SQL
EXEC sp_addrolemember N'db_accessadmin', N'my_user_test'
EXEC sp_addrolemember N'db_backupoperator', N'my_user_test'
EXEC sp_addrolemember N'db_datareader', N'my_user_test'
EXEC sp_addrolemember N'db_datawriter', N'my_user_test'
EXEC sp_addrolemember N'db_ddladmin', N'my_user_test'
EXEC sp_addrolemember N'db_denydatareader', N'my_user_test'
EXEC sp_addrolemember N'db_denydatawriter', N'my_user_test'
EXEC sp_addrolemember N'db_owner', N'my_user_test'
EXEC sp_addrolemember N'db_securityadmin', N'my_user_test'


ALTER ROLE [db_accessadmin] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_backupoperator] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_datareader] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_datawriter] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_ddladmin] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_denydatareader] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_denydatawriter] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_owner] ADD MEMBER [MYDOMINIO\omar.LOPEZ]
ALTER ROLE [db_securityadmin] ADD MEMBER [MYDOMINIO\omar.LOPEZ]


```

**Crear reporte de Permisos globales de todas las base de datos**
```SQL
1.-  creamos una la tabla temporal
CREATE TABLE #userpriv (
	db VARCHAR(200),
    usuario VARCHAR(200),
    db_accessadmin BIT
	,db_backupoperator BIT
	,db_datareader BIT
	,db_datawriter BIT
	,db_ddladmin BIT
	,db_denydatareader BIT
	,db_denydatawriter BIT
	,db_owner BIT
	,db_securityadmin BIT
);

2.- ejecutamos esta query y el todo el resultado lo copiamos y el resultado lo volvemos a ejecutar
select 'use '+ name + ' insert into  #userpriv select * from 
(select  db , usuario , sum(db_accessadmin)  db_accessadmin ,sum(db_backupoperator) db_backupoperator,sum(db_datareader )	db_datareader,sum(db_datawriter) db_datawriter	,sum(db_ddladmin) db_ddladmin ,sum(db_denydatareader)  db_denydatareader ,sum(db_denydatawriter) db_denydatawriter,sum(db_owner) db_owner,sum(db_securityadmin ) db_securityadmin   from (SELECT 
DB_NAME() db,
    p.name AS Usuario,
	CASE WHEN r.name = '+char(39) + 'db_accessadmin'+char(39) + '  THEN 1 ELSE 0 END as db_accessadmin,
	CASE WHEN r.name = '+char(39) + 'db_backupoperator'+char(39) + ' THEN 1 ELSE 0 END as db_backupoperator,
	CASE WHEN r.name = '+char(39) + 'db_datareader'+char(39) + ' THEN 1 ELSE 0 END as db_datareader,
	CASE WHEN r.name = '+char(39) + 'db_datawriter'+char(39) + ' THEN 1 ELSE 0 END as db_datawriter,
	CASE WHEN r.name = '+char(39) + 'db_ddladmin'+char(39) + ' THEN 1 ELSE 0 END as db_ddladmin,
	CASE WHEN r.name = '+char(39) + 'db_denydatareader'+char(39) + ' THEN 1 ELSE 0 END as db_denydatareader,
	CASE WHEN r.name = '+char(39) + 'db_denydatawriter'+char(39) + ' THEN 1 ELSE 0 END as db_denydatawriter,
	CASE WHEN r.name = '+char(39) + 'db_owner'+char(39) + ' THEN 1 ELSE 0 END as db_owner,
	CASE WHEN r.name = '+char(39) + 'db_securityadmin'+char(39) + ' THEN 1 ELSE 0 END as db_securityadmin
FROM sys.database_role_members m
INNER JOIN sys.database_principals r ON m.role_principal_id = r.principal_id 
INNER JOIN sys.database_principals p ON m.member_principal_id = p.principal_id and p.type_desc != '+char(39)+'DATABASE_ROLE'+char(39)+')a group by   db , usuario ) as a '
	 cnt_db from sys.databases where database_id > 4


3.- Ver el reporte, limpiamos los usuario basura y nos mostrara los usuarios que solo tiene permisos elevados 
select CONNECTIONPROPERTY ('local_net_address') as IP_SERVER,* from #userpriv where 
 usuario NOT LIKE 'NT AUTHORITY%'
    AND usuario NOT LIKE 'NT SERVICE%'
	AND usuario NOT LIKE 'public'
	AND usuario NOT LIKE '##%'
	AND usuario NOT LIKE 'dbo'
	and (db_accessadmin != 0 or db_backupoperator != 0  or db_datawriter != 0 or db_ddladmin != 0 or db_denydatareader != 0 or db_denydatawriter != 0 or db_owner != 0 or db_securityadmin != 0)
 order by usuario
```

**Permisos especificos/ Granulares:**
Este le especificas que permiso quieres para un objeto o varios objetos, como por ejemplos los permisos select, insert, update etc, etc
```SQL
/*podemos usar esto en los grant*/
OBJECT::MYOBJECT_TEST
DATABASE::MYDBA_TEST  
SCHEMA::MYESQUEMA_TEST

GRANT CONTROL ON dbo.my_tabla TO [my_user_test]
GRANT TAKE OWNERSHIP ON dbo.my_tabla TO [my_user_test]
GRANT VIEW CHANGE TRACKING ON dbo.my_tabla TO [my_user_tes
GRANT VIEW DEFINITION ON SCHEMA::dbo TO [MYDOMINIO\my_user_test_windows];
GRANT CONNECT, SELECT , UPDATE,  INSERT, DELETE, ALTER,  REFERENCES ON SCHEMA::dbo TO my_user_test;
GRANT UPDATE ON dbo.my_tabla TO my_usuario;

GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO nombre_usuario;
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO nombre_usuario;

GRANT CREATE TABLE TO [MYDOMINIOS\my_user_test_windows];
GRANT SHOWPLAN TO user1;

GRANT CREATE SEQUENCE ON SCHEMA::dbo TO  [Endy]

/* ESTOS PERMISOS GRANULARES SON A NIVEL BASE DE DATOS */

https://learn.microsoft.com/es-es/sql/relational-databases/security/permissions-database-engine?view=sql-server-ver16
SELECT * FROM fn_my_permissions(NULL, 'SERVER');
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');
SELECT *   FROM fn_builtin_permissions(DEFAULT);

CREATE TABLE --- este permiso tambien te va solicitar el permiso ALTER ya que  si no lo colocas te va salir
el error de 'dbo' no existe

CREATE VIEW
CREATE PROCEDURE
CREATE FUNCTION
CREATE RULE
CREATE DEFAULT
BACKUP DATABASE
BACKUP LOG
CREATE DATABASE
CREATE TYPE
CREATE ASSEMBLY
CREATE XML SCHEMA COLLECTION
CREATE SCHEMA
CREATE SYNONYM
CREATE AGGREGATE
CREATE ROLE
CREATE MESSAGE TYPE
CREATE SERVICE
CREATE CONTRACT
CREATE REMOTE SERVICE BINDING
CREATE ROUTE
CREATE QUEUE
CREATE SYMMETRIC KEY
CREATE ASYMMETRIC KEY
CREATE FULLTEXT CATALOG
CREATE CERTIFICATE
CREATE DATABASE DDL EVENT NOTIFICATION
CONNECT
CONNECT REPLICATION
CHECKPOINT
SUBSCRIBE QUERY NOTIFICATIONS
AUTHENTICATE
SHOWPLAN
ALTER ANY USER
ALTER ANY ROLE
ALTER ANY APPLICATION ROLE
ALTER ANY SCHEMA
ALTER ANY ASSEMBLY
ALTER ANY DATASPACE
ALTER ANY MESSAGE TYPE
ALTER ANY CONTRACT
ALTER ANY SERVICE
ALTER ANY REMOTE SERVICE BINDING
ALTER ANY ROUTE
ALTER ANY FULLTEXT CATALOG
ALTER ANY SYMMETRIC KEY
ALTER ANY ASYMMETRIC KEY
ALTER ANY CERTIFICATE
SELECT
INSERT
UPDATE
DELETE
REFERENCES
EXECUTE
ALTER ANY DATABASE DDL TRIGGER
ALTER ANY DATABASE EVENT NOTIFICATION
ALTER ANY DATABASE AUDIT
VIEW DATABASE STATE
VIEW DEFINITION
TAKE OWNERSHIP
ALTER
CONTROL



--- permisos a todos los procedimientos 

grant execute on Proc_calcularImpuestos to [MYDOMINIOS\my_user_test_windows] AS [dbo] /* with grant option -- el "with grant option" sirve para
que el usuario,  tenga la capacidad de asignar ese permiso a otros usuarios */

GRANT EXECUTE ON SCHEMA::dbo TO my_user_test_windows; -- permiso de EXECUTE  a todos los objetos
SELECT  'GRANT EXECUTE ON [' + SCHEMA_NAME(schema_id) + '].[' + name + '] TO [TuRolOUsuario];' + CHAR(13) FROM sys.procedures;

/* Ejemplos de with grant option 
https://sqlity.net/en/1884/grant-option-delegate-permission-management/
*/

```

**Ver permisos especificos pero de manera generica**
```SQL
********* OPCION #1 *********
SELECT
    p.name AS Usuario,
    STUFF((
        SELECT ', ' + dp.permission_name
        FROM sys.database_permissions dp
        WHERE dp.grantee_principal_id = p.principal_id
        FOR XML PATH('')), 1, 2, '') AS Privilegios
FROM sys.database_principals p
WHERE p.type_desc IN ('SQL_USER', 'WINDOWS_USER', 'WINDOWS_GROUP')
	AND principal_id > 4 -- Excluye usuarios de sistema
    AND p.name NOT LIKE '##%' -- Excluye usuarios de sistema
ORDER BY p.name;


********* OPCION #1 *********
 SELECT 
    dp.class_desc, 
    dp.permission_name, 
    dp.state_desc, 
    OBJECT_NAME(major_id) AS object_name, 
    USER_NAME(grantee_principal_id) AS grantee
FROM sys.database_permissions dp
WHERE  USER_NAME(grantee_principal_id)  = 'my_user1' =  ---- grantee_principal_id = DATABASE_PRINCIPAL_ID('my_user1');



```

**Crear un reporte de Permisos especificos de todas las base de datos**
```SQL
1.-  creamos una la tabla temporal
CREATE TABLE #userpriv_grant (
	db VARCHAR(200),
    usuario VARCHAR(200),
    INSERT_ int
	,DELETE_ int
	,UPDATE_ int
	,ALTER_ int
	,EXECUTE_ int

);


2.- ejecutamos esta query y el todo el resultado lo copiamos y el resultado lo volvemos a ejecutar
select 'use '+ name + ' insert into  #userpriv_grant select * from 
(select        DB_NAME() db,
		Usuario,
		sum(INSERT_ ) INSERT_,
		sum(DELETE_ ) DELETE_,
		sum(UPDATE_ ) UPDATE_,
		sum(ALTER_  ) ALTER_,
		sum(EXECUTE_) EXECUTE_
		from 
( SELECT	
    USER_NAME(grantee_principal_id) AS Usuario,
    CASE WHEN permission_name = '+char(39)+ 'INSERT'+char(39)+ '  THEN 1 ELSE 0 END as '+char(39)+ 'INSERT_'+char(39)+ ' ,
	CASE WHEN permission_name = '+char(39)+ 'DELETE'+char(39)+ '  THEN 1 ELSE 0 END as '+char(39)+ 'DELETE_'+char(39)+ ' ,
	CASE WHEN permission_name = '+char(39)+ 'UPDATE'+char(39)+ '  THEN 1 ELSE 0 END as '+char(39)+ 'UPDATE_'+char(39)+ ' ,
	CASE WHEN permission_name = '+char(39)+ 'ALTER'+char(39)+ '  THEN 1 ELSE 0 END as '+char(39)+ 'ALTER_'+char(39)+ ' ,
	CASE WHEN permission_name = '+char(39)+ 'EXECUTE'+char(39)+ '  THEN 1 ELSE 0 END as '+char(39)+ 'EXECUTE_'+char(39)+ ' 
	/*CASE WHEN permission_name = '+char(39)+ 'CONNECT'+char(39)+ '  THEN 1 ELSE 0 END as '+char(39)+ 'CONNECT'+char(39)+ ' ,*/
FROM sys.database_permissions where state_desc = '+char(39)+ 'GRANT'+char(39)+ ' 
and permission_name in('+char(39)+ 'INSERT'+char(39)+ ','+char(39)+ 'DELETE'+char(39)+ ', '+char(39)+ 'UPDATE'+char(39)+ ','+char(39)+ 'ALTER'+char(39)+ ', '+char(39)+ 'EXECUTE'+char(39)+ ' /*,'+char(39)+ 'CONNECT'+char(39)+ '*/ ) )a
group by Usuario )a'

from sys.databases where database_id > 4


3.- Ver el reporte, limpiamos los usuario basura y nos mostrara los usuarios que solo tiene permisos elevados 
select CONNECTIONPROPERTY ('local_net_address') IP_SERVER,* from #userpriv_grant where 
 usuario NOT LIKE 'NT AUTHORITY%'
    AND usuario NOT LIKE 'NT SERVICE%'
	AND usuario NOT LIKE 'public'
	AND usuario NOT LIKE '##%'
	AND usuario NOT LIKE 'dbo'
 order by usuario
```




### Revokar permisos Nivel servidor
https://learn.microsoft.com/es-es/sql/relational-databases/security/authentication-access/create-a-login?view=sql-server-ver16
```SQL
EXEC sp_dropsrvrolemember N'test_permisos', N'bulkadmin';
EXEC sp_dropsrvrolemember N'test_permisos', N'dbcreator';
EXEC sp_dropsrvrolemember N'test_permisos', N'diskadmin';
EXEC sp_dropsrvrolemember N'test_permisos', N'processadmin';
EXEC sp_dropsrvrolemember N'test_permisos', N'securityadmin';
EXEC sp_dropsrvrolemember N'test_permisos', N'serveradmin';
EXEC sp_dropsrvrolemember N'test_permisos', N'setupadmin';
EXEC sp_dropsrvrolemember N'test_permisos', N'sysadmin';
```

### Revokar permisos nivel administrador
```SQL
REVOKE ADMINISTER BULK OPERATIONS TO [my_user_test]
REVOKE ALTER ANY CONNECTION TO [my_user_test]
REVOKE ALTER ANY CREDENTIAL TO [my_user_test]
REVOKE ALTER ANY DATABASE TO [my_user_test]
REVOKE ALTER ANY ENDPOINT TO [my_user_test]
REVOKE ALTER ANY EVENT NOTIFICATION TO [my_user_test]
REVOKE ALTER ANY LINKED SERVER TO [my_user_test]
REVOKE ALTER ANY LOGIN TO [my_user_test]
REVOKE ALTER ANY SERVER AUDIT TO [my_user_test]
REVOKE ALTER RESOURCES TO [my_user_test]
REVOKE ALTER SERVER STATE TO [my_user_test]
REVOKE ALTER SETTINGS TO [my_user_test]
REVOKE ALTER TRACE TO [my_user_test]
REVOKE AUTHENTICATE SERVER TO [my_user_test]
REVOKE CONNECT SQL TO [my_user_test]
REVOKE CONTROL SERVER TO [my_user_test]
REVOKE CREATE ANY DATABASE TO [my_user_test]
REVOKE CREATE DDL EVENT NOTIFICATION TO [my_user_test]
REVOKE CREATE ENDPOINT TO [my_user_test]
REVOKE CREATE TRACE EVENT NOTIFICATION TO [my_user_test]
REVOKE EXTERNAL ACCESS ASSEMBLY TO [my_user_test]
REVOKE SHUTDOWN TO [my_user_test]
REVOKE UNSAFE ASSEMBLY TO [my_user_test]
REVOKE VIEW ANY DATABASE TO [my_user_test]
REVOKE VIEW ANY DEFINITION TO [my_user_test]
REVOKE VIEW SERVER STATE TO [my_user_test]
```

 
### Revokar permisos nivel base de datos global
```SQL
EXEC sp_droprolemember N'db_accessadmin', N'test_permisos'
EXEC sp_droprolemember N'db_backupoperator', N'test_permisos'
EXEC sp_droprolemember N'db_datareader', N'test_permisos'
EXEC sp_droprolemember N'db_datawriter', N'test_permisos'
EXEC sp_droprolemember N'db_ddladmin', N'test_permisos'
EXEC sp_droprolemember N'db_denydatareader', N'test_permisos'
EXEC sp_droprolemember N'db_denydatawriter', N'test_permisos'
EXEC sp_droprolemember N'db_owner', N'test_permisos'
EXEC sp_droprolemember N'db_securityadmin', N'test_permisos'
```


### Revokar permisos nivel base de datos especificos
```SQL
REVOKE SELECT ON tabla_vista FROM usuario;
REVOKE INSERT ON tabla FROM usuario;
REVOKE UPDATE ON tabla FROM usuario;
REVOKE DELETE ON tabla FROM usuario;
REVOKE EXECUTE ON procedimiento_almacenado FROM usuario;
REVOKE execute on SCHEMA::dbo TO  nuevo_test; -- eliminar los permisos de ejecucion en todo el esquema
REVOKE REFERENCES ON tabla FROM usuario;
REVOKE CONTROL ON tabla FROM usuario;
REVOKE ALTER ON objeto FROM usuario;
REVOKE VIEW DEFINITION FROM usuario;
```

# Quitar de un rol a un usuario 
```SQL
ALTER ROLE [db_Rol_Lectura] DROP MEMBER [myempresa\omar.lopez]
```

#### Ver si un usuario esta en un rol
```SQL
SELECT 
    DP.name AS UserName,
    DP.type_desc AS UserType,
    DP.default_schema_name AS DefaultSchema,
    RP.name AS RoleName
FROM sys.database_principals DP
LEFT JOIN sys.database_role_members DRM ON DRM.member_principal_id = DP.principal_id
LEFT JOIN sys.database_principals RP ON DRM.role_principal_id = RP.principal_id
```


### Habilitar/ Desabilitar/ Bloquear la conexion de un usuario sin eliminarlo 

```SQL
***** este solo se puede hacer en la master *****
GRANT CONNECT SQL TO [test_permisos]
DENY CONNECT SQL TO [test_permisos]

***** Este se puede realizar en todas las base de datos no permite hacer login a un usuario *****

ALTER LOGIN [test_permisos] ENABLE
ALTER LOGIN [test_permisos] DISABLE
```

### Problemas para iniciar sesion por usuario huérfanos 
Este detalle se puede presentar porque el  sid usuario creado en la base de datos no coincide con el sid login, o  puede ser que el usuario de la base de datos no se elimino y que el login si se elimino , entonces por eso se dice que
el usuario se quedo huérfanos porque ya no esta ligado a un login, y siempre un usuario debe de tener un login y coincidir su sid 




**sp_change_users_login** es un procedimiento almacenado en SQL Server que solía utilizarse para corregir la desincronización entre un usuario de base de datos y su inicio de sesión correspondiente en el servidor de base de datos.
```SQL
***** Identificar usuarios sin asociar con logins: *****

select name,sid from sys.database_principals where name = 'systest'
select name,sid  from sys.server_principals  where name = 'systest'

-- Si no coinciden entonces es un usuario huérfanos
SELECT a.name, a.sid, b.sid, a.type_desc
FROM sys.database_principals AS a
LEFT JOIN sys.server_principals AS b on a.name COLLATE DATABASE_DEFAULT = b.name COLLATE DATABASE_DEFAULT
where a.type_desc in('WINDOWS_USER', 'SQL_USER' ,  'DATABASE_ROLE','WINDOWS_GROUP') and 
a.sid != b.sid  and  a.name != 'public'
ORDER BY a.type_desc,a.name;

-- o puedes usar el procedimiento que es para lo mismo
EXEC sp_change_users_login 'Report';




***** Vincular un usuario huérfano con un inicio de sesión: ***** 
--- Este comando intenta automáticamente vincular usuarios huérfanos con inicios de sesión que tengan el mismo nombre. Si no existe un inicio de sesión con el mismo nombre, lo crea y le asigna una contraseña.
EXEC sp_change_users_login 'Auto_Fix', 'nombre_usuario', NULL, 'contraseña';
EXEC sp_change_users_login 'Auto_Fix', 'nombre_usuario'; -- si no colocas contraseña  funciona como el Update_One

-- Este comando vincula un usuario específico de la base de datos con un inicio de sesión existente. No crea nuevos inicios de sesión.
EXEC sp_change_users_login 'Update_One', 'nombre_usuario', 'nombre_login';


***** OTRA OPCIÓN ES ***** 
ALTER USER nombre_de_usuario WITH LOGIN = nombre_de_login;
```


### Copiar mismo permisos de un usuario o todos los usuarios 
```SQL
******** PASO #1 | CREAR TABLA TEMPORAL ********
CREATE TABLE #userpriv (
	db VARCHAR(200),
    usuario VARCHAR(200),
    permiso VARCHAR(200)
);


******** PASO #2 | CONSULTAR Y INSERTAR LOS REGISTROS EN LA TEMPORAL ********
 select 'use '+ name + ' insert into  #userpriv select * from 
( SELECT DB_NAME() db, p.name user_nm, r.name permiso 
FROM sys.database_role_members m
INNER JOIN sys.database_principals r ON m.role_principal_id = r.principal_id  
INNER JOIN sys.database_principals p ON m.member_principal_id = p.principal_id AND p.type_desc = ''SQL_USER''
WHERE p.name IN (SELECT name FROM sys.server_principals WHERE type_desc IN (''WINDOWS_LOGIN'', ''SQL_LOGIN'', ''SERVER_ROLE'', ''WINDOWS_GROUP'')

-- and name = ''MY_USER_TEST'' --- aqui le pones el nombre del usuario que quieres buscar en todas las base de datos 

)) as a '
cnt_db from sys.databases where database_id > 4



******** PASO #2 | IMPRIMIR LOS RESULTADOS ********

DECLARE @dbName NVARCHAR(100), @roleName NVARCHAR(100), @privilege NVARCHAR(100)
DECLARE @previousDbName NVARCHAR(100) = ''

DECLARE @dbRoleMembers CURSOR

SET @dbRoleMembers = CURSOR FOR
select * from #userpriv order by db, usuario

OPEN @dbRoleMembers
FETCH NEXT FROM @dbRoleMembers INTO @dbName, @roleName, @privilege

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @dbName <> @previousDbName
    BEGIN
        SET @previousDbName = @dbName
        PRINT 'USE ' + QUOTENAME(@dbName) --- Este código devolverá las cosas con'[]' 
    END
    
    PRINT 'EXEC sp_addrolemember  N''' + @privilege + ''', N''' + @roleName + ''' '
    
    FETCH NEXT FROM @dbRoleMembers INTO @dbName, @roleName, @privilege
END

CLOSE @dbRoleMembers
DEALLOCATE @dbRoleMembers

```

# cambiar owner
```SQL
/* ASIGNAR EL OWNER */
EXEC sp_changedbowner 'NuevoPropietario';
EXEC sp_changeobjectowner 'My_Object', 'My_user';


alter AUTHORIZATION ON OBJECT::CatPersona TO [test2]
ALTER AUTHORIZATION ON DATABASE::AdventureWorks2019 TO [testt];
Alter AUTHORIZATION ON SCHEMA::MYESQUEMA TO [testt];  

/* saber quien es el owner  */ 
SELECT name as [DB Name], suser_sname(owner_sid) as [Owner]  FROM sys.databases
SELECT name as [Table Name],USER_NAME(principal_id) AS [Table_Owner], type_desc FROM sys.objects where principal_id is not null
SELECT schema_name, schema_owner FROM information_schema.schemata where not SCHEMA_NAME in('db_owner' ,'db_accessadmin' ,'db_securityadmin' ,'db_ddladmin' ,'db_backupoperator' ,'db_datareader' ,'db_datawriter' ,'db_denydatareader' ,'db_denydatawriter')


/* *** REFERENCE **
https://www.mssqltips.com/sqlservertip/6836/sql-alter-authorization-examples/
*/

```

### info extra
Procedimientos almacenados y funciones que muestran información de usuarios y sus permisos
```SQL
EXEC sp_helprolemember
EXEC sp_helprotect
EXEC sp_helpuser
EXEC sp_helplogins


SELECT * FROM master.sys.sysusers WHERE islogin = 1



SELECT * FROM sysobjects a
LEFT JOIN syspermissions b
ON a.id=b.id
WHERE a.xtype='P'
AND b.id IS NULL

```

### usuario guest
Cuando inicia sesión en SQL Server, primero autentica sus credenciales de login en el servidor. Si tiene éxito, SQL Server comprueba si su inicio de sesión está asociado o asignado a un usuario de la base de datos en la que está intentando acceder. Si es así, SQL Server otorga el acceso de inicio de sesión a la base de datos como usuario de la base de datos.
<br><br>
Si no existe tal asignación, SQL Server verifica si existe activado el usuario invitado (guest). Si es así, el usuario conectado tiene acceso a la base de datos como invitado. Si la cuenta de invitado esta desactivada, SQL Server niega el acceso a la base de datos.

```sql
SELECT name, permission_name, state_desc
FROM sys.database_principals dp
INNER JOIN sys.server_permissions sp
ON dp.principal_id = sp.grantee_principal_id
WHERE name = ‘guest’ AND permission_name = ‘CONNECT’

Para habilitar al usuario invitado en la base de datos donde se necesita podemos ejecutar la siguiente instrucción:

GRANT CONNECT TO guest
GO

y para deshabilitarlo usamos las sentencias:

REVOKE CONNECT TO guest
GO

https://soportesql.wordpress.com/2021/07/11/habilitar-al-usuario-invitado-en-el-sql-server/
```



Con esto puedes ver el codigo del procedimiento almacenado 
```SQL
EXEC SP_HELPTEXT 'sp_grantdbaccess'

--- AQUI ESTAN TODOS LOS PERMISOS 
SELECT * FROM fn_builtin_permissions(NULL);

```

public: Aunque técnicamente no es un rol asignable, todos los usuarios son miembros del rol público por defecto. Este rol tiene los permisos connect básicos necesarios para todos los usuarios de la base de datos.





https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/create-a-database-user?view=sql-server-ver16

https://gist.github.com/ryzr/e96e7a20179a0e520fbff094a6d7d8b1


### Cambiar nombre de usuario 
```SQL

EXEC sp_rename 'antiguo_login', 'nuevo_login';
EXEC sp_rename 'oldUser', 'newUser';

ALTER USER antiguo_usuario WITH NAME = nuevo_usuario;

```


### Bloquear por columnas 
```SQL

 revoke  SELECT    ON object::dbo.clientes(email) TO jose;

```


#### Pendientes por actualizar este documento :
```SQL
1- especificar para que sirve cada permiso
2.- agregar una query para eliminar el usuario de cada base de datos ya que no se elimina el permiso en todos
3.- poder hacer que se ejecuten los reportes con sp_executesql
4.- ver que permisos tienen los roles
5.- agregar una query para que elimine el usuario por completo y no se quede en la base de datos el registro del usuario
```
