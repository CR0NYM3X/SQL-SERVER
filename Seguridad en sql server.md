
# Ejecutar comandos en windows desde sql server 
```
exec master..xp_cmdshell 'dir' -- ejecuta comandos 
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

# Cambiar las configuraciones del sql server 
```
********** ver las configuraciones que hay actualmente **********
EXEC sp_configure;

********** cambiar una configuracion **********
sp_configure 'show advanced options', 1; --- cambia la configuración de sql server 
```

# Lectura y modificacion del registro de windows 
**xp_regread, xp_regwrite:** Estas funciones permiten leer y escribir en el registro /regedit del sistema. Si se usan sin restricciones, podrían abrir la puerta a cambios no autorizados en la configuración del servidor.
```
--- leer registros como la version de windows | con este ejemplo vamos a ver la version del sistema operativo 
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

--- escribir  registros
EXEC xp_regwrite 'HKEY_CURRENT_USER', 'Software\MyApp', 'Version', 'REG_SZ', '1.0';
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


# Ejecucion querys suplatando el usuario 
Estamos ejecutando una query como si estuvieramos conectados con este usuario
```
EXECUTE AS USER = 'MYDOMINIO\USER_ADMINS123';

	SELECT SUSER_SNAME(),DB_NAME(),entity_name,permission_name FROM fn_my_permissions(NULL, 'DATABASE') 

REVERT;
```

**Deshabilitar o Habilitar estas opciones**
Esto se tiene que ejecutar en la base de datos que quieres deshabilitarle esta opción
```
******** Habilitar EXECUTE AS: ******** 
ALTER DATABASE [new_dba_test24] SET TRUSTWORTHY ON;

******** Deshabilitar EXECUTE AS: ********
ALTER DATABASE [new_dba_test24] SET TRUSTWORTHY OFF;
```




# Bibliografías 
https://www.netspi.com/blog/technical/network-penetration-testing/hacking-sql-server-stored-procedures-part-1-untrustworthy-databases/

https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server 

https://www.madeiradata.com/post/how-to-protect-sql-server-from-hackers-and-penetration-tests

https://pentera.io/blog/how-to-find-the-mssql-databases-version-with-the-tds-protocol/




