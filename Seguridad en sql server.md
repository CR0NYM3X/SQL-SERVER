
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

---- Para ver el último usuario que ha iniciado sesión en el sistema, puedes ir 
 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI', 'LastLoggedOnUser'  usuario
 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI', 'LastLoggedOnDisplayName' --- saber el nombre completo

--- usuarios registrados en el servidor
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\    ProfileImagePath



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



# Ejecucion de bibliotecas de objetos de windows 
**sp_OACreate, sp_OAMethod, sp_OAGetProperty:** Estos procedimientos almacenados están asociados con la ejecución de objetos COM externos desde SQL Server y pueden ser utilizados para realizar acciones peligrosas si no se controlan adecuadamente.
```
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


# Ejecuta una query asiendote pasar por un usuario 
Estamos ejecutando una query como si estuvieramos conectados con este usuario
```
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



# Agregar procedimientos almecenados desde un archivo dll
permite agregar procedimientos almacenados extendidos a SQL Server. Estos procedimientos almacenados pueden ser archivos DLL que se registran en SQL Server y se pueden ejecutar desde consultas SQL.
```
--Register the function (xp_hello)  
sp_addextendedproc 'xp_hello', 'c:\xp_hello.dll';  
  
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

# Ingresar con el usuario DAC
```
https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/diagnostic-connection-for-database-administrators?view=sql-server-ver16
https://www.sqlshack.com/sql-server-dedicated-admin-connection-dac-how-to-enable-connect-and-use/


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

# Bibliografías 
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-1-untrustworthy-databases/
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-2-user-impersonation/
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-3-sqli-and-user-impersonation/
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-procedures-part-4-enumerating-domain-accounts/

https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server 

https://www.madeiradata.com/post/how-to-protect-sql-server-from-hackers-and-penetration-tests

https://pentera.io/blog/how-to-find-the-mssql-databases-version-with-the-tds-protocol/

https://addendanalytics.com/blog/accessing-excel-files-using-openrowset-and-opendatasource-in-sql-server/#:~:text=%60OPENROWSET%60%20is%20an%20SQL%20Server,file%20directly%20into%20SQL%20Server.

https://github.com/Ignitetechnologies/MSSQL-Pentest-Cheatsheet





