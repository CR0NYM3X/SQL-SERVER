



# Error \#1 : Login failed. The login is from an untrusted domain and cannot be used with Windows authentication.

https://solutions.dbwatch.com/Sqlserver/ <br><br>

**Validar el tipo de autenticación de sql server**
```
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')
```
**Para cambiar la contraseña del usuario y dominio**
```
https://aka.ms/ssprsetup
https://mysignins.microsoft.com/security-info
https://myaccount.microsoft.com
https://account.activedirectory.windowsazure.com/ChangePassword.aspx
```

**Validar el usuario que esas en windows**
ver tu usuario de dominio, LOS grupos en los que estas Y las políticas que tienes  aplicadas 
```
whoami /all 
```

**Verificar la existencia de un usuario en activi directory**
Si el usuario no existe te retornara el error "El dominio especificado no existe", si sí existe te retornara los dominios
```
 net user /domain alejandro.lopez
```
 

**ver las ip del dominio** 
- Con esta consulta vas a ver las ip y los dns de los dominios active directory que existen y responde a tu computadora,  por ejemplo:  usuario1.CRONYMEX.com, grupodessarollo,CRONYMEX.com, jefes.CRONYMEX.com
```
 nslookup -type=srv _ldap._tcp.dc._msdcs.CRONYMEX.com
```

- Con esta consulta vas a ver el a que subdominio pertenece
```
 echo %LOGONSERVER%

***** Ejemplo que retora esta consulta *****
\\jefes

***** validar la ip  *****
ping jefes

```
 
**Corroborar que el usuario si se puede autenticar y ver que si funcione correctamente**

```
****** EJECUTAS ESTE COMANDO PRIMERO Y COLOCAS CONTRASEÑA Y DESPUÉS SE ABRIRA EL CMD ******
runas /user:coppel\alejandro.lopez "C:\Windows\System32\cmd.exe"

****** UNA VEZ SE ABRA EL CMD NUEVO COLOCAS ESTE COMANDO Y TE DIRA SI ESTAS DENTRO DEL DOMINIO Y USUARIO ******
whoami

****** PARA VALIDAR SI PUEDES REALIZAR LA CONEXION DESDE SQLCMD  ******
sqlcmd -E -S 192.168.1.10 -d master -Q "select 'usuario:  '+SUSER_SNAME()"

```


**Mostrar una lista de los Controladores de Dominio disponibles en un dominio**
```
nltest /dclist:coppel 
```

**Verificar la confiabilidad y la conectividad al dominio**
```
nltest /dsgetdc:coppel 
```

**otros**
```
nltest /dsgetsite
nltest /domain_trusts
```

### Problemas para iniciar sesion por usuario huérfanos 
Este detalle se puede presentar porque el  sid usuario creado en la base de datos no coincide con el sid login, o  puede ser que el usuario de la base de datos no se elimino y que el login si se elimino , entonces por eso se dice que
el usuario se quedo huérfanos porque ya no esta ligado a un login, y siempre un usuario debe de tener un login y coincidir su sid 




**sp_change_users_login** es un procedimiento almacenado en SQL Server que solía utilizarse para corregir la desincronización entre un usuario de base de datos y su inicio de sesión correspondiente en el servidor de base de datos.
```
***** Identificar usuarios sin asociar con logins: *****

-- Si no coinciden entonces es un usuario huérfanos
SELECT a.name, a.sid, b.sid, a.type_desc
FROM sys.database_principals AS a
LEFT JOIN sys.server_principals AS b on a.name COLLATE DATABASE_DEFAULT = b.name COLLATE DATABASE_DEFAULT
where a.type_desc in('WINDOWS_USER', 'SQL_USER' ,  'DATABASE_ROLE','WINDOWS_GROUP') and 
a.sid != b.sid --and a.name= 'AdmonFlotas'
ORDER BY a.type_desc,a.name;

-- o puedes usar el procedimiento que es para lo mismo
EXEC sp_change_users_login 'Report';




***** Vincular un usuario huérfano con un inicio de sesión: ***** 
EXEC sp_change_users_login 'Update_One', 'nombre_de_usuario', 'nombre_de_login';

***** OTRA OPCIÓN ES ***** 
ALTER USER nombre_de_usuario WITH LOGIN = nombre_de_login;
```

### solucion 
se cambio de contraseña el correo 

Para validar si tu servidor está dentro de un dominio y a qué dominios apunta, puedes usar varios comandos en la línea de comandos (CMD). Aquí te dejo los pasos detallados:

### Validar si el Servidor Está en un Dominio

