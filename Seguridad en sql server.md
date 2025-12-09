
[MFA - Tutorial: Set up Microsoft Entra authentication for SQL Server with app registration](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/azure-ad-authentication-sql-server-setup-tutorial?view=sql-server-ver17)

### 🔐 Usuarios comunes en SQL Server

#### 1. **`dbo` (Database Owner)**
- Es el **propietario de la base de datos**.
- Tiene **todos los permisos** sobre todos los objetos de la base de datos.
- Normalmente, cualquier usuario que sea dueño de la base de datos o tenga el rol `db_owner` se considera `dbo`.
- Si un objeto es creado por `dbo`, se puede acceder como `dbo.NombreObjeto`.

#### 2. **`guest`**
- Permite que los usuarios que **no tienen un usuario explícito en la base de datos** puedan acceder a ella **si el usuario `guest` tiene permisos**.
- Es útil para accesos públicos o compartidos, pero **no se recomienda** habilitarlo en bases de datos sensibles.
- Si no se le asignan permisos, los usuarios sin usuario en la base de datos **no podrán acceder**.

#### 3. **`public`**
- Es un **rol especial** que **todos los usuarios** de la base de datos heredan automáticamente.
- Los permisos asignados al rol `public` se aplican a **todos los usuarios**, incluso si no tienen permisos específicos.
- Se usa para definir permisos **mínimos o comunes**.

### Ver los permisos de esos roles
```
select USER_NAME(grantee_principal_id), OBJECT_NAME(major_id) , * from sys.database_permissions
where USER_NAME(grantee_principal_id) in('public','guest','dbo')
order by USER_NAME(grantee_principal_id),permission_name,OBJECT_NAME(major_id) 
 ```




### Mayor seguridad de monitoreo
```
Event Sessions: Para monitoreo detallado y flexible de eventos de sistema y rendimiento.
Trace: Para diagnóstico detallado y análisis de consultas y eventos específicos.
Auditorías: Para cumplimiento normativo y seguridad, registrando eventos de acceso a datos críticos.
```

# ver las configuraciones 
```
select * from sys.configurations;
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
```

# Desactivar usuarios peligroso:
```
------- Deshabilita - Usuario SA -------
ALTER LOGIN [sa] DISABLE

------- No se puede borrar el usaurio pero se puede Deshabilitar ------- 
execute SYS.sp_MSforeachdb 'use [?];  REVOKE CONNECT FROM GUEST;'
```



# Validar el tipo de autenticación de sql server 
Devolverá un valor 1 si solo se permite la autenticación integrada de Windows (también conocida como autenticación de Windows), lo que significa que el servidor está configurado para permitir
únicamente iniciar sesión usando credenciales de Windows. Si devuelve 0, significa que también se permite la autenticación de SQL Server.
```
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')

xp_loginconfig 'login mode';

```


# Cuanta de servicio por default
En SQL Server, **`NT SERVICE\SYSTEM`** es una cuenta de sistema incorporada en Windows que se utiliza para ejecutar servicios y procesos del sistema operativo. 
Esta cuenta tiene privilegios elevados y se utiliza para realizar tareas de alto nivel en el sistema. Cuando se configura SQL Server para usar una cuenta de servicio determinada, como en el caso de los servicios de SQL Server durante la instalación, puede optarse por usar NT SERVICE\SYSTEM como cuenta de servicio.


# Como habilitar xp_cmdshell para usuario que no son sysadmin
```sql

--- validar si existe alguna credencia 
SELECT * FROM sys.credentials WHERE name = '##xp_cmdshell_proxy_account##';

--- Validar si que usuario se usa para levantar el servicio
	SELECT * FROM sys.dm_server_services;

use master 

----- HABILITAMOS EL PROCEDIMIENTO YA QUE POR SEGURIDAD VIENE DESHABILITADO
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
 

--- creamos el usuario en la master ya que el procedimiento existe en la master  
CREATE USER [exe_1] FOR LOGIN [exe_1]

---- damos permisos al usuario para que pueda usar el procedimiento 
GRANT EXECUTE ON master.dbo.xp_cmdshell TO [exe_1] ;   

/* CREAMOS LA CREDENCIA , SE OCUPA UN USUARIO NIVEL S.O , ESTO PERMITIRA QUE LAS PERSONAS QUE NO SON SYSADMIN USEN ESE USUARIO NVL S.O  PARA EJECUTAR COMANDO EN EL SERVIDOR 
#### EN CASO DE QUE COLOQUES MAL EL USUARIO Y CONTRASEÑA SE VA GUARDAR LA CREDENCIAL, EL PROBLEMA VA SER CUANDO EL USUARIO USE xp_cmdshell
APARECERA ESTE ERROR --> ( An error occurred during the execution of xp_cmdshell. A call to 'LogonUserW' failed with error code: '1326')  */
CREATE CREDENTIAL ##xp_cmdshell_proxy_account##
WITH IDENTITY =  'dominio\user_admin', 
SECRET = '123123';



/*
### Este procedimiento hace lo mismo que crear la credencia de manera manual pero la diferencia es que 
validara que el usuario nivel S.O  que estas ingresando  si exista y tenga la contraseña correcta, en caso de que este mal marcara el error  
---> ( An error occurred during the execution of sp_xp_cmdshell_proxy_account. Possible reasons: the provided account was invalid or the '##xp_cmdshell_proxy_account##' credential could not be created. Error code: 1326(The user name or password is incorrect.), Error Status: 0.) 
*/
EXEC sp_xp_cmdshell_proxy_account 'dominio\user_admin', '123123';

--- PROBAMOS SI FUNCIONO 
EXEC xp_cmdshell 'whoami';


---- BIBLIOGRAFÍAS 
 https://www.sqlshack.com/xp_cmdshell-and-sp_xp_cmdshell_proxy_account-stored-procedures-in-sql-server/



/* for mount points, something like this */
EXECUTE sys.xp_cmdshell 'wmic volume get name, freespace, capacity, label'
/* the base wmi query that does not support mount points */
EXECUTE xp_cmdshell 'wmic logicaldisk get name,freespace,size,volumename,blocksize'



---------- Esto no lo e confirmado si funciona tengo que validar
CREATE CREDENTIAL [CmdShellCredential]
WITH IDENTITY = 'DOMAIN\CmdShellUser', 
SECRET = 'cmdshellpassword';
EXEC sp_add_proxy 
    @proxy_name = 'CmdShellProxy', 
    @credential_name = 'CmdShellCredential';
EXEC sp_grant_proxy_to_subsystem 
    @proxy_name = 'CmdShellProxy', 
    @subsystem_name = 'CmdExec';






```



