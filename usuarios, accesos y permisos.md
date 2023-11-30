
# Objetivo:
Es lograr administrar los usuarios de manera necesaria para llevar acabo las actividades  laborales y entender un poco la estructura de los usuarios

### Niveles de Permisos: 
En SQL server existen los permisos 

**Nivel servidor:**  Estos permisos están asociados con la administración y control general del servidor, por ejemplo  la creacion de login de  usuarios , la creacion base de datos, la creacion  SQL <br><br>
**Nivel base de datos :** Estos permisos se aplican a objetos específicos dentro de una base de datos.  por ejemplo la creación, eliminación , la modificación o inserción de los objetos o datos  <br><br>
- 1  **Permisos especificos:** Este le especificas que permiso quieres para un objeto o varios objetos, como por ejemplos los permisos select, insert, update etc, etc
- 2  **Permisos globales:**  con los permisos globales le indicar por ejemplo que quiero permiso de lecturas en todas las tablas

**permisos de administrador :** Estos son permisos que permiten realizar actividades muy especificas que un usuario comun no utiliza, por ejemplo respaldos, el copiado de información, la modificacion de un link server o eventos de auditoria 

 

### Conceptos Básicos 

![usuarios](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/media/typesofusers.png?view=sql-server-ver16)

`Login :` permite que te conectes al servidor sql server     <br>
`Usuario :` este sirve para asociar un usuario con una base de datos,  **tipos de usuarios:**  WINDOWS_USER y SQL_USER <br>
`Role :` este es un grupo de permisos que se pueden otrogar a un o más de un usuario      <br>
`connect :`  otorga permiso de conexión pero este se crea automaticamente al crear el login y asociar un usuario con una base de datos   <br>


# Ejemplos de uso :

### Buscar un usuario, login o role:

**SQL_LOGIN** ->  son aquellos usuarios que cuando se crearon se les epecifico una contraseña 
**WINDOWS_LOGIN** -> son aquellos usuarios que se autentican con las contraseñas que estan de un active directory

```
--- Con estas querys puedes ver cuando se crearon y se modificaron los usuarios

--- [Recomendada para buscar] Esta query te muestra a nivel servidor todos  los roles, usuarios sql y windows login y grupos  que existen:
select * from sys.server_principals where type_desc in('WINDOWS_LOGIN', 'SQL_LOGIN',  'SERVER_ROLE' , 'WINDOWS_GROUP') order by type_desc,name 

--- Esta query te muestra a nivel de base de datos todo solo los usuarios sql y windows user que se asociaron a una base de datos en especifica 
select * from sys.database_principals where  type_desc in('WINDOWS_USER', 'SQL_USER' ,  'DATABASE_ROLE','WINDOWS_GROUP') order by type_desc,name  

--- Esta query puede ver el hash los SQL_USER 
SELECT name,password_hash,default_database_name, is_expiration_checked, is_policy_checked  FROM sys.sql_logins order by name
```

### ver hash password de todos login sql, no de los windows login, para pasar a otro server
```
exec sp_help_revlogin
```

### Creacion un login :
Al crear el Login le especificamos de que forma se va conectar el servidor , que es con que nombre y contraseña 

```
CREATE LOGIN [MYDOMINIO\miusuario] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [jose-mecanico] WITH PASSWORD=N'123123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
```

