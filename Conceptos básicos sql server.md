

### Estructura 
```
msdb.dbo.backupmediafamily

[Base de datos].[esquema].[tabla]
```

### comandos básicos
```
use mydba_test -- sirve para que use una base de datos

go  ---  le indicas que está completo y que la interfaz de SQL Server debe ejecutar ese comando antes de continuar con cualquier otro comando siguiente
```


### Conectarse a sql server desde CMD
[Link descargar SQLCMD](https://learn.microsoft.com/es-es/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16&tabs=odbc%2Cwindows&pivots=cs1-bash) <br> 

Puedes usar la herramienta de SQLCMD.exe o OSQL.exe

```
# Directorio donde se encuentra la herramienta:
C:\Program Files\Microsoft SQL Server\150\Tools\Binn

//// Ejemplos #1
OSQL.EXE -E -S My_hostnameServ -d Mydba -Q "SELECT name FROM sys.databases" 

//// Ejemplos #2
OSQL.EXE -S My_hostnameServ -d Mydba -U Usuario_test -i script.sql -o "C:\Users\alex\Desktop\log_script.txt"

*** Info parámetro ***
-E Este le indicas que utilice el windows autentication, con esta opcion no colocas ningun usuario o contraseña
-S Colocas el hostname del servidor
-d colocas el nombre de la base de datos a la que te conectas 
-Q sirve para ejecutar querys
-i Sirve para ejecutar scripts que tengan querys denstro del script
-U Indicas el usuario con el que te vas a conectas 
-o se guarda en un archivo como lgo toda la salida que se va ejecutar
```

Tambien puede conectarse de esta forma desde el cmd 
```

******** EJEMPLO ********
runas /user:DOMINIO\Usuario "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"

-- Tambien puede ser una ruta como: "C:\Program Files (x86)\Microsoft SQL Server\150\Tools\Binn\ManagementStudio\Ssms.exe"

runas: se utiliza en Windows para ejecutar programas con diferentes credenciales de usuario que las actuales.
 Sin embargo, runas no se usa directamente para conectarte a un servidor SQL Server de manera remota,
pero puedes utilizarlo para ejecutar aplicaciones como SQL Server Management Studio (SSMS) con diferentes credenciales.

/netonly: Indica que se realizará la autenticación de red remota,
lo que significa que se usarán las credenciales proporcionadas solo para recursos de red
 y no para los recursos locales.

/user:MYDOMINIO\user1: Especifica el nombre del dominio y el usuario con el que se ejecutará la aplicación.
 En este caso, MYDOMINIO es el nombre del dominio y user1 es el nombre de usuario.

"C:\Program Files\Microsoft SQL Server\110\Tools\binn\VSShell\Common7\IDE\Ssms.exe": Es la ubicación de la aplicación
SQL Server Management Studio (SSMS) en el sistema de archivos de Windows.
```

### Puertos por dafault que usa el sql server
    puerto: 1433, 1434, 4022, 135, de tipo TCP y el 1434 UDP.


### Bases de Datos del Sistema en SQL Server:
En SQL Server, las bases de datos del sistema son bases de datos que se utilizan para administrar y controlar el propio sistema de gestión de bases de datos. Algunas de las bases de datos del sistema más importantes en SQL Server son:<br>

**`master:`** La base de datos "master" almacena información crítica sobre la configuración del servidor, inicios de sesión, seguridad y otros aspectos fundamentales. Esta base de datos es esencial para el funcionamiento del servidor y no se puede desactivar.<br>

**`model:`** La base de datos "model" se utiliza como plantilla para crear nuevas bases de datos. Cualquier cambio que realices en "model" se aplicará a las bases de datos recién creadas.<br>

**`msdb:`** La base de datos "msdb" almacena información sobre la programación de tareas, mantenimiento, copias de seguridad y otras tareas administrativas.<br>

**`tempdb:`** La base de datos "tempdb" es una base de datos temporal que se utiliza para almacenar datos temporales y variables de sesión, así como para ayudar en la clasificación y unión de datos.