# Ejecutar comandos en windows desde sql server 
```
exec master..xp_cmdshell 'dir' -- ejecuta comandos 
```

**Deshabilitar o Habilitar estas opciones**
```
********** DESHABILITAR EL PROCEDIMIENTO **********
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;

********** HABILITADOR EL PROCEDIMIENTO **********
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
```


# Enviar correos desde sql server 
```
EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'TuPerfilDeCorreo',  
    @recipients = 'destinatario@example.com',  
    @subject = 'Asunto del Correo',  
    @body = 'Cuerpo del Correo',
    @query = 'SELECT * FROM TuTabla',
    @attach_query_result_as_file = 1;
```
**Deshabilitar o Habilitar estas opciones**
```
********** DESHABILITAR EL PROCEDIMIENTO **********
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 0;
EXEC sp_configure 'SQL Mail XPs', 0;
RECONFIGURE;

********** HABILITADOR EL PROCEDIMIENTO **********
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE;
```

# Cambiar las configuraciones del sql server 
```
********** ver las configuraciones que hay actualmente **********
EXEC sp_configure;

********** cambiar una configuracion **********
sp_configure 'show advanced options', 1; --- cambia la configuración de sql server 
```

# Lectura y modificacion del registro de windows 

**xp_regread, xp_regwrite:** Estas funciones permiten leer y escribir en el registro /regedit del sistema. Si se usan sin restricciones, podrían abrir la puerta a cambios no autorizados en la configuración del servidor.
```SQL

-- Te dice la llave  de registro y te indica el valor de cada llave 
SELECT *  FROM sys.dm_server_registry


********** procedimientos **********
xp_regaddmultistring
xp_regdeletekey
xp_regdeletevalue
xp_regenumvalues
xp_regenumkeys
xp_regread
xp_regwrite
xp_regremovemultistring
xp_instance_regaddmultistring
xp_instance_regdeletekey
xp_instance_regdeletevalue
xp_instance_regenumkeys
xp_instance_regenumvalues
xp_instance_regread
xp_instance_regremovemultistring
xp_instance_regwrite



********** leer registros como la version de windows | con este ejemplo vamos a ver la version del sistema operativo  **********
DECLARE @ProductName NVARCHAR(100), 
        @CurrentVersion NVARCHAR(100), 
        @BuildLab NVARCHAR(100),
        @EditionID NVARCHAR(100),
        @ProductId NVARCHAR(100);

EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'ProductName', @ProductName OUTPUT;
EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'CurrentVersion', @CurrentVersion OUTPUT;
EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'BuildLab', @BuildLab OUTPUT;
EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'EditionID', @EditionID OUTPUT;
EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'ProductId', @ProductId OUTPUT;

SELECT @ProductName AS 'ProductName',
       @CurrentVersion AS 'CurrentVersion',
       @BuildLab AS 'BuildLab',
       @EditionID AS 'EditionID',
       @ProductId AS 'ProductId';

********** SABER LAS CANTIDADES DE INSTANCIAS QUE HAY EN EL SERVIDOR **********
EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Microsoft SQL Server', 'InstalledInstances'

********** CAMBIAR EL MODO DE LOGIN DE WINDOWS ATENTICATION A Mixed **********
	xp_loginconfig 'login mode';
	EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2;


********** Leer registros Opcion #2 **********
---  acceder a configuraciones y parámetros almacenados en el registro de Windows que están asociados con la instancia de SQL Server actual
EXEC xp_instance_regread 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory';

----- otros parámetros
  N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory';
  N'System\CurrentControlSet\Services\MSSQLSERVER',  N'ImagePath';
  N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData';
  N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultLog';
  N'Software\Microsoft\Microsoft SQL Server\MSSQLServer\CurrentVersion', N'CurrentVersion';	
  N'Software\Microsoft\MSSQLServer\Setup', N'SQLPath';
  N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IPAll', N'TcpPort';


---- Cambiar la ruta de error log anget 
  N'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SQLserverAgent

---- Para ver el último usuario que ha iniciado sesión en el sistema, puedes ir 
 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI', 'LastLoggedOnUser'  usuario
 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI', 'LastLoggedOnDisplayName' --- saber el nombre completo

--- usuarios registrados en el servidor
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\    ProfileImagePath

------ 

********** escribir en registros **********
EXEC xp_regwrite 'HKEY_CURRENT_USER', 'Software\MyApp', 'Version', 'REG_SZ', '1.0';


EXECUTE master.sys.xp_instance_regwrite
    'HKEY_LOCAL_MACHINE',
    'Software\Microsoft\MSSQLSERVER\SQLServerAgent\MyNewKey',
    'MyNewValue',
    'REG_SZ',
    'Now you see me!';

EXECUTE master.sys.xp_instance_regread
    'HKEY_LOCAL_MACHINE',
    'Software\Microsoft\MSSQLSERVER\SQLServerAgent\MyNewKey',
    'MyNewValue';

-------------------------- VER LAS CUENTAS DE SERVICIO  DE SQL SERVER ------------------------------------------

-- 1. Servicio principal de SQL Server (Motor de base de datos)
DECLARE @ServiceAccountSQL NVARCHAR(256);
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER', 
    N'ObjectName', 
    @ServiceAccountSQL OUTPUT;
SELECT 
    'Motor de SQL Server' AS Servicio,
    @ServiceAccountSQL AS Cuenta;

-- 2. Servicio SQL Server Agent (Agente)
DECLARE @ServiceAccountAgent NVARCHAR(256);
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT', 
    N'ObjectName', 
    @ServiceAccountAgent OUTPUT;
SELECT 
    'SQL Server Agent' AS Servicio,
    @ServiceAccountAgent AS Cuenta;

-- 3. Servicio Full-Text Search (Búsqueda de texto completo)
DECLARE @ServiceAccountFullText NVARCHAR(256);
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\MSSQLFDLauncher', 
    N'ObjectName', 
    @ServiceAccountFullText OUTPUT;
SELECT 
    'Full-Text Search' AS Servicio,
    @ServiceAccountFullText AS Cuenta;

-- 4. Servicio Integration Services (SSIS)
DECLARE @ServiceAccountSSIS NVARCHAR(256);
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\MsDtsServer160', 
    N'ObjectName', 
    @ServiceAccountSSIS OUTPUT;
SELECT 
    'Integration Services (SSIS)' AS Servicio,
    @ServiceAccountSSIS AS Cuenta;

-- 5. Servicio Analysis Services (SSAS) - Si está instalado
DECLARE @ServiceAccountSSAS NVARCHAR(256);
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\MSOLAP$MSSQLSERVER', 
    N'ObjectName', 
    @ServiceAccountSSAS OUTPUT;
SELECT 
    'Analysis Services (SSAS)' AS Servicio,
    @ServiceAccountSSAS AS Cuenta;

-- 6. Servicio Reporting Services (SSRS) - Si está instalado
DECLARE @ServiceAccountSSRS NVARCHAR(256);
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\ReportServer$MSSQLSERVER', 
    N'ObjectName', 
    @ServiceAccountSSRS OUTPUT;
SELECT 
    'Reporting Services (SSRS)' AS Servicio,
    @ServiceAccountSSRS AS Cuenta;

```
Referencias: <br>
https://sqlsolutionsgroup.com/working-registry-sql-server/ <br>
https://book.hacktricks.xyz/generic-methodologies-and-resources/basic-forensic-methodology/windows-forensics/interesting-windows-registry-keys

