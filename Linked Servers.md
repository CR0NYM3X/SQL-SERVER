

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
SELECT * FROM OPENQUERY(LINKEO_TEST, 'SELECT * FROM CAT_SERVIDORES LIMIT 10');
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


--- 

### 🎭 ¿Qué hace la casilla de **"Suplantar"**?

- **Permite que el usuario local actúe como si fuera el usuario remoto especificado**, **usando su propio contexto de seguridad**, en lugar de enviar explícitamente un usuario y contraseña.
 
### 🔍 ¿Cómo funciona?

- Cuando **activas "Suplantar"**, SQL Server **no envía usuario y contraseña** al servidor remoto.
- En su lugar, **intenta delegar el contexto de seguridad del usuario local** (por ejemplo, `DOMAIN\jose`) al servidor remoto.
- Esto **solo funciona si estás usando autenticación de Windows** y tienes **Kerberos y delegación configurados correctamente**.

--- 

### ✅ Recomendación de Mejores Prácticas

| Escenario | Opción recomendada | Seguridad |
|----------|--------------------|-----------|
| Entorno con Active Directory y Kerberos | **Opción 3** | 🔒 Alta |
| Entorno sin Kerberos pero con control de acceso centralizado | **Opción 4** (con cuenta de servicio segura) | 🔐 Media |
| Pruebas o desarrollo sin datos sensibles | **Opción 4 o 1** | 🧪 Baja |
| Nunca usar | **Opción 2** | 🚫 Muy baja |

 

### 🔐 Opción 1: **NO SE ESTABLECERÁN**

- **Descripción**: No se define ningún mapeo de usuario. SQL Server no intentará autenticar al usuario local en el servidor vinculado.
- **Seguridad**: Alta (si se configura correctamente)
- **Motivo de seguridad**: No se permite el acceso a menos que se configure explícitamente un inicio de sesión predeterminado o se use otro método de autenticación.
- **Método de conexión al servidor remoto**: No se conecta automáticamente. Requiere que se configure un inicio de sesión predeterminado en la pestaña de seguridad del Linked Server.
- **Ventajas**:
  - Evita accesos accidentales o no autorizados.
  - Obliga a definir reglas claras de acceso.
- **Desventajas**:
  - No funcional por sí sola; requiere configuración adicional.
  - Puede generar errores si no se entiende bien su propósito.
- **Recomendado**: Para entornos donde se desea un control estricto de acceso y se planea usar autenticación personalizada o delegación controlada.
- **¿Permite mapeo de usuarios?** ✅ Sí, pero solo si defines un inicio de sesión predeterminado.
- **¿Permite suplantar?** ❌ No aplica.
- **¿Requiere usuario y contraseña en el mapeo?** ✅ Solo si defines un inicio de sesión predeterminado.
**NOTA:** Al intentar mapear el usuario posiblemente te aparezca el mensaje "Access to the remote server is denied because no login-mapping exists. (Microsoft SQL Server, Error: 7416)" pero si permitira, no le hagas caso al mensaje 
---

### 🔐 Opción 2: **SE ESTABLECERÁN SIN USAR UN CONTEXTO DE SEGURIDAD**

- **Descripción**: Permite el acceso al servidor vinculado sin pasar credenciales. Es equivalente a un acceso anónimo.
- **Seguridad**: Muy baja
- **Motivo de seguridad**: Cualquier usuario puede acceder al servidor remoto sin autenticación, lo que representa un riesgo crítico.
- **Método de conexión al servidor remoto**: SQL Server intenta conectarse sin enviar credenciales. Depende de que el servidor remoto permita conexiones anónimas.
- **Ventajas**:
  - Fácil de configurar.
  - Útil para pruebas rápidas sin restricciones.
- **Desventajas**:
  - No hay trazabilidad de quién accede.
  - Riesgo de exposición de datos sensibles.
  - No cumple con estándares de seguridad corporativa.
- **Recomendado**: **Nunca** en producción. Solo para pruebas locales muy controladas y sin datos sensibles.
- **¿Permite mapeo de usuarios?** ❌ No. No se puede mapear porque no se usan credenciales.
- **¿Permite suplantar?** ❌ No.
- **¿Requiere usuario y contraseña en el mapeo?** ❌ No.

---

### 🔐 Opción 3: **SE ESTABLECERÁN USANDO EL CONTEXTO DE SEGURIDAD ACTUAL DE INICIO DE SESIÓN**

- **Descripción**: Se utiliza el contexto del usuario que inició sesión en SQL Server para autenticarse en el servidor vinculado. Requiere Kerberos y delegación configurada.
- **Seguridad**: Muy alta
- **Motivo de seguridad**: Se mantiene la identidad del usuario a través de los servidores, permitiendo auditoría y control de acceso granular.
- **Método de conexión al servidor remoto**: SQL Server usa el **usuario de Windows** con el que se conectó el cliente (ej. `jose`) y lo delega al servidor remoto mediante **Kerberos**. No se usan credenciales fijas.
- **Ventajas**:
  - Trazabilidad completa de accesos.
  - Cumple con políticas de seguridad basadas en identidad.
  - Ideal para entornos con Active Directory.
- **Desventajas**:
  - Requiere configuración avanzada (SPN, delegación, Kerberos).
  - Puede ser complejo de mantener.
- **Recomendado**: En entornos empresariales con infraestructura de seguridad bien definida (AD + Kerberos). Ideal para producción.
- **¿Permite mapeo de usuarios?** ❌ No. No se usa mapeo porque se delega el contexto directamente.
- **¿Permite suplantar?** ✅ Sí, si el servidor remoto lo permite y Kerberos está bien configurado.
- **¿Requiere usuario y contraseña en el mapeo?** ❌ No.

---

### 🔐 Opción 4: **SE ESTABLECERÁN USANDO ESTE CONTEXTO DE SEGURIDAD**

- **Descripción**: Se define un usuario y contraseña fijos para conectarse al servidor remoto, independientemente del usuario local.
- **Seguridad**: Media a baja (dependiendo de cómo se protejan las credenciales)
- **Motivo de seguridad**: Todos los usuarios usan las mismas credenciales, lo que puede permitir accesos no autorizados si no se controla adecuadamente.
- **Método de conexión al servidor remoto**: SQL Server se conecta **siempre** con el usuario y contraseña especificados en esta opción, por ejemplo: `usuario = postgres`, `contraseña = 123`.
- **Ventajas**:
  - Fácil de implementar.
  - No requiere configuración de Kerberos.
  - Útil cuando se necesita acceso constante con una cuenta de servicio.
- **Desventajas**:
  - No hay trazabilidad por usuario.
  - Riesgo si las credenciales se filtran.
  - Puede violar políticas de seguridad si no se protege adecuadamente.
- **Recomendado**: Para entornos de desarrollo, QA o cuando no se puede usar delegación. Asegúrate de usar una cuenta de servicio con permisos mínimos y rotación de contraseñas.
- **¿Permite mapeo de usuarios?** ✅ Sí. Puedes mapear usuarios locales a un usuario remoto específico.
- **¿Permite suplantar?** ✅ Sí, puedes activar la casilla de suplantar para que un usuario local actúe como otro.
- **¿Requiere usuario y contraseña en el mapeo?** ✅ Sí, debes especificarlos en cada mapeo o usar un inicio de sesión predeterminado.


---


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