1. **Abrir CMD con Privilegios de Administrador**:
   - Haz clic derecho en el menú de inicio y selecciona "Símbolo del sistema (Administrador)".

2. **Usar el Comando `systeminfo`**:
   - Escribe el siguiente comando para obtener información del sistema, incluyendo el dominio al que pertenece:

     ```cmd
     systeminfo | findstr /B /C:"Domain"
     ```

   - Este comando buscará la línea que comienza con "Domain" en la salida de `systeminfo`.

### Ejemplo de Salida

```cmd
Domain:                    DOMINIO_LOCAL
```

Si el servidor está en un dominio, verás el nombre del dominio. Si no está en un dominio, verás algo como "Workgroup".

### Ver a Qué Dominios Apunta

1. **Usar el Comando `nltest`**:
   - Puedes usar `nltest` para listar los controladores de dominio (DC) disponibles en tu dominio:

     ```cmd
     nltest /dclist:tu_dominio
     ```

   - Reemplaza `tu_dominio` con el nombre de tu dominio.

### Ejemplo de Salida

```cmd
C:\> nltest /dclist:dominio
    Lista de DCs en dominio "dominio" desde \\DC1
        DC1.dominio.com [PDC]
        DC2.dominio.com
    El comando se completó correctamente
```

### Verificar Relaciones de Confianza entre Dominios
 puede verificar las relaciones de confianza entre dominios. Esto es útil para asegurarse de que los dominios confían entre sí y que la autenticación cruzada funciona correctamente.

1. **Usar el Comando `netdom`**:
   - Para verificar las relaciones de confianza entre dominios, puedes usar el siguiente comando:

     ```cmd
     netdom trust trusting_domain /d:trusted_domain /verify
     ```

   - Reemplaza `trusting_domain` y `trusted_domain` con los nombres de los dominios correspondientes.

2. **Listar Relaciones de Confianza**:
   - Puedes listar todas las relaciones de confianza que un dominio tiene con otros dominios.

     ```cmd
     netdom trust nombre_del_dominio /domain:dominio /enumerate
     ```


### Ejemplo de Uso

```cmd
netdom trust dominio_local /d:dominio_remoto /verify
```




Para validar si un usuario existe en el Active Directory desde la línea de comandos (CMD), puedes utilizar el comando `dsquery`. Aquí te dejo los pasos para hacerlo:

### Validar Usuario en Active Directory

1. **Buscar Usuarios**:
   - Puedes buscar usuarios en el dominio utilizando varios criterios, como el nombre.

     ```cmd
     dsquery user -name "nombre_del_usuario"
     ```

2. **Buscar Grupos**:
   - Puedes buscar grupos en el dominio.

     ```cmd
     dsquery group -name "nombre_del_grupo"
     ```

3. **Buscar Unidades Organizativas (OU)**:
   - Puedes buscar unidades organizativas en el dominio.

     ```cmd
     dsquery ou -name "nombre_de_la_ou"
     ```

4. **Buscar Equipos**:
   - Puedes buscar equipos en el dominio.

     ```cmd
     dsquery computer -name "nombre_del_equipo"
     ```
 


### Ejemplo 

Aquí tienes un ejemplo completo de cómo se vería:

```cmd
C:\> dsquery user -name "juan.perez"
"CN=Juan Perez,OU=Usuarios,DC=dominio,DC=com"
```



### Alternativa con `net user`

Otra forma de verificar si un usuario de dominio existe es utilizando el comando `net user`:

```cmd
net user nombre_del_usuario /domain
```

Por ejemplo:

```cmd
net user juan.perez /domain
```
  


### Resumen

- **`systeminfo`**: Para verificar si el servidor está en un dominio.
- **`nltest`**: Para listar los controladores de dominio.
- **`netdom`**: Para verificar relaciones de confianza entre dominios.
 
 






### link de apoyo
************** The login is from an untrusted ************** <br>
https://windowsreport.com/0x8009030c/ <br>
https://dba.stackexchange.com/questions/191267/sspi-handshake-failed-with-error-code-0x8009030c-state-14












# Error \#2 : Could not open error log file.
Al intentar inciar el servicio de sql, aparecia el siguiente error 
```sql
****************** ERROR ******************
 Error : "initerrlog: Could not open error log file 'F:\SQLERRORLOG\ERRORLOG'. Operating system error = 5(Access is denied.)"

****************** SOLUCION ******************
se dio permiso en el disco F al usuario que levanta el servicio de sql server
```



# Error \#3 : The system cannot find the path specified.