**Deshabilitar o Habilitar estas opciones**

```
********** DESHABILITAR EL PROCEDIMIENTO **********
-- Revocar permisos para xp_instance_regread
DENY EXECUTE ON xp_instance_regread TO [UsuarioOGrupo];

-- Revocar permisos para xp_regread
DENY EXECUTE ON xp_regread TO [UsuarioOGrupo];

-- Revocar permisos para xp_regwrite
DENY EXECUTE ON xp_regwrite TO [UsuarioOGrupo];

--- ejemplo como denegar 
https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2018-03-09/finding/V-79327
```



# Ejecuta una query asiendote pasar por un usuario 
Estamos ejecutando una query como si estuvieramos conectados con este usuario
```

GRANT IMPERSONATE ON DATABASE::test_db TO user_A


USE master;  
GRANT IMPERSONATE ON LOGIN::user_A to USER_B;  
GRANT IMPERSONATE ON USER::user_A to USER_B;  


EXECUTE AS USER = 'MYDOMINIO\USER_ADMINS123';

	SELECT SUSER_SNAME(),DB_NAME(),entity_name,permission_name FROM fn_my_permissions(NULL, 'DATABASE') 

REVERT;
```

**Ver que db tiene habilitada esta opcion**
```
SELECT a.name,b.is_trustworthy_on
FROM master..sysdatabases as a
INNER JOIN sys.databases as b
ON a.name=b.name;
```

**Validar si el usuario actual es sysadmin**
```
SELECT is_srvrolemember('sysadmin')
```

**Deshabilitar o Habilitar estas opciones**
Esto se tiene que ejecutar en la base de datos que quieres deshabilitarle esta opción
```
******** Habilitar EXECUTE AS: ******** 
ALTER DATABASE [new_dba_test24] SET TRUSTWORTHY ON;

******** Deshabilitar EXECUTE AS: ********
ALTER DATABASE [new_dba_test24] SET TRUSTWORTHY OFF;
```


# Suplantar a un usuario 
SQL Server, otorga permiso al usuario [MyUser1] para actuar como si fuera el usuario sa (System Administrator). permite que un usuario tenga la capacidad de ejecutar sentencias 
bajo la identidad de otro usuario. En este caso, estás otorgando a [MyUser1] la capacidad de actuar como el usuario sa.
```
GRANT IMPERSONATE ON LOGIN::sa to [MyUser1];
```



# Ejecutar lenguajes como R o Python:
procedimiento almacenado que permite ejecutar scripts escritos en lenguajes externos, como R o Python, dentro de SQL Server
```
CREATE TABLE Ejemplo (
    ID INT PRIMARY KEY,
    Valor INT
);

INSERT INTO Ejemplo VALUES (1, 10), (2, 20), (3, 30);

EXEC sp_execute_external_script
  @language = N'R',
  @script = N'
    # Seleccionamos los datos desde la tabla
    InputDataSet <- InputDataSet;

    # Sumamos 5 a cada valor en la columna "Valor"
    InputDataSet$Valor <- InputDataSet$Valor + 5;

    # Devolvemos el resultado
    OutputDataSet <- InputDataSet;'
  ,@input_data_1 = N'SELECT * FROM Ejemplo'
  WITH RESULT SETS ((ID INT, Valor INT));
```


**Deshabilitar o Habilitar estas opciones**
```
********** DESHABILITAR EL PROCEDIMIENTO **********
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'external scripts enabled', 0;
RECONFIGURE;

********** HABILITADOR EL PROCEDIMIENTO **********
EXEC sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;
```

**links de ejecucion de R y pthon**
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-execute-external-script-transact-sql?view=sql-server-ver16
https://www.mssqltips.com/sqlservertip/4747/sql-server-spexecuteexternalscript-stored-procedure-examples/
https://blog.voogie.online/code/2020/11/04/Simple-example-of-sp_execute_external_script-using-python/


