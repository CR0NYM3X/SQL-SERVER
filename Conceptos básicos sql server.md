
### Diferencia de DDL Y DML 
**Lenguaje de Definición de Datos (DDL):**

`Propósito:` El DDL se utiliza para definir la estructura y las características de la base de datos. <br>
`Operaciones típicas:` Crear, modificar y eliminar objetos de la base de datos, como tablas, índices, vistas, esquemas, etc. <br>
`Ejemplos de sentencias DDL:` CREATE TABLE, ALTER TABLE, DROP TABLE, CREATE INDEX, CREATE VIEW, etc. <br>
`Efecto en los datos:` Las sentencias DDL no afectan directamente a los datos almacenados en la base de datos, sino a la estructura y definición de cómo se almacenan y organizan esos datos.


**Lenguaje de Manipulación de Datos (DML):** <br>
`Propósito:` El DML se utiliza para manipular y trabajar con los datos almacenados en la base de datos. <br>
`Operaciones típicas:` Insertar, recuperar, actualizar y eliminar datos dentro de las tablas de la base de datos. <br>
`Ejemplos de sentencias DML:` SELECT, INSERT, UPDATE, DELETE, etc. <br>
`Efecto en los datos:` Las sentencias DML sí afectan directamente a los datos almacenados en la base de datos, cambiando su contenido, añadiendo nuevos datos o eliminando datos existentes.

**Lenguaje de Control de Datos (DCL)**
Estos comandos permiten al Administrador del sistema gestor de base de datos, controlar el acceso a los objetos<br>
GRANT, permite otorgar permisos.<br>
REVOKE, elimina los permisos que previamente se han concedido.



### Ver configuraciónes del servidor
```
SELECT* FROM sys.configurations WHERE configuration_id = 1568 

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
```

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

******** EJEMPLO #1 ********
runas /user:DOMINIO\omar.lopez "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"

******** EJEMPLO #2 ********
runas /user:DOMINIO\omar.lopez "C:\Windows\System32\cmd.exe"


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

**`msdb:`** La base de datos "msdb" almacena información sobre la programación de tareas, mantenimiento, respaldos, jobs y otras tareas administrativas.<br>

**`tempdb:`** La base de datos "tempdb" es una base de datos temporal que se utiliza para almacenar datos temporales y variables de sesión, así como para ayudar en la clasificación y unión de datos.



##  cuenta de servicio 
La cuenta de servicio que configuras al instalar SQL Server es crucial para la seguridad y el rendimiento. Aquí están algunas razones por las que no se recomienda dejar la cuenta predeterminada:

**Seguridad:** <br>
La cuenta predeterminada suele ser NT SERVICE\MSSQLSERVER, que tiene privilegios elevados (como miembro del rol sysadmin).   
Usar una cuenta personalizada permite restringir permisos y limitar el acceso a recursos específicos.  <br>
**Principio de menor privilegio:**  <br>
Siempre ejecuta los servicios de SQL Server con los privilegios más bajos posibles.  
Utiliza cuentas de dominio (como gMSA o MSA) si tu servidor está en un dominio.   
Si no está en un dominio, considera usar cuentas virtuales.  <br>
**Personalización:**  <br>
Configurar una cuenta personalizada te permite ajustar permisos según tus necesidades.   
Puedes otorgar acceso a compartir archivos o otros servidores de bases de datos de manera más controlada.  <br>


```
gMSA (Cuenta de Servicio Administrada de Grupo):
Funcionalidad: Ofrece la misma funcionalidad que las sMSA, pero se extiende a varios servidores dentro del dominio.
Uso: Permite que todas las instancias de un servicio en una granja de servidores utilicen la misma entidad de servicio, lo que permite que los protocolos de autenticación mutua funcionen1.
Administración de Contraseñas: El sistema operativo de Windows administra la contraseña de la cuenta en lugar de requerir intervención manual del administrador.
Aplicaciones Prácticas: Ideal para servicios que se ejecutan en múltiples servidores sin necesidad de sincronizar contraseñas entre instancias de servicio.
sMSA (Cuenta de Servicio Administrado Independiente):
Funcionalidad: Introducida en Windows Server 2008 R2 y Windows 7, proporciona administración automática de contraseñas y SPN.
Uso: Diseñada para una sola instancia de servicio en un servidor.
Administración de Contraseñas: Similar a la gMSA, pero no se extiende a varios servidores1.
```