Al intentar levantar el servicio de sql server, se levanto el servicio pero casi todas las base de datos estaban con estatus "Recovery Pending"  y validando el log salio el error de ":Open failed: Could not open"
```sql
*********** ERROR ***********
FCB::Open failed: Could not open file O:\SQLSERVDATA\TablasTmp.MDF for file number 1.  OS error: 3(The system cannot find the path specified.). 2024-01-05 10:43:31.19 spid61s     Error: 5120, Severity: 16, State: 101.


************* QUERYS UTILIZADAS **********
# Muestra la rutas los archivos de la base de datos que no estan online 
select DB_NAME(database_id),name,physical_name,LEFT(physical_name, 1) unidad_disco from sys.master_files 
where database_id in(select database_id from sys.databases where state_desc != 'ONLINE')
order by database_id

# Muestra las rutas de todos los archivos de la base de datos 
SELECT  physical_name from sys.master_files

# puedes ver los log del servidor 
EXEC sp_readerrorlog 0, 1, 'Open failed'

EXEC sp_readerrorlog 0, 1, 'Recovery of database'



************* SOLUCION **********
1.- Descargue el bat -> https://github.com/CR0NYM3X/SQL-SERVER/tree/main/script_bat 
2.- Se paso al servidor la herramienta validador_de_archivos.bat y se creo el archivo "Rutas.txt" en la misma ruta donde coloque el bat,
y llene el txt con los physical_name de las base de datos, obtenida esta info de la tabla sys.master_files
3.- Se encontro que los archivos mdf y ldf  se  encontraban en otros discos con diferentes letras
4.- Se detuvo el servicio de sql server y se apoyo por parte de windows a cambiar las letras
5.- Se levanto el servicio y las base de datos que tenian el detalle se pusieron en estatus "restoring"
6.- Finalizo la restauración y ya permitio ingresar a las dbs

```


# Error \#3 - Se queda en NTLM en la columna auth_scheme 

```



1.- Validacion de kerberos habilitados  


	 el valor de la columna auth_scheme, que será KERBEROS si Kerberos está habilitado.
	https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/register-a-service-principal-name-for-kerberos-connections?view=sql-server-ver16
 

	SELECT net_transport, auth_scheme FROM sys.dm_exec_connections WHERE session_id = @@SPID;

	**Resultado esperado:**  
	`KERBEROS` (si la autenticación es exitosa).  
	Si muestra `NTLM`, hay un problema con Kerberos.




2.- **Validar la Cuenta de Servicio de SQL Server:**
  - El servicio de SQL Server   debe ejecutarse bajo una **cuenta de dominio** o **cuenta de servicio gestionada (gMSA)**.
  
 
  EXEC xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER', 
    N'ObjectName';
  
  -- Confirmar si SQL Server reconoce su unión al dominio
  SELECT DEFAULT_DOMAIN() AS Dominio;	 


 

3.- **Verificar LOGS Intentos de Registro de SPN**
	EXEC xp_readerrorlog 0, 1, N'SPN';
	**Resultado esperado:**  
		Mensajes como `The SPN ... for SQL Server registration succeeded`.  
		Si hay errores como `Cannot generate SSPI context`, el SPN está mal configurado.
 

		
4.- ** Validar la Autenticación de Cuentas de Dominio**
	Probar si SQL Server reconoce una cuenta de dominio existente.
	
	-- Intentar crear un login temporal de dominio (solo para prueba)
		CREATE LOGIN [DOMINIO\UsuarioDePrueba] FROM WINDOWS 




5.- **Verificar la Unión al Dominio:** 
   Debe mostrar el nombre del dominio 

    systeminfo | findstr /B /C:"Nombre de dominio"
   


6.- **Comprobar la Configuración de DNS:**
Los servidores DNS deben apuntar a los controladores de dominio de la empresa

	-- validar server 
	nslookup diminio.com
	
	-- validar si estan configurados los dns 
	ipconfig /all
   
 
 nltest /dsgetdc:tu_dominio.com
 nslookup -type=srv _ldap._tcp.dc._msdcs.tu_dominio.com

  
7.- **Verificar SPN (Service Principal Name):**
 Los SPN son críticos para Kerberos. Si están mal configurados, se producirán errores de autenticación.
 Debes ver un SPN como: `MSSQLSvc/nombre_equipo.dominio.com:1433`
	 setspn -L NOMBRE_EQUIPO_SQL
	 
	 
	 
	 

8.- **Verificar fuente de tiempo:**
	
		 ---- Indicadores de Problemas de Sincronización:

		1. **Leap Indicator**: Si el valor no es 0.
		   - **Valor esperado**: `0 (no warning)`
		   - **Valor problemático**: Cualquier valor diferente de 0.

		2. **Stratum**: Si el valor es demasiado alto (idealmente debe estar entre 1 y 4). Indica la proximidad del servidor a la fuente de tiempo original. Un valor más bajo indica una mayor proximidad. Un valor de 1 es ideal, mientras que valores mayores indican mayor distancia.
		   - **Valor esperado**: `1 a 4`
		   - **Valor problemático**: Valores superiores a 4.

		3. **Diferencia de Tiempo (Offset)**: Si la diferencia de tiempo es significativa (más de ±1 segundo).
		   - **Valor esperado**: Dentro de ±1 segundo.
		   - **Valor problemático**: Más de ±1 segundo.



	 -- Verificar fuente de tiempo: 
		w32tm /query /peers
		w32tm /query /status	
	  
		 - **Resultado esperado:**  
		 `Fuente de tiempo: dominio.com` (ej: `dc01.dominio.com`).
	 
	 . **Forzar sincronización manual:**
		w32tm /resync /force
		
		
9.- **Verificar diferencia de tiempo con el controlador de dominio:**
 
		net time \\nombre_dc /set
		w32tm /stripchart /computer:dominio.com /samples:10 /period:10 /dataonly

 
   - Si hay un desfase mayor a 5 minutos, ajusta la hora automáticamente:
 
		w32tm /config /syncfromflags:domhier /update	 
	 
	 
	 
 
10. **Firewall y Puertos:**
   - Asegúrate de que los puertos necesarios para Active Directory/Kerberos estén abiertos:
     - **Kerberos**: Puerto **88** (TCP/UDP).
     - **LDAP**: Puerto **389** (TCP/UDP).
     - **Global Catalog**: Puerto **3268** (TCP).
     - **DNS**: Puerto **53** (TCP/UDP).


Test-NetConnection -ComputerName 192.168.5.100 -Port  1433

 
11.- **Reiniciar el Servicio de SQL Server:**
    - Después de cambiar la cuenta de servicio o SPN, reinicia el servicio de SQL Server.
	
	
	
	
 
12.- 
https://dba.stackexchange.com/questions/296040/cannot-connect-to-mssql-using-kerberos-auth
ipconfig /flushdns

		

----
klist tickets

		
		
		
Fuentes : 
https://www.mssqltips.com/sqlservertip/6772/kerberos-configuration-manager-for-sql-server/
		
		
		

```