### crear un usuario o eliminar:
El crear un usuario, estas especificando que el usuario, que puede abrir la base de datos en la que creaste el usuario 
[Doc. Oficial](https://learn.microsoft.com/es-es/sql/t-sql/statements/create-user-transact-sql?view=sql-server-ver16)

```
use mi_dba_test
go

-- agregar usuarios las dos querys sirven para lo mismo 
EXEC sp_grantdbaccess 'my_user_123','my_user_123'; 
CREATE USER [my_user_123] FOR LOGIN [my_user_123]

-- eliminar usuarios de base de datos 
DROP USER [alex]
```

### Crear un role o eliminar

[Doc. Oficial](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-server-role-transact-sql?view=sql-server-ver16)
```
--- crear roles
CREATE ROLE desarolladores;
CREATE SERVER ROLE testers [AUTHORIZATION owner_name];

--- Eliminar roles
DROP ROLE  desarolladores;
DROP SERVER ROLE  testers;

```

### Asignar permisos  Nivel servidor
```
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
```
select   CONNECTIONPROPERTY ('local_net_address') IP_SERVER,UserName,sum(sysadmin) sysadmin ,sum(securityadmin) securityadmin ,sum(serveradmin ) serveradmin ,sum(setupadmin ) setupadmin ,sum(processadmin ) processadmin ,sum(diskadmin ) diskadmin ,sum(dbcreator) dbcreator ,sum(bulkadmin) bulkadmin from
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
Estos son permisos que permiten realizar actividades muy especificas que un usuario comun no utiliza, por ejemplo respaldos, el copiado de información, la modificacion de un link server o eventos de auditoria 
```
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
```
select CONNECTIONPROPERTY ('local_net_address')  IP_SERVER,username,a1 as ADMINISTER_BULK_OPERATIONS ,a2  as ALTER_ANY_SERVER_AUDIT ,a3  as ALTER_ANY_CREDENTIAL ,a4  as ALTER_ANY_CONNECTION ,a5  as ALTER_ANY_DATABASE ,a6  as ALTER_ANY_EVENT_NOTIFICATION ,a7  as ALTER_ANY_ENDPOINT ,a8  as ALTER_ANY_LOGIN ,a9  as ALTER_ANY_LINKED_SERVER ,a10 as ALTER_RESOURCES ,a11 as ALTER_SERVER_STATE ,a12 as ALTER_SETTINGS ,a13 as ALTER_TRACE ,a14 as AUTHENTICATE_SERVER ,a15 as CONTROL_SERVER /*,a16 as CONNECT_SQL*/ ,a17 as CREATE_ANY_DATABASE ,a18 as CREATE_DDL_EVENT_NOTIFICATION ,a19 as CREATE_ENDPOINT ,a20 as CREATE_TRACE_EVENT_NOTIFICATION ,a21 as SHUTDOWN_ ,a22 as EXTERNAL_ACCESS_ASSEMBLY ,a23 as UNSAFE_ASSEMBLY  from  
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
**Permisos globales:** Estos permisos se asigna a una base de datos especifica, pero al asignarle un permiso, se agrega de manera global para todos sus objetos, por ejemplo el procedimiento almacenado  sp_addrolemember sólo te da permisos de lectura 

```
EXEC sp_addrolemember N'db_accessadmin', N'my_user_test'
EXEC sp_addrolemember N'db_backupoperator', N'my_user_test'
EXEC sp_addrolemember N'db_datareader', N'my_user_test'
EXEC sp_addrolemember N'db_datawriter', N'my_user_test'
EXEC sp_addrolemember N'db_ddladmin', N'my_user_test'
EXEC sp_addrolemember N'db_denydatareader', N'my_user_test'
EXEC sp_addrolemember N'db_denydatawriter', N'my_user_test'
EXEC sp_addrolemember N'db_owner', N'my_user_test'
EXEC sp_addrolemember N'db_securityadmin', N'my_user_test'
```

**Crear reporte de Permisos globales de todas las base de datos**
```
1.-  creamos una la tabla temporal
CREATE TABLE #userpriv (
	IP_SERVER VARCHAR(200),
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
(select CONNECTIONPROPERTY ('local_net_address') IP_SERVER, db , usuario , sum(db_accessadmin)  db_accessadmin ,sum(db_backupoperator) db_backupoperator,sum(db_datareader )	db_datareader,sum(db_datawriter) db_datawriter	,sum(db_ddladmin) db_ddladmin ,sum(db_denydatareader)  db_denydatareader ,sum(db_denydatawriter) db_denydatawriter,sum(db_owner) db_owner,sum(db_securityadmin ) db_securityadmin   from (SELECT 
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
select * from #userpriv where 
 usuario NOT LIKE 'NT AUTHORITY%'
    AND usuario NOT LIKE 'NT SERVICE%'
	AND usuario NOT LIKE 'public'
	AND usuario NOT LIKE '##%'
	AND usuario NOT LIKE 'dbo'
	and (db_accessadmin != 0 or db_backupoperator != 0  or db_datawriter != 0 or db_ddladmin != 0 or db_denydatareader != 0 or db_denydatawriter != 0 or db_owner != 0 or db_securityadmin != 0)
 order by usuario
```

**Permisos especificos:**
Este le especificas que permiso quieres para un objeto o varios objetos, como por ejemplos los permisos select, insert, update etc, etc
```
GRANT VIEW DEFINITION ON SCHEMA::dbo TO [MYDOMINIO\my_user_test_windows];
GRANT CONNECT, SELECT , UPDATE,  INSERT, DELETE, ALTER,  REFERENCES ON SCHEMA::dbo TO my_user_test;
GRANT UPDATE ON dbo.my_tabla TO my_usuario;

--- permisos a todos los procedimientos 
SELECT  'GRANT EXECUTE ON [' + SCHEMA_NAME(schema_id) + '].[' + name + '] TO [TuRolOUsuario];' + CHAR(13) FROM sys.procedures;

grant execute on Proc_calcularImpuestos to [MYDOMINIOS\my_user_test_windows] 
GRANT EXECUTE ON SCHEMA::dbo TO my_user_test_windows; -- permiso de EXECUTE  a todos los objetos

```

**Ver permisos especificos pero de manera generica**
```
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

```

**Crear un reporte de Permisos especificos de todas las base de datos**
```
1.-  creamos una la tabla temporal
CREATE TABLE #userpriv_grant (
	IP_SERVER VARCHAR(200),
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
(select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER,
	    DB_NAME() db,
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
select * from #userpriv_grant where 
 usuario NOT LIKE 'NT AUTHORITY%'
    AND usuario NOT LIKE 'NT SERVICE%'
	AND usuario NOT LIKE 'public'
	AND usuario NOT LIKE '##%'
	AND usuario NOT LIKE 'dbo'
 order by usuario
```


	




### Bloquear la conexion de un usuario sin eliminarlo 
--- este solo se puede hacer en la master
GRANT CONNECT SQL TO [test_permisos]
DENY CONNECT SQL TO [test_permisos]

---- este se puede realizar en todas las base de datos 
ALTER LOGIN [test_permisos] ENABLE
ALTER LOGIN [test_permisos] DISABLE

### info extra
Procedimientos almacenados y funciones que muestran información de usuarios y sus permisos
```
EXEC sp_helprotect
EXEC sp_helpuser


SELECT * FROM fn_my_permissions(NULL, 'DATABASE'); --- APPLICATION ROLE, ASSEMBLY, ASYMMETRIC KEY, CERTIFICATE, CONTRACT, DATABASE, ENDPOINT,
FULLTEXT CATALOG, LOGIN, MESSAGE TYPE, OBJECT, REMOTE SERVICE BINDING, ROLE, ROUTE, SCHEMA, SERVER, SERVICE, SYMMETRIC KEY, TYPE, USER, XML SCHEMA COLLECTION.

SELECT * FROM fn_builtin_permissions(NULL);
```

Con esto puedes ver el codigo del procedimiento almacenado 
```
EXEC SP_HELPTEXT 'sp_grantdbaccess'
```

https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/create-a-database-user?view=sql-server-ver16

#### Pendientes por actualizar este documento :
```
1- especificar para que sirve cada permiso
2.- agregar una query para eliminar el usuario de cada base de datos ya que no se elimina el permiso en todos 
```
