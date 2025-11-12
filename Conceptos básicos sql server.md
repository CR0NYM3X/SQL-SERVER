
## Conexion string 
```
Server=192.28.230.122;Application Name=TEST_APLICATION;Database=master;User Id=sys_usert;Password=A138AFB73ECD5B64F6;Encrypt=True;TrustServerCertificate=True;

*** Referencias ***
https://www.mssqltips.com/sqlservertip/7220/sql-server-connection-strings-reference-guide/
https://www.connectionstrings.com/sql-server/
https://www.connectionstrings.com/all-sql-server-connection-string-keywords/
```

## Accesos directos
```
--- SQL Server Configuration Manager 
C:\Windows\SysWOW64\mmc.exe /32 C:\Windows\SysWOW64\SQLServerManager15.msc

--- SQL Server Profiler 
C:\Program Files (x86)\Microsoft SQL Server\<versión>\Tools\Binn\profiler.exe
```
---

### 🧠 ¿Por qué aparecen en `sys.database_permissions`?

Porque SQL Server permite asignar permisos directamente a estos roles o usuarios especiales. Por ejemplo:

- Si ves que `public` tiene permiso `SELECT` sobre una tabla, **todos los usuarios** podrán hacer `SELECT` en esa tabla.
- Si `guest` tiene permiso `CONNECT`, entonces usuarios sin usuario en la base de datos podrán conectarse.
- Si `dbo` tiene permisos sobre un objeto, es porque es el propietario o tiene privilegios elevados.

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
---

### 🧠 Conceptos de arquitectura y rendimiento relacionados con NUMA/UMA

| Concepto | Descripción |
|---------|-------------|
| **NUMA (Non-Uniform Memory Access)** | Arquitectura donde cada CPU tiene su propia memoria local. SQL Server puede optimizar el uso de recursos si está bien configurado. |
| **UMA (Uniform Memory Access)** | Arquitectura donde todos los CPUs acceden a la misma memoria con igual latencia. Menos eficiente en sistemas grandes. |
| **Soft-NUMA** | Técnica de SQL Server para simular NUMA en sistemas que no lo tienen, dividiendo CPUs lógicamente para mejorar el rendimiento. |
| **Affinity Mask / CPU Affinity** | Configuración que permite asignar CPUs específicos a SQL Server para controlar el uso de núcleos y mejorar el rendimiento. |
| **Memory Nodes** | En NUMA, cada nodo tiene su propia memoria. SQL Server puede asignar memoria por nodo para optimizar el acceso. |
| **Scheduler** | SQL Server usa planificadores por CPU y por nodo NUMA. Entender cómo se distribuyen las tareas es clave para evitar cuellos de botella. |
| **Parallelism (MAXDOP)** | Controla cuántos núcleos se usan para ejecutar una consulta en paralelo. Mal configurado puede causar problemas en entornos NUMA. |
| **Resource Governor** | Permite controlar el uso de CPU y memoria por grupo de trabajo, útil en servidores con múltiples aplicaciones o instancias. |
| **Buffer Pool Extension** | Usa SSD como extensión de memoria para el buffer pool, útil cuando hay limitaciones de RAM física. |
| **Lock Pages in Memory** | Permite que SQL Server mantenga páginas en memoria sin que el sistema operativo las intercambie, mejorando estabilidad en entornos críticos. |



---

### 🧠 Comparación general de entornos

| Entorno        | Propósito principal                     | Datos usados           | Usuarios principales         | Nivel de riesgo |
|----------------|------------------------------------------|-------------------------|-------------------------------|------------------|
| **Desarrollo** | Crear y probar nuevas funcionalidades    | Ficticios o mínimos     | Desarrolladores, DBAs         | Bajo             |
| **QA**         | Validar calidad y funcionalidad          | Simulados o anonimizados| QA, testers, DBAs             | Medio            |
| **Staging**    | Simular producción para pruebas finales  | Similares a producción  | DevOps, DBAs, QA              | Alto             |
| **Preprod**    | Validación con usuarios clave            | Reales o replicados     | Usuarios finales, QA, negocio| Alto             |
| **Producción** | Uso real por clientes o usuarios finales | Reales                  | Todos                         | Crítico          |