# Error \#5 []JAVA-  Algorithm constraints check failed on signature algorithm: SHA1withRSA
```
---------------------------------------- LOG ERROR ----------------------------------------

10:11  INFO 1 --- [ppel-connection] c.c.connections.CoppelConnectionProxy    : Error al obtener conexion: jdbc:sqlserver://192.168.1.100;databaseName=db_test;Encrypt=True;TrustServerCertificate=True
com.microsoft.sqlserver.jdbc.SQLServerException: "encrypt" property is set to "true" and "trustServerCertificate" property is set to "true" but the driver could not establish a secure connection to SQL Server by using Secure Sockets Layer (SSL) encryption: Error: Certificates do not conform to algorithm constraints. ClientConnectionId:1c60bdfd-5dc5-4bb3-8659-c03457433fda
	at com.microsoft.sqlserver.jdbc.SQLServerConnection.terminate(SQLServerConnection.java:4271) ~[mssql-jdbc-12.8.1.jre11.jar!/:na]
	Caused by: javax.net.ssl.SSLHandshakeException: Certificates do not conform to algorithm constraints
	at java.base/sun.security.ssl.Alert.createSSLException(Alert.java:130) ~[na:na]
	at java.base/sun.security.ssl.TransportContext.fatal(TransportContext.java:383) ~[na:na]
	at java.base/sun.security.ssl.CertificateMessage$T12CertificateConsumer.checkServerCerts(CertificateMessage.java:647) ~[na:na]
	at java.base/sun.security.ssl.CertificateMessage$T12CertificateConsumer.onCertificate(CertificateMessage.java:467) ~[na:na]
	at java.base/sun.security.ssl.CertificateMessage$T12CertificateConsumer.consume(CertificateMessage.java:363) ~[na:na]
	at java.base/sun.security.ssl.SSLHandshake.consume(SSLHandshake.java:393) ~[na:na]
	at java.base/sun.security.ssl.HandshakeContext.dispatch(HandshakeContext.java:476) ~[na:na]
	at java.base/sun.security.ssl.HandshakeContext.dispatch(HandshakeContext.java:447) ~[na:na]
	at java.base/sun.security.ssl.TransportContext.dispatch(TransportContext.java:206) ~[na:na]
	at java.base/sun.security.ssl.SSLTransport.decode(SSLTransport.java:172) ~[na:na]
	at java.base/sun.security.ssl.SSLSocketImpl.decode(SSLSocketImpl.java:1506) ~[na:na]
	at java.base/sun.security.ssl.SSLSocketImpl.readHandshakeRecord(SSLSocketImpl.java:1421) ~[na:na]
	at java.base/sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:455) ~[na:na]
	at java.base/sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:426) ~[na:na]
	at com.microsoft.sqlserver.jdbc.TDSChannel.enableSSL(IOBuffer.java:1854) ~[mssql-jdbc-12.8.1.jre11.jar!/:na]
	... 13 common frames omitted
Caused by: java.security.cert.CertificateException: Certificates do not conform to algorithm constraints
	at java.base/sun.security.ssl.AbstractTrustManagerWrapper.checkAlgorithmConstraints(SSLContextImpl.java:1557) ~[na:na]
	at java.base/sun.security.ssl.AbstractTrustManagerWrapper.checkAdditionalTrust(SSLContextImpl.java:1484) ~[na:na]
	at java.base/sun.security.ssl.AbstractTrustManagerWrapper.checkServerTrusted(SSLContextImpl.java:1431) ~[na:na]
	at java.base/sun.security.ssl.CertificateMessage$T12CertificateConsumer.checkServerCerts(CertificateMessage.java:631) ~[na:na]
	... 25 common frames omitted
Caused by: java.security.cert.CertPathValidatorException: Algorithm constraints check failed on signature algorithm: SHA1withRSA
	at java.base/sun.security.provider.certpath.AlgorithmChecker.check(AlgorithmChecker.java:231) ~[na:na]
	at java.base/sun.security.ssl.AbstractTrustManagerWrapper.checkAlgorithmConstraints(SSLContextImpl.java:1553) ~[na:na]
	... 28 common frames omitted

10:11  WARN 1 --- [qtp739971314-43] o.s.b.f.support.DisposableBeanAdapter    : Invocation of close method failed on bean with name 'scopedTarget.getTransactionInfo': com.coppel.exceptions.RetrievableException: La conexion se ha cerrado o es invalida.

---------------------------------------- LOG ERROR ----------------------------------------


---------------------------------------- INVESTIGACIÓN ----------------------------------------


Conclusión Revisar  lo siguiente :

1.- modificar el java.security para eliminar el sha1 de la variable  jdk.certpath.disabledAlgorithms=

2.-  Cree su imagen modificando el Dockerfile para anular la política de cifrado 

3.- Actualizar el JDBC a 12.10 



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




### Funcionamiento de TLS en SQL Server

1. **Cifrado por Defecto**: Cuando configuras `encrypt_connection=true` en tu cadena de conexión, SQL Server intenta cifrar la conexión utilizando TLS. Si no has instalado un certificado de servidor, SQL Server genera un certificado autofirmado (certificado de reserva) durante el inicio y lo usa para cifrar las credenciales .

2. **Opción `trust_server_certificate`**: Cuando `trust_server_certificate=true`, el cliente confía en el certificado del servidor sin validar su autenticidad. Esto es útil en entornos de prueba o cuando se usa un certificado autofirmado. Si `trust_server_certificate=false`, el cliente intentará validar el certificado del servidor contra una autoridad de certificación de confianza .

3. **Columna `encrypt_option`**: Esta columna en la vista `sys.dm_exec_connections` indica si la conexión está cifrada. Si `encrypt_connection=true`, esta columna debería mostrar `true`, independientemente de si el certificado es autofirmado o emitido por una autoridad de certificación.

### Por qué ves `encrypt_option=true` sin haber instalado un certificado

- **Certificado Autofirmado**: SQL Server está utilizando un certificado autofirmado para cifrar la conexión. Esto es suficiente para que la columna `encrypt_option` muestre `true` cuando `encrypt_connection=true`.

- **Validación del Certificado**: Cuando configuras `trust_server_certificate=false`, el cliente no confía en el certificado autofirmado y, por lo tanto, la conexión no se cifra, resultando en `encrypt_option=false` .

### Recomendaciones

Para un entorno de producción, es recomendable instalar un certificado emitido por una autoridad de certificación de confianza. Aquí tienes los pasos básicos:

1. **Obtener un Certificado**: Solicita un certificado de una autoridad de certificación.
2. **Instalar el Certificado**: Instala el certificado en el servidor SQL utilizando el Administrador de configuración de SQL Server ..
3. **Configurar SQL Server**: Configura SQL Server para usar el certificado instalado.
 


### Certificado Autofirmado
Cuando configuras `encrypt_connection=true` y no has instalado un certificado específico, SQL Server utiliza un certificado autofirmado para cifrar las conexiones. Este certificado autofirmado se genera una vez y se reutiliza para todas las conexiones hasta que se reinicie el servidor o se cambie la configuración [1](https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/certificate-requirements?view=sql-server-ver16).

### Almacenamiento de Certificados
Los certificados, incluidos los autofirmados, se almacenan en el **almacén de certificados del equipo local** o en el **almacén de certificados de la cuenta de servicio de SQL Server**Se recomienda el almacén de certificados del equipo local para evitar problemas de configuración cuando se cambia la cuenta de inicio de SQL Server [1](https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/certificate-requirements?view=sql-server-ver16).

### Reutilización de Certificados
El certificado autofirmado no se genera para cada conexión nueva. En lugar de eso, se reutiliza el mismo certificado para todas las conexiones mientras el servidor esté en funcionamiento. Esto significa que cuando te desconectas y te vuelves a conectar, SQL Server sigue utilizando el mismo certificado autofirmado.



### Consecuencias de `TrustServerCertificate=false`
1. **Mayor Seguridad**: Al validar el certificado, se asegura que la conexión es segura y que no está siendo interceptada por un atacante (ataque de hombre en el medio).
2. **Errores de Conexión**: Si el certificado no es válido, está expirado, o no es emitido por una autoridad de certificación confiable, la conexión fallará .

 
REF : 


# Configuración del Motor de base de datos de SQL Server para cifrar conexiones
    https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/configure-sql-server-encryption?view=sql-server-ver16#sql-server-generated-self-signed-certificates
    
     

# Requisitos de certificado para SQL Server
    https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/certificate-requirements?view=sql-server-ver16
	
	
	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------







### 3. **Configuración del Almacén de Confianza**
Aunque `trustServerCertificate=true` permite conexiones sin validar el certificado, es recomendable verificar la configuración del **almacén de confianza** (trustStore) en tu JVM para evitar problemas futuros . Si decides usar un trustStore, asegúrate de especificar las propiedades `trustStore` y `trustStorePassword` en tu cadena de conexión:

java
String connectionUrl = "jdbc:sqlserver://localhost:1433;"
    + "databaseName=tuBaseDeDatos;"
    + "encrypt=true;trustServerCertificate=false;"
    + "trustStore=path/to/truststore;trustStorePassword=tuPassword;";


 
### ¿Qué es un TrustStore?
Un **trustStore** almacena certificados que identifican a otros servidores o entidades con las que tu aplicación se comunica de manera segura . Cuando tu aplicación se conecta a un servidor, verifica el certificado del servidor contra los certificados almacenados en el trustStore. Si el certificado del servidor está en el trustStore, la conexión se considera segura.

### ¿Cómo se usa un TrustStore?
Para usar un trustStore en Java, debes especificar su ubicación y contraseña mediante propiedades del sistema. Aquí tienes un ejemplo de cómo configurar un trustStore:

java
System.setProperty("javax.net.ssl.trustStore", "ruta/al/truststore.jks");
System.setProperty("javax.net.ssl.trustStorePassword", "tuContraseña");


### Creación y Gestión de un TrustStore
Puedes crear y gestionar un trustStore utilizando la herramienta **keytool** de Java. Aquí tienes algunos comandos útiles:

1. **Crear un TrustStore**:
   bash
   keytool -genkey -alias miAlias -keyalg RSA -keystore truststore.jks -storepass tuContraseña
   

2. **Importar un Certificado**:
   bash
   keytool -import -alias miAlias -file certificado.crt -keystore truststore.jks -storepass tuContraseña
   

### Consideraciones al Usar un TrustStore
- **Ubicación del TrustStore**: Asegúrate de que el trustStore esté accesible para tu aplicación y que la ruta especificada sea correcta.
- **Contraseña**: Protege tu trustStore con una contraseña segura y no la compartas públicamente.
- **Certificados**: Mantén tu trustStore actualizado con los certificados necesarios para las conexiones seguras .

### Ejemplo de Uso en una Aplicación
Aquí tienes un ejemplo de cómo configurar una conexión segura utilizando un trustStore en Java:

java
import java.sql.Connection;
import java.sql.DriverManager;

public class SecureConnection {
    public static void main(String[] args) {
        System.setProperty("javax.net.ssl.trustStore", "ruta/al/truststore.jks");
        System.setProperty("javax.net.ssl.trustStorePassword", "tuContraseña");

        String connectionUrl = "jdbc:sqlserver://localhost:1433;databaseName=tuBaseDeDatos;encrypt=true;trustServerCertificate=false;";
        try (Connection con = DriverManager.getConnection(connectionUrl, "tuUsuario", "tuContraseña")) {
            System.out.println("Conexión segura establecida.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}


 

### TrustStore
El **TrustStore** es un almacén de confianza que contiene los certificados de las autoridades de certificación (CA) en las que confía tu aplicación.Este almacén se utiliza para verificar la autenticidad de los servidores con los que tu aplicación se comunica. Puedes configurar un TrustStore personalizado especificando su ubicación y contraseña mediante propiedades del sistema Java:

java
-Djavax.net.ssl.trustStore=/ruta/a/tu/truststore
-Djavax.net.ssl.trustStorePassword=tuContraseña


### cacerts
El archivo **cacerts** es el TrustStore predeterminado que viene con la instalación de Java. Este archivo, ubicado generalmente en `lib/security/cacerts` dentro del directorio de instalación de Java, contiene certificados de muchas CA conocidas.Cuando no se especifica un TrustStore personalizado, Java utiliza el archivo cacerts para autenticar servidores.

### Relación entre TrustStore y cacerts
- **TrustStore predeterminado**: Si no configuras un TrustStore personalizado, Java utilizará el archivo cacerts como su TrustStore predeterminado .
- **Personalización**: Puedes crear y utilizar un TrustStore personalizado si necesitas incluir certificados específicos que no están en el archivo cacerts .
- **Compatibilidad**: Al migrar a una nueva versión de Java, como Java 21, es importante asegurarte de que cualquier TrustStore personalizado que estés utilizando sea compatible y esté correctamente configurado.





 El **TrustStore** y el archivo **cacerts** pueden utilizarse tanto para certificados emitidos por una entidad certificadora (CA) como para certificados autofirmados. Aquí te explico cómo funcionan en cada caso:

### Certificados Emitidos por una CA
- **TrustStore**: Cuando utilizas certificados emitidos por una CA reconocida, estos certificados se almacenan en el TrustStore. Java utiliza el TrustStore para verificar la autenticidad del servidor durante las conexiones SSL/TLS.
- **cacerts**: El archivo cacerts, que es el TrustStore predeterminado de Java, ya contiene muchos certificados de CA reconocidas. Si tu certificado está emitido por una CA incluida en cacerts, no necesitas hacer ninguna configuración adicional .

### Certificados Autofirmados
- **TrustStore**: Para certificados autofirmados, debes agregar manualmente el certificado al TrustStore para que Java pueda confiar en él. Esto es necesario porque los certificados autofirmados no están emitidos por una CA reconocida .
- **cacerts**: Puedes agregar certificados autofirmados al archivo cacerts para que Java los reconozca como confiables. Esto se hace utilizando herramientas como `keytool` .

### Ejemplo de Configuración
Para agregar un certificado autofirmado al TrustStore o cacerts, puedes usar el siguiente comando `keytool`:

sh
keytool -import -alias miCertificado -file ruta/al/certificado.cer -keystore ruta/al/truststore.jks


Este comando importa el certificado al TrustStore especificado. Si quieres agregarlo al cacerts, reemplaza `ruta/al/truststore.jks` por la ruta al archivo cacerts.

### Consideraciones
- **Entornos de Desarrollo**: Los certificados autofirmados son comunes en entornos de desarrollo y pruebas.
- **Entornos de Producción**: En producción, es recomendable utilizar certificados emitidos por una CA reconocida para garantizar la seguridad y confianza de las conexiones .
 



Cuando utilizas la propiedad `trustServerCertificate=true` en tu cadena de conexión, **Java no utiliza el archivo cacerts** para verificar el certificado del servidor [. Esta propiedad indica que tu aplicación debe confiar en el certificado del servidor sin realizar una verificación completa contra el TrustStore (incluyendo cacerts) .

### ¿Qué significa esto?
- **Sin verificación**: Al establecer `trustServerCertificate=true`, estás indicando que tu aplicación debe aceptar el certificado del servidor tal como está, sin importar si está firmado por una autoridad de certificación conocida ..
- **Uso de cacerts**: Si `trustServerCertificate=false`, entonces Java utilizará el TrustStore (que puede ser el archivo cacerts predeterminado) para verificar la autenticidad del certificado del servidor .

### Ejemplo de cadena de conexión
java
String connectionUrl = "jdbc:sqlserver://localhost:1433;"
    + "databaseName=tuBaseDeDatos;"
    + "encrypt=true;trustServerCertificate=true;"
    + "user=tuUsuario;password=tuContraseña;";







------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




# Recomendaciones 

1. Actualizar el controlador JDBC

    Aun que en la página oficial de SQL Server indica que la version de JDBC 12.8 es compatible con SQL Server 2016 y JRE 21 de igual forma no es una mala idea actualizar.

        Ref: https://learn.microsoft.com/es-es/sql/connect/jdbc/microsoft-jdbc-driver-for-sql-server-support-matrix?view=sql-server-ver16

2. Actualizar los certificados SSL
    El error indica que los certificados no cumplen con las restricciones de algoritmos, específicamente SHA1withRSA hay que actualizar los certificados.
    
    
    "Caused by: java.security.cert.CertPathValidatorException: Algorithm constraints check failed on signature algorithm: SHA1withRSA"
    
    
    Ref: 
        https://learn.microsoft.com/en-us/answers/questions/1199915/certificates-do-not-conform-to-algorithm
        https://stackoverflow.com/questions/75697268/keycloak-on-azure-to-postgresql-certificates-do-not-conform-to-algorithm-constr
        https://learn.microsoft.com/en-us/sql/connect/jdbc/configuring-the-client-for-ssl-encryption?view=sql-server-ver16
        https://learn.microsoft.com/es-es/sql/connect/jdbc/connecting-with-ssl-encryption?view=sql-server-ver16
        

3. Características obsoletas del motor de base de datos en SQL Server 2016

     SQL Server 2016 y versiones anteriores utilizan el algoritmo SHA1, que ya no se considera seguro.
     El uso de MD2, MD4, MD5, SHA y SHA1 Utilice SHA2_256 o SHA2_512 en su lugar. 

    Ref: https://learn.microsoft.com/en-us/sql/database-engine/deprecated-database-engine-features-in-sql-server-2016?view=sql-server-ver16
    Ref: https://support.microsoft.com/en-us/topic/kb4053407-fix-sql-server-2017-cannot-decrypt-data-encrypted-by-earlier-versions-of-sql-server-by-using-the-same-symmetric-key-a33f8bc7-e01a-55c6-72db-b851334df3dd

4. Validacion de connexion string 
    "jdbc:sqlserver://192.168.10.101;databaseName=pruebas_db;Encrypt=True;TrustServerCertificate=True";
	

5. Actualizar el cacert 

    Comando: 
        $JAVA_HOME/keytool -import -alias <server_name> -keystore $JAVA_HOME/lib/security/cacerts -file CERTIFICATE_FILE_NAME 

    Ref: 
        https://support.atlassian.com/bitbucket-data-center/kb/ssl-algorithm-constraints-check-failed/
        https://learn.microsoft.com/en-us/answers/questions/2125449/ssl-error-connection-into-sql-server-2016-standar

6.-  Alternativas para la implementación de contenedores Docker

    Cree su imagen modificando el Dockerfile para anular la política de cifrado

    Comando: 
        RUN update-crypto-policies --set DEFAULT:SHA1



7.- Validación de código Java en parámetros

    Comando: 	
		private static final String[] protocols = new String[]{"TLSv1.3"}; private static final String[] cipher_suites = new String[]{"TLS_AES_128_GCM_SHA256"};
 
    Ref: 
		https://snyk.io/es/blog/implementing-tls-in-java/


Ref Adicionales : 

    # especificación java.security para su JDK y permitir el algoritmo SHA1
        https://stackoverflow.com/questions/78576008/java-security-cert-certpathvalidatorexception-algorithm-constraints-check-faile
        

    # Java TLS Handshake fails 
        https://access.redhat.com/solutions/6992400
        
        
     
    # Create and Install a Self-Signed SSL/TLS Certificate for SQL Server
        https://codekabinett.com/rdumps.php?Lang=2&targetDoc=create-install-ssl-tls-certificate-sql-server
		
		
	# Nombres de algoritmos del estándar de seguridad de Java
		https://docs.oracle.com/en/java/javase/21/docs/specs/security/standard-names.html
	
	
	# clipersuite   --- TLS 1.3  (TLS_AES_256_GCM_SHA384)  ---  TLS 1.2  (ECDHE-RSA-AES256-GCM-SHA384)
		https://www.ibm.com/docs/en/ibm-mq/9.3.x?topic=java-tls-cipherspecs-ciphersuites-in-mq-classes
		
		




```
