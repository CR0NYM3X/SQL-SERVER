
# Objetivo:
Es lograr administrar los usuarios de manera necesaria para llevar acabo las actividades  laborales y entender un poco la estructura de los usuarios

### Niveles de Permisos: 
En SQL server existen los permisos 

**Nivel servidor:**  Estos permisos están asociados con la administración y control general del servidor, por ejemplo  la creacion de login de  usuarios , la creacion base de datos, la creacion  SQL <br><br>
**Nivel base de datos :** Estos permisos se aplican a objetos específicos dentro de una base de datos.  por ejemplo la creación, eliminación , la modificación o inserción de los objetos o datos  <br><br>
- 1  **Permisos especificos:** Este le especificas que permiso quieres para un objeto o varios objetos
- 2  **Permisos globales:**  con los permisos globales le indicar por ejemplo que quiero permiso de lecturas en todas las tablas

**permisos de configuración :** Estos son permisos que permiten realizar actividades muy especificas que un usuario comun no utiliza, por ejemplo respaldos, el copiado de información, la modificacion de un link server o eventos de auditoria 

 

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
select * from sys.database_principals where  type_desc in('WINDOWS_USER', 'SQL_USER' ,  'DATABASE_ROLE') order by type_desc,name  

--- Esta query puede ver el hash los SQL_USER 
SELECT name,password_hash,default_database_name, is_expiration_checked, is_policy_checked  FROM sys.sql_logins order by name
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


### Asignar permisos de configuración a un login 
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


### Asignar permisos  Nivel servidor  a un login 
### Asignar permisos  Nivel base de datos a un login 
**Permisos globales:**
**Permisos especificos:**




https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/create-a-database-user?view=sql-server-ver16

```
```