# Abrir archivos externos como csv o txt, o consultar tablas de manera remota
[Doc Oficial OPENROWSET](https://learn.microsoft.com/es-es/sql/t-sql/functions/openrowset-transact-sql?view=sql-server-ver16) <br>
[Doc Oficial OPENDATASOURCE](https://learn.microsoft.com/es-es/sql/t-sql/functions/opendatasource-transact-sql?view=sql-server-ver16)


```
**** Ejemplo #1 **** 
SELECT * FROM OPENROWSET(
   BULK 'C:\DATA\inv-2017-01-19.csv',
   SINGLE_CLOB) AS DATA;

**** Ejemplo #2 **** 
-- Para crear un formato puedes usar
bcp new_dba_test24.dbo.my_tabla_test format nul -c -x -f D:\XChange\test-csv.fmt -T

 SELECT * FROM OPENROWSET(BULK N'D:\XChange\test-csv.csv',
    FORMATFILE = N'D:\XChange\test-csv.fmt',
    FIRSTROW=2) AS cars;


**** Ejemplo #3 **** 

-- Para acceder a datos de una base de datos externa desde SQL Server,  utilizarán las credenciales de Windows del usuario que está ejecutando la consulta
SELECT a.*
FROM OPENROWSET(
    'SQLNCLI', -- Proveedor de datos específico
    'Server=Seattle1;Trusted_Connection=yes;',
    'SELECT TOP 10 GroupName, Name FROM AdventureWorks2022.HumanResources.Department'
) AS a;

**** Ejemplo #4 **** 
--- OPENDATASOURCE Es una función en SQL Server que se utiliza para acceder a datos de fuentes externas mediante la especificación explícita de la conexión a esa fuente de datos. 
SELECT *
FROM OPENDATASOURCE(
    'SQLNCLI',  -- Proveedor de datos específico (puede variar según el tipo de base de datos)
    'Data Source=ServidorExterno;User ID=Usuario;Password=Contraseña'
).NombreDeTuBaseDeDatos.dbo.NombreDeTuTabla;

**** Ejemplo #5 **** 
SELECT GroupName, Name, DepartmentID  
FROM OPENDATASOURCE('MSOLEDBSQL', 'Server=Seattle1;Database=AdventureWorks2022;TrustServerCertificate=Yes;Trusted_Connection=Yes;').HumanResources.Department  
ORDER BY GroupName, Name;  
```

**Deshabilitar o Habilitar estas opciones**
Esto se tiene que ejecutar en la base de datos que quieres deshabilitarle esta opción
```
******** Habilitar  ******** 
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

******** Deshabilitar EXECUTE AS: ********
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 0;
RECONFIGURE;
```


# Abrir JSON 
Aunque es una función útil para manipular datos JSON, si no se limita adecuadamente, podría permitir la ejecución de código no seguro o inyección de datos.
```
DECLARE @json NVARCHAR(2048) = N'{
   "String_value": "John",
   "DoublePrecisionFloatingPoint_value": 45,
   "DoublePrecisionFloatingPoint_value": 2.3456,
   "BooleanTrue_value": true,
   "BooleanFalse_value": false,
   "Null_value": null,
   "Array_value": ["a","r","r","a","y"],
   "Object_value": {"obj":"ect"}
}';
```

SELECT * FROM OpenJson(@json);

**links de para abrir json**
https://learn.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16
https://database.guide/introduction-to-openjson-with-examples-sql-server/
https://www.c-sharpcorner.com/article/using-openjson-function-in-sql-server/






# Crear codigo HTML mediante consulta
sp_makewebtask se utilizaba para generar un archivo HTML a partir de una consulta SQL. 
```sql
EXEC sp_makewebtask 
    @outputfile = 'C:\Empleados.html',
    @query = 'select * from Empleados',
    @templatefile = 'C:\template.html',
```
 
**Deshabilitar o Habilitar estas opciones**
```sql
sp_configure 'show advanced options', 1;

sp_configure 'Web Assistant Procedures', 1;
```




# pueden permitir la ejecución de código dinámico
```
EXEC sp_executesql N'SELECT * FROM  my_tabla_server where ipservidor in( @1, @2) order by ipservidor',N'@1 varchar(50),@2 varchar(50)'
,@param1,@param2

  sp_sqlexec N'SELECT @@version'
  exec ('SELECT @@version')
  EXECUTE ('SELECT @@version')

  SELECT * FROM OPENQUERY('server_name', 'SELECT @@version')
```

# Deshabilitar el usuario local
```

```

# Ingresar con el usuario Control de Acceso Diagnóstico (DAC)
La conexión de administrador dedicada (DAC) puede ayudarle a salir de una situación difícil. Esto fue creado para ayudarlo a conectarse a SQL Server y ejecutar consultas básicas en casos con problemas críticos de rendimiento, donde no permita realizar una conexión al servidor,  Esto funciona diciéndole a SQL Server que reserve un hilo específicamente para procesar sus consultas en caso de emergencia. Si bien reserva una conexión para usted, es solo un hilo, no hay ningún paralelismo aquí; de hecho, recibirá un error.
<br>
De forma predeterminada, el DAC solo escucha en la dirección IP de bucle invertido (127.0.0.1), puerto 1434. Si el puerto TCP 1434 no está disponible, se asigna dinámicamente un puerto TCP cuando se inicia el motor de base de datos. Cuando hay más de una instancia de SQL Server instalada en una computadora

```
https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/remote-admin-connections-server-configuration-option?view=sql-server-2017
https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/diagnostic-connection-for-database-administrators?view=sql-server-ver16
https://www.sqlshack.com/sql-server-dedicated-admin-connection-dac-how-to-enable-connect-and-use/

### Validar si esta activado
EXEC sp_configure 'remote admin connections' -- si la columna config_value esta en 1 esta activado si es 0 esta desactivado

 
### Consideraciones al usar DAC:
1. **Acceso limitado**: Solo los miembros del rol `sysadmin` pueden conectarse utilizando la DAC.
2. **Conexión única**: Solo se permite una conexión DAC por instancia de SQL Server. Si ya hay una conexión DAC activa, cualquier solicitud nueva será denegada.
3. **Configuración predeterminada**: Por defecto, la DAC solo permite conexiones desde el servidor local. Para habilitar conexiones remotas, debes configurar la opción `remote admin connections`.

### Configuración de la DAC para conexiones remotas:

-- Habilitar conexiones remotas para DAC
EXEC sp_configure 'remote admin connections', 1;
RECONFIGURE;


### Conexión a una instancia con un puerto diferente:
Marcara el siguiente error "cloud not establish dedicated administrator connection (DAC) on default port"
por lo que se tiene que colocar el puerto 1433 o intentar con el 1434 


 

-----

sqlcmd -A -S 127.0.0.1,1434

EXEC sp_configure 'remote admin connections', 1;
GO
RECONFIGURE;
GO
 
### Ventajas del DAC
1. **Acceso en Situaciones Críticas**: Permite a los administradores conectarse y ejecutar consultas de diagnóstico cuando el servidor está bajo una carga extrema o no responde a conexiones normales.
2. **Resolución de Problemas**: Facilita la identificación y terminación de consultas de larga duración que pueden estar causando problemas de rendimiento.
3. **Seguridad**: La conexión DAC admite cifrado y otras características de seguridad de SQL Server.

### Requisitos para Conectarse
1. **Permisos**: Solo los miembros del rol `sysadmin` pueden conectarse utilizando la DAC.
2. **Configuración**: Por defecto, la conexión solo está permitida desde un cliente que se ejecute en el servidor. Para permitir conexiones remotas, se debe configurar mediante el procedimiento almacenado `sp_configure` con la opción `remote admin connections`.
3. **Herramientas**: La DAC está disponible a través de la utilidad de línea de comandos `sqlcmd` usando el modificador especial `-A`, o prefijando `admin:` al nombre de la instancia en SQL Server Management Studio (SSMS).

### Cómo Conectarse
1. **Desde SSMS**:
   - Desconecta todas las conexiones a la instancia de SQL Server.
   - Selecciona `Archivo > Nuevo > Consulta de motor de base de datos`.
   - En el cuadro de diálogo de conexión, escribe `admin:localhost,PUERTO` para la instancia predeterminada o `admin:localhost\NOMBRE_INSTANCIA,PUERTO` para una instancia con nombre.

2. **Desde `sqlcmd`**:
   ```plaintext
   sqlcmd -S admin:<instance_name> -A

En este comando, `-A` indica que estás utilizando la DAC, `localhost` es el nombre del servidor y `PUERTO` es el número de puerto específico de tu instancia.
   ```

### Limitaciones o Desventajas
1. **Conexión Única**: Solo se permite una conexión DAC por cada instancia de SQL Server.
2. **Recursos Limitados**: SQL Server Express no escucha en el puerto DAC a menos que se inicie con una marca de seguimiento 7806.
3. **Uso Restricto**: La DAC está diseñada únicamente para diagnóstico y resolución de problemas, no para operaciones regulares.

 

```

# Instancias 
permite que los usuarios que no son administradores creen instancias de base de datos en su propio proceso de SQL Server <br> 
Seguridad: Es importante tener en cuenta que habilitar la creación de instancias de usuario puede presentar riesgos de seguridad, ya que los usuarios pueden crear y acceder a bases de datos sin el conocimiento o la supervisión del administrador del sistema.
Se recomienda utilizar las instancias de usuario de manera cuidadosa y solo en entornos donde sea necesario para el desarrollo y la prueba de aplicaciones. 

```SQL
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'user instances enabled', 1
```



# Recuperar el acceso a sql server
Para esto entramos en **sql server mode single user mode** en este modo nadie se puede conectar mas que un usuario administrador a nivel windows server  
para esto puedes desde ingresar al **SQL server configuration manager** después ingresar a SQL server services > SQL server (MSSQLSERVER) -> click derecho -> propiedades -> Startup Parameters  -> Agregamos el parametro  **-m** -> add -> OK 

o puedes realizar esto desde el cmd 
 ```SQL
Consideraciones: Se debe usar el puerto 1433 que es el por defaul no funciona si la instanccia tiene otro puerto 

NOTA: si es por instancia se coloca MSSQL$NOMBREINSTANCIA

net start MSSQL$mssqlserver
net start MSSQL$mssqlserver \m 

sqlcmd -S 127.0.0.1

create login [myuser_test] with password = '12345.aA'
go
alter server role [sysadmin] add member [myuser_test]
go



```


### Desactivar CLR   Common Language Runtime 
Estaba destinado a ser tanto una mejora como un reemplazo futuro de los procedimientos almacenados extendidos, que son un tipo especial de procedimiento almacenado escrito en lenguaje C y compilado en código de máquina como una biblioteca dll.



 ## Ver los proc ensamblados con clr 
```SQL 
  SELECT 
    name AS NombreEnsamblado,
    assembly_id AS IDEnsamblado,
    permission_set_desc AS ConjuntoDePermisos,
    create_date AS FechaCreacion,
    modify_date AS FechaModificacion
FROM 
    sys.assemblies
-- WHERE    name LIKE '%.dll'; -- Filtra por archivos DLL, típicos de ensamblados CLR
```
	 

## Habilitar el parámetro 
```SQL 
---- Desactivar  
EXEC sp_configure 'clr enabled';  
EXEC sp_configure 'clr enabled' , '0';  
RECONFIGURE;    
```
**Opción SAFE_ACCESS**
Características Principales:
- Permisos Limitados: Los ensamblados con SAFE_ACCESS no pueden acceder a recursos externos, como archivos del sistema o bases de datos externas.
- Seguridad: Proporciona un nivel alto de seguridad, ya que los ensamblados no pueden realizar operaciones que podrían comprometer la integridad del sistema.
- Recomendado: Es la configuración recomendada para ensamblados que no necesitan interactuar con recursos externos

```SQL 
CREATE ASSEMBLY MiEnsamblado
FROM 'ruta_al_archivo.dll'
WITH PERMISSION_SET = SAFE;    --- SAFE, EXTERNAL_ACCESS, UNSAFE
```

https://www.mssqltips.com/sqlservertip/6104/how-to-enable-sql-server-clr-integration-using-tsql/



# Agregar e un archivo dll
permite agregar procedimientos almacenados extendidos a SQL Server. Estos procedimientos almacenados pueden ser archivos DLL que se registran en SQL Server y se pueden ejecutar desde consultas SQL.
```sql
--- Guardar el binario en la ruta :
C:\ProgramFiles\Microsoft SQL server\MSSQL15.MSSQLSERVER\MSQL\Binn

EXEC sp_configure 'clr enabled';  
EXEC sp_configure 'clr enabled' , '1';  
RECONFIGURE;    

--Register the function (xp_hello)  
sp_addextendedproc 'xp_hello', 'c:\xp_hello.dll';

--- darle permisos de ejecucion en el procedimiento 
grant execute on xp_hello to [User_test];

--- elimina la extencion
sp_dropextendedproc 'xp_hello', 'c:\xp_hello.dll';
  
--The following will succeed in calling xp_hello  
DECLARE @txt varchar(33);  
EXEC xp_Hello @txt OUTPUT;  
```

**Deshabilitar o Habilitar estas opciones**
```
REVOKE EXECUTE ON sp_addextendedproc FROM [NombreUsuario];
```
**link de ejemplo para agregar  procedimientos almecenados **
https://github.com/MicrosoftDocs/sql-docs/blob/live/docs/relational-databases/extended-stored-procedures-programming/adding-an-extended-stored-procedure-to-sql-server.md


 

#  OLE Automation - Ejecucion de bibliotecas de objetos de windows
**la creación de objetos de automatización OLE debe estar prohibida** sugiere una medida de seguridad importante en SQL Server. OLE Automation permite a SQL Server interactuar con objetos COM (Component Object Model) fuera del motor de base de datos, lo cual puede abrir puertas a varios riesgos de seguridad.
 
**Razones para Prohibir la Creación de Objetos OLE:**
	- Seguridad: Permitir OLE Automation puede exponer el servidor a ataques, ya que se puede ejecutar código arbitrario.
	- Estabilidad: Puede afectar la estabilidad del servidor si el objeto COM invocado tiene errores o se comporta de manera inesperada.
 
**Ejemplo de uso**
```SQL
**sp_OACreate, sp_OAMethod, sp_OAGetProperty:** Estos procedimientos almacenados están asociados con la ejecución de objetos COM externos desde SQL Server
 y pueden ser utilizados para realizar acciones peligrosas si no se controlan adecuadamente.
--- Creara el archivo Archivo.txt y escribira en el archivo 

DECLARE @FileSystemObject INT;
DECLARE @FileHandler INT;
DECLARE @FilePath NVARCHAR(255) = 'C:\Ruta\Del\Archivo.txt';
DECLARE @FileContent NVARCHAR(MAX) = 'Contenido del archivo';

-- Crear una instancia del objeto Scripting.FileSystemObject
/*
 muchas utilidades disponibles en el entorno de scripting de Windows. Es una biblioteca de objetos utilizada para interactuar con el sistema de archivos desde scripts y aplicaciones en Windows
*/
EXEC sp_OACreate 'Scripting.FileSystemObject', @FileSystemObject OUTPUT;

-- Crear un archivo usando el objeto FileSystemObject
EXEC sp_OAMethod @FileSystemObject, 'CreateTextFile', @FileHandler OUTPUT, @FilePath, 2, TRUE;

-- Escribir contenido en el archivo
EXEC sp_OAMethod @FileHandler, 'Write', NULL, @FileContent;

-- Cerrar el archivo
EXEC sp_OAMethod @FileHandler, 'Close';

-- Liberar la instancia del objeto FileSystemObject
EXEC sp_OADestroy @FileSystemObject;
```


**Deshabilitar o Habilitar estas opciones**
```
********** VER SI ESTAN HABILITADOS **********
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures'; --- si la columna config_value y run_value estan en 0 estan desabilitados, si es 1 esta habilitado


********** HABILITADOR EL PROCEDIMIENTO **********
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;


********** DESHABILITAR EL PROCEDIMIENTO **********
EXEC sp_configure 'Ole Automation Procedures', 0;
RECONFIGURE;
```





# cross db ownership chaining 
Habilitar esta característica puede exponer riesgos de seguridad si no se maneja adecuadamente. es una configuración de seguridad en SQL Server que permite que las bases de datos se confíen mutuamente en términos de permisos de objetos. Cuando está habilitado, un objeto en una base de datos puede acceder a objetos en otra base de datos si existe una cadena de propiedad entre ellas

**Habilitar estas opciones**
```SQL
https://www.mssqltips.com/sqlservertip/1782/understanding-cross-database-ownership-chaining-in-sql-server/

# Objetivo : En el ejemplo de Cross-Database Ownership Chaining (CDOC), configuramos las bases de datos DB1 y DB2 de manera que un procedimiento almacenado y  una vusta  en DB1 puede acceder a una tabla en DB2 


--- Crear dbs de pruebas 
CREATE DATABASE DB1;
CREATE DATABASE DB2;



--- Activar el Cross db a nivel DB 
--- [Nota] para que funcione las 2 tienen que estar activadas el DB_CHAINING o lo activan a nivel instancia 
ALTER DATABASE DB1 SET DB_CHAINING ON;
ALTER DATABASE DB2 SET DB_CHAINING ON;


-- validar que se cambio la configuracion a nivel DB 
SELECT name, is_db_chaining_on FROM sys.databases where is_db_chaining_on =1 ;


--- Activar el cross db a nivel instancia
sp_configure 'cross db ownership chaining', 1;
RECONFIGURE;


-- validar que se cambio la configuracion a nivel instancia 
select name,value_in_use from sys.configurations where name =  'cross db ownership chaining'




-- Crear el login 
USE [master]
GO
CREATE LOGIN [user_cross] WITH PASSWORD=N'123123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
 
 
-- Crear el usauri en la DB1
USE [DB1]
GO
CREATE USER [user_cross] FOR LOGIN [user_cross]

 
-- Crear el usauri en la DB2 
USE [DB2]
GO
CREATE USER [user_cross] FOR LOGIN [user_cross]
 






USE DB2;
GO

--- Crear tabla 
CREATE TABLE TableDB2 (
    ID INT PRIMARY KEY,
    Description NVARCHAR(50)
);


-- Insertamos algunos datos en TableDB2
INSERT INTO TableDB2 (ID, Description) VALUES (1, 'Description1');
INSERT INTO TableDB2 (ID, Description) VALUES (2, 'Description2');


--- corroborar datos 
select * from TableDB2 ; 



USE DB1;

--- Crear Procedimiento 
CREATE PROCEDURE GetDataFromDB2
AS
BEGIN
    SELECT * FROM DB2.dbo.TableDB2;
END;


--- Crear vista 
CREATE VIEW ViewDB1 AS SELECT * FROM DB2.dbo.TableDB2;



---- Darle permisos al usuario user_cross para que pueda usar la vista y el Proc
grant execute on dbo.GetDataFromDB2 to user_cross
GRANT SELECT ON dbo.ViewDB1 TO user_cross;


 


 ############ TEST ############
 
 --- [Nota]: se conectan con el usuario user_cross 
 

use db2;
select * from TableDB2 ;  --> Msg 229, Level 14, State 5, Line 3  The SELECT permission was denied on the object 'TableDB2', database 'DB2', schema 'dbo'.

 

USE DB1;
EXEC GetDataFromDB2; --- retorna los datos exitosamente 
select * from ViewDB1; --- retorna los datos exitosamente  


-- Se conectan con el usuario syadmin y Elimin el usuario de la db2 para validar si le permite 
use db2 
DROP USER [user_cross]

-- se conectan co el usuario user_cross 
select * from ViewDB1; -->  Msg 916, Level 14, State 2, Line 11 The server principal "user_cross" is not able to access the database "DB2" under the current security context.


############ Eliminar todo el test ############

############ Eliminar todo el test ############
 
drop database db1;
drop database db2;


sp_who user_cross  
kill PID
DROP LOGIN [user_cross];




```

**Deshabilitar estas opciones**
¿Por qué Deshabilitarlo? 
Deshabilitar esta configuración puede mejorar la seguridad, ya que evita que objetos en diferentes bases de datos accedan entre sí sin una relación de propiedad clara2. Esto puede prevenir ciertos tipos de ataques o accesos no autorizados. pero también puede afectar la funcionalidad de algunas aplicaciones que dependen de esta característica

```SQL
EXEC sp_configure 'show advanced options', 1;
sp_configure 'cross db ownership chaining', 0;
RECONFIGURE;

ALTER DATABASE DB1 SET DB_CHAINING OFF;
ALTER DATABASE DB2 SET DB_CHAINING OFF;

```



# Consulta de parametros de seguridad 
```
SELECT *
FROM sys.configurations
WHERE name in( 
'c2 audit mode'
,'Ad Hoc Distributed Queries'
,'clr enabled'
,'cross db ownership chaining'
,'Database Mail XPs'
,'Ole Automation Procedures'
,'remote access'
,'remote admin connections'
,'scan for startup procs'
, 'default trace enabled'
) order by name 



--------

Habilitar la función de “protección ampliada” para fortalecer la seguridad en la capa de red.

----
Los Grupos “BUILTIN” y locales de windows no deben usarse para  inicio de sesión de SQL Server, es necesario crear grupos  alternativos en AD para el inicio de sesión en SQL Server.
 

--------



Los permisos al rol “public” deben ser basados en el principio del mínimo privilegio y no deben tener acceso al proxy de SQL Server (“SQL Agent proxies”), es importante crear cuentas alternativas en AD adecuadas para ejecutar las funciones.



 select  user_name(grantee_principal_id),user_name(grantor_principal_id),* from sys.database_permissions  

 
```




## Cerrado automatico a DB AUTO_CLOSE 
Cierra automáticamente cuando el último usuario se desconecta. Cuando se habilita AUTO_CLOSE, la base de datos se cierra y se liberan todos sus recursos, lo que puede ahorrar memoria y otros recursos del servidor. Sin embargo, esto también puede tener un impacto significativo en el rendimiento
 
 **Recomendaciones** 
 -	Usarlo en entornos de desarrollo o servidores donde la base de datos se utiliza duranto un gran periodo de tiempo
 -	No usarlo en produccion o en servidores donde las bases de datos se usan muy fecuentemente ya que  requieren un acceso rápido y eficiente y puede tener un impacto negativo significativo en el rendimiento 

```SQL

-- Validar las DB que tienen activado esta opcion 
SELECT name, is_auto_close_on FROM sys.databases  where  is_auto_close_on = 1 ;


--- Desactivar el auto cerrado 
ALTER DATABASE test_db SET AUTO_CLOSE OFF;

--- Activar el auto cerrado 
ALTER DATABASE test_db SET AUTO_CLOSE OFF;



```


### hide instance 
"ocultar" una instancia para que no aparezca en la lista de servidores disponibles cuando los clientes utilizan la opción de "Explorar servidores" en aplicaciones como SQL Server Management Studio (SSMS).
```
Ve a la pestaña "Sql Server Network Configuration" > "Protocols for MSSQLSERVER*" > click derecho  propiedad >  HideInstance a Yes
```

### Force Encryption
Ofrece seguridad contra ciertos tipos de ataques de retransmisión de autenticación, Cuando te conectas al motor de base de datos con protección ampliada, se utilizan técnicas adicionales para asegurar que las credenciales de autenticación no puedan ser interceptadas y reutilizadas por un atacante.
```
Ve a la pestaña "Sql Server Network Configuration" > "Protocols for MSSQLSERVER*" > click derecho  propiedad >  Force Encryption a Yes
```



# Recomendaciones de autenticación 

```
Después del alta de la cuenta o después de resetear la contraseña, se debe exigir al usuario actualizar su contraseña después del inicio de sesión (este punto no aplica para usuarios aplicativos), cumpliendo con el “Estándar para la Gestión de Contraseñas”.
La autenticación de SQL Server debe heredar la política de contraseñas establecida en el sistema operativo windows.
La autenticación de SQL debe validar la expiración de contraseñas tomando en cuenta la política de contraseñas establecidas en el sistema operativo windows.
```

# Denys que se pudieran considerar realizar 

```

DENY SELECT ON sys.tables TO usuario_soporte;
DENY SELECT ON sys.views TO usuario_soporte;
DENY SELECT ON sys.procedures TO usuario_soporte;
DENY SELECT ON sys.columns TO usuario_soporte;
DENY SELECT ON sys.sql_logins TO usuario_soporte;
DENY EXECUTE ON sp_configure TO usuario_soporte;
DENY EXECUTE ON sp_addlogin TO usuario_soporte;
DENY EXECUTE ON sp_droplogin TO usuario_soporte;
DENY EXECUTE ON sp_addsrvrolemember TO usuario_soporte;
DENY EXECUTE ON sp_dropsrvrolemember TO usuario_soporte;
DENY EXECUTE ON fn_helpcollations TO usuario_soporte;
DENY EXECUTE ON fn_dblog TO usuario_soporte;
DENY SELECT ON sys.database_permissions TO rol_restringido;
DENY SELECT ON sys.server_principals TO rol_restringido;
DENY SELECT ON sys.server_role_members TO rol_restringido;
DENY EXECUTE ON sp_addrolemember TO rol_restringido;
DENY EXECUTE ON sp_droprolemember TO rol_restringido;
DENY EXECUTE ON sp_changedbowner TO rol_restringido;
DENY EXECUTE ON fn_trace_getinfo TO rol_restringido;
DENY EXECUTE ON fn_virtualfilestats TO rol_restringido;
DENY SELECT ON sys.dm_exec_sessions TO rol_restringido;
DENY SELECT ON sys.dm_exec_requests TO rol_restringido;
DENY SELECT ON sys.dm_exec_query_stats TO rol_restringido;
DENY SELECT ON sys.dm_os_performance_counters TO rol_restringido;
DENY SELECT ON sys.dm_db_index_physical_stats TO rol_restringido;
DENY EXECUTE ON sp_who TO rol_restringido;
DENY EXECUTE ON sp_who2 TO rol_restringido;
DENY EXECUTE ON sp_lock TO rol_restringido;
DENY EXECUTE ON sp_msforeachdb TO rol_restringido;
DENY EXECUTE ON sp_msforeach_worker TO rol_restringido;
DENY EXECUTE ON fn_virtualservernodes TO rol_restringido;




```

---

### 🔐 ¿Qué es Always Encrypted?

Es una tecnología que **cifra datos sensibles en columnas específicas** de una tabla, de modo que **ni el motor de SQL Server ni los administradores de base de datos pueden ver los datos en texto claro**. Solo las aplicaciones cliente que tienen acceso a las claves pueden descifrar los datos.

### 🧰 Requisitos

- SQL Server 2016 o superior.
- .NET Framework 4.6 o superior.
- ADO.NET con soporte para Always Encrypted.
- Configuración de claves en el cliente.

### 🎯 ¿Para qué sirve?

- **Proteger datos confidenciales** en tránsito, en reposo y en uso.
- Cumplir con normativas como GDPR, HIPAA, PCI-DSS.
- Evitar que personal con acceso al servidor (DBAs, soporte, etc.) vea datos sensibles.
- Asegurar que el cifrado y descifrado se haga **solo en el cliente**, no en el servidor.



### 🧠 ¿Cómo funciona?

1. **Columnas cifradas**: Se eligen columnas específicas para cifrar (por ejemplo, `tarjeta_credito`, `curp`, `rfc`).
2. **Claves de cifrado**:
   - **Column Master Key (CMK)**: Protege la clave de columna. Se guarda en el cliente o en un almacén seguro (como Windows Certificate Store o Azure Key Vault).
   - **Column Encryption Key (CEK)**: Cifra los datos. Se guarda en SQL Server pero cifrada con la CMK.
3. **Cifrado en el cliente**: El cliente (por ejemplo, una app en C# con ADO.NET) cifra los datos antes de enviarlos al servidor y los descifra al recibirlos.


### 🧪 Tipos de cifrado

| Tipo de cifrado | Características | Uso común |
|------------------|------------------|------------|
| **Deterministic** | Siempre produce el mismo valor cifrado para el mismo valor original. Permite búsquedas y joins. | Buscar por CURP, RFC, etc. |
| **Randomized** | Produce valores cifrados diferentes cada vez. Más seguro pero no permite búsquedas. | Contraseñas, tokens, etc. |


---

# Bibliografías 
```
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-1-untrustworthy-databases/
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-2-user-impersonation/
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-3-sqli-and-user-impersonation/
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-procedures-part-4-enumerating-domain-accounts/

https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server 

https://www.madeiradata.com/post/how-to-protect-sql-server-from-hackers-and-penetration-tests

https://pentera.io/blog/how-to-find-the-mssql-databases-version-with-the-tds-protocol/

https://addendanalytics.com/blog/accessing-excel-files-using-openrowset-and-opendatasource-in-sql-server/#:~:text=%60OPENROWSET%60%20is%20an%20SQL%20Server,file%20directly%20into%20SQL%20Server.

https://github.com/Ignitetechnologies/MSSQL-Pentest-Cheatsheet

medidas de seguridad: 
https://learn.microsoft.com/es-es/sql/relational-databases/security/security-center-for-sql-server-database-engine-and-azure-sql-database?view=sql-server-ver16
https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver16
```





### CONFIGURACIONES DE SEGURIDAD
```SQL

trucos de pentesting en postgresql -> https://hackviser.com/tactics/pentesting/services/mssql

--- Tecnicas de seguridad:
https://jotelulu.com/blog/como-mejorar-la-seguridad-de-tu-sql-server/

Seguridad: 
https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver16

 https://reunir.unir.net/bitstream/handle/123456789/3619/ARMENDARIZ%20PEREZ%2C%20I%C3%91IGO.pdf?sequence=1&isAllowed=y
 https://www.coursesidekick.com/computer-science/4425647
 http://bibliotecadigital.econ.uba.ar/download/tpos/1502-0496_TiebasJ.pdf
 https://www.udb.edu.sv/udb_files/recursos_guias/informatica-ingenieria/base-de-datos-i/2019/i/guia-12.pdf
 https://www.sothis.tech/seguridad-en-microsoft-sql-server/


----------- ecnriptado ------------
cifrar los datos en reposo 
Cifrado de datos transparente (TDE)  - https://learn.microsoft.com/es-es/sql/relational-databases/security/encryption/transparent-data-encryption?view=sql-server-ver16#enable-tde

----------- NIVEL COLUMNA ------------
 Enmascaramiento dinámico de datos (DDM) 

------------ Protección en el nivel de fila ------------
Seguridad de nivel de fila (RLS)  -  https://learn.microsoft.com/es-es/sql/relational-databases/security/row-level-security?view=sql-server-ver16#Typical

------------ AUDITORIAS ------------
Informes y auditoría
https://learn.microsoft.com/es-es/sql/relational-databases/security/auditing/sql-server-audit-database-engine?view=sql-server-ver16

------------ Identidades y autenticación ------------
el modo de autenticación de Windows y el "modo de autenticación de SQL Server y Windows" (modo mixto).

------------ tablas temporales historicas ------------
 registros históricos de los cambios de datos a lo largo del tiempo puede ser beneficioso para abordar los cambios accidentales en los datos.
https://learn.microsoft.com/es-es/sql/relational-databases/tables/temporal-tables?view=sql-server-ver16

------------ Evaluación y herramientas de evaluación de seguridad ------------
Evaluación de vulnerabilidades de SQL Server 
habilite solo las características que necesita : https://learn.microsoft.com/es-es/sql/relational-databases/security/surface-area-configuration?view=sql-server-ver16

Clasificacion de datos sensibles : https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-data-discovery-and-classification?view=sql-server-ver16&tabs=t-sql

------------ Amenazas de SQL comunes ------------
Inyección de código SQL:   https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-injection?view=sql-server-ver16
Inyección de código SQL:  Los desarrolladores y administradores de seguridad deben revisar todo el código que llama a EXECUTE, EXEC o sp_executesql, xp_: Procedimientos almacenados extendidos del catálogo, como xp_cmdshell 
Acceso por fuerza bruta: https://learn.microsoft.com/es-es/defender-for-identity/credential-access-alerts
Riesgos de contraseña :  contraseñas seguras complejas para todas sus cuentas.
Proteger SQL Server: https://learn.microsoft.com/es-es/sql/relational-databases/security/securing-sql-server?view=sql-server-ver16



```