--- 

### 🧩 Tipos de RAID

| **RAID** | **Descripción** | **Ventajas** | **Desventajas** |
|----------|------------------|--------------|------------------|
| **RAID 0** | Distribuye los datos entre dos o más discos (striping). | Alta velocidad de lectura/escritura. | No tiene redundancia; si falla un disco, se pierde todo. |
| **RAID 1** | Duplica los datos en dos discos (mirroring). | Alta disponibilidad; tolerancia a fallos. | Solo se usa el 50% del espacio total. |
| **RAID 5** | Distribuye datos y paridad entre tres o más discos. | Buena velocidad y tolerancia a fallos. | Rendimiento de escritura más bajo; requiere mínimo 3 discos. |
| **RAID 6** | Similar a RAID 5 pero con doble paridad. | Puede tolerar la falla de dos discos. | Menor rendimiento de escritura; requiere mínimo 4 discos. |
| **RAID 10 (1+0)** | Combina RAID 1 y RAID 0 (mirroring + striping). | Alta velocidad y redundancia. | Costoso; requiere mínimo 4 discos. |
| **RAID 50 (5+0)** | Combina RAID 5 y RAID 0. | Mejor rendimiento y tolerancia que RAID 5. | Complejidad; requiere mínimo 6 discos. |
| **RAID 60 (6+0)** | Combina RAID 6 y RAID 0. | Alta tolerancia a fallos y buen rendimiento. | Muy complejo; requiere mínimo 8 discos. |
| **RAID 2, 3, 4** | Obsoletos o poco usados. Usan técnicas de paridad específicas. | Algunas ventajas en entornos específicos. | No se usan comúnmente hoy en día. |
| **JBOD (Just a Bunch Of Disks)** | No es RAID, pero se usa para agrupar discos sin redundancia. | Aprovecha todo el espacio. | Sin tolerancia a fallos. |

 
### 🧠 ¿Cuál es mejor según el uso?

| **Uso** | **RAID recomendado** |
|--------|-----------------------|
| Alto rendimiento sin necesidad de redundancia | RAID 0 |
| Alta disponibilidad y simplicidad | RAID 1 |
| Equilibrio entre rendimiento y seguridad | RAID 5 o RAID 6 |
| Máxima seguridad y velocidad | RAID 10 |
| Grandes volúmenes y alta tolerancia | RAID 50 o RAID 60 |


# **Estructuras internas de SQL Server (.mdf, .ndf)** 
que se usan para administrar el espacio en disco dentro de los archivos de datos (.mdf, .ndf). Son fundamentales para entender cómo SQL Server organiza las páginas y extents.

 
### ✅ **1. GAM (Global Allocation Map)**

*   **Qué es:** Una página especial que indica **qué extents (8 páginas = 64 KB)** están **libres o asignados** en un archivo de base de datos.
*   **Función:** Cada bit en la GAM representa un extent:
    *   **0** = extent asignado.
    *   **1** = extent libre.
*   **Ubicación:** Cada GAM cubre 4 GB de espacio de datos y se encuentra cada 511.232 páginas (\~4 GB).
 

### ✅ **2. SGAM (Shared Global Allocation Map)**

*   **Qué es:** Otra página especial que indica **qué extents están parcialmente usados para asignaciones mixtas**.
*   **Función:** SQL Server puede asignar páginas individuales dentro de un extent (mixed extent). SGAM marca:
    *   **1** = extent tiene páginas libres para asignación mixta.
    *   **0** = extent no disponible para asignación mixta.
*   **Ubicación:** Igual que GAM, cada SGAM cubre 4 GB.
 
### ✅ **3. PFS (Page Free Space)**

*   **Qué es:** Página que rastrea el **espacio libre dentro de cada página** y si está asignada.
*   **Función:** Indica:
    *   Si la página está asignada.
    *   Si es parte de un objeto.
    *   Cuánto espacio libre tiene (en rangos: 0-50%, 50-80%, etc.).
*   **Ubicación:** Cada PFS cubre 8.088 páginas (\~64 MB).


