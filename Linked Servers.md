

# Que es Linked Servers:
Permíten conectarse a una base de datos externa y realizar consultas en ella, no importa si es postgresql o sql server


**se recomienda usar openquery por temas de rendimiento**

# Ejemplos de uso: 

### Agregar un usuario al login de linkeo
```SQL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'192.44.4.85', @locallogin = N'test_user', @useself = N'True'
```

### Ver la configuración de los linked

```SQL
SELECT * FROM sys.linked_logins WHERE server_id in(SELECT server_id FROM sys.servers WHERE is_linked = 1);
SELECT  * FROM sys.servers  WHERE is_linked = 1;
 select * from sys.remote_logins
```

### Ejemplo usando un linkeo
```
SELECT * FROM [Nobre_linkeo].[NombreBaseDatos].[NombreEsquema].[NombreTabla];
```

### ver los linkeos que existen
```
EXEC sp_linkedservers;
```

### Hacer un test a los linkeos 
```
EXEC sp_testlinkedserver N'NOMBRE_DE_LINKEO';
```

### Crear un linkeo  básico de sql server a sql server

[Doc Oficial](https://learn.microsoft.com/es-es/sql/relational-databases/system-stored-procedures/sp-addlinkedserver-transact-sql?view=sql-server-ver16)

- Antes de crear un linkeo vamos a explicar el uso de los procedimientos almacenados que se usan:

**`sp_addlinkedserver`**  Se especifica el nombre del servidor vinculado, el proveedor OLE DB o la conexión ODBC que se utilizará para acceder a ese servidor y, en algunos casos, información adicional sobre la conexión <br> 
**`sp_addlinkedsrvlogin`** Después de establecer un linked server, este procedimiento se usa para configurar los permisos de inicio de sesión remoto para el linked server. Esto se hace para autenticarse en el servidor  
remoto y tener permisos apropiados para acceder a las bases de datos o tablas remotas.<br>
**`sp_serveroption`**  Este procedimiento se utiliza para configurar las opciones de configuración del servidor vinculado. Se pueden establecer diferentes opciones, como habilitar la ejecución remota 

```

**************  CREANDO EL SERVER LINK **************
EXEC master.dbo.sp_addlinkedserver 
	@server = N'MY_LINKEO_TEST1', 
	@srvproduct=N'', 
	@provider=N'SQLNCLI',   /* Tambien puedes usar este proveedor --> @provider=N'SQLOLEDB' */
	@datasrc=N'192.168.1.100'

************** CREANDO LOGIN PARA EL LINKEO **************
EXEC master.dbo.sp_addlinkedsrvlogin 
	@rmtsrvname=N'MY_LINKEO_TEST1',
	@useself=N'False',
	@locallogin=NULL,
	@rmtuser=N'MY_USER_LINKEO',
	@rmtpassword='MY_PASSWORD123456'

************** OPCIONES DE LINKEO **************
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'rpc', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'rpc out', @optvalue=N'true' ----> este nos permite ejecutar procedimientos 
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'use remote collation', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'MY_LINKEO_TEST1', @optname=N'remote proc transaction promotion', @optvalue=N'true'
```


### Eliminar el linkeo y sus login
```
EXEC master.dbo.sp_dropserver @server=N'SOPBODROPACALEX', @droplogins='droplogins'
EXEC sp_dropremotelogin 'NOMBRE_DEL_LINKED_SERVER';
```

# info extra:

 - Se utiliza para forzar la regeneración de la clave maestra del servicio (Service Master Key). La clave maestra del servicio se utiliza para cifrar otras claves en la jerarquía de claves de SQL Server.
```
ALTER SERVICE MASTER KEY FORCE REGENERATE;

--- EXEC sp_addserver @server = 'ServidorRemoto', @local = 'local';
```

- Para conectar el linkeo a  POSTGRESQL se coloca en provider
```
En Provider:  Microsoft OLE DB Provider for ODBC  Drivers
Provider String: Driver={PostgreSQL UNICODE};Server=IP address;Port=5432;Database=myDataBase;Uid=myUsername;Pwd=myPassword;
Para consultar : select *from test2.postgres.[public].empleados



OPTION=3
link server de mssql a mssql https://www.mssqltips.com/sqlservertip/6083/understanding-sql-server-linked-servers/
link server de mssql a psql: https://www.mssqltips.com/sqlservertip/3662/sql-server-and-postgresql-linked-server-configuration-part-2/
PostgreSQL ODBC Driver (psqlODBC) connection strings: https://www.connectionstrings.com/postgresql-odbc-driver-psqlodbc/


https://www.sqlshack.com/how-to-configure-a-linked-server-using-the-odbc-driver/
https://www.sqlshack.com/how-to-create-and-configure-a-linked-server-in-sql-server-management-studio/

```






