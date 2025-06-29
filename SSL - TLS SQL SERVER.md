

### Funcionamiento de TLS en SQL Server

1. **Cifrado por Defecto**: Cuando configuras `Encrypt=true` en tu cadena de conexión, SQL Server intenta cifrar la conexión utilizando TLS. Si no has instalado un certificado de servidor, SQL Server genera un certificado autofirmado (certificado de reserva) durante el inicio y lo usa para cifrar las credenciales.

2. **Opción `TrustServerCertificate`**: Cuando `TrustServerCertificate=true`, el cliente confía en el certificado del servidor sin validar su autenticidad. Esto es útil en entornos de prueba o cuando se usa un certificado autofirmado. 

3. **Opción `TrustServerCertificate`**: Cuando `TrustServerCertificate=false`
	1. **Mayor Seguridad**: Al validar el certificado, se asegura que la conexión es segura y que no está siendo interceptada por un atacante (ataque de hombre en el medio).
	2. **Errores de Conexión**: Si el certificado no es válido, está expirado, o no es emitido por una autoridad de certificación confiable, la conexión fallará .
	 

4. **Columna `encrypt_option`**: Esta columna en la vista `sys.dm_exec_connections` indica si la conexión está cifrada. Si `Encrypt=true`, esta columna debería mostrar `true`, independientemente de si el certificado es autofirmado o emitido por una autoridad de certificación.

### Por qué ves `encrypt_option=true` sin haber instalado un certificado

- **Certificado Autofirmado**: SQL Server está utilizando un certificado autofirmado para cifrar la conexión. Esto es suficiente para que la columna `encrypt_option` muestre `true` cuando `Encrypt=true`.

- **Validación del Certificado**: Cuando configuras `TrustServerCertificate=false`, el cliente no confía en el certificado autofirmado y, por lo tanto, la conexión no se cifra, resultando en `encrypt_option=false` .



### Certificado Autofirmado
Cuando configuras `Encrypt=true` y no has instalado un certificado específico, SQL Server utiliza un certificado autofirmado para cifrar las conexiones. Este certificado autofirmado se genera una vez
 y se reutiliza para todas las conexiones hasta que se reinicie el servidor o se cambie la configuración ..

### Almacenamiento de Certificados
Los certificados, incluidos los autofirmados, se almacenan en el **almacén de certificados del equipo local** o en el **almacén de certificados de la cuenta de servicio de SQL Server** .

### Reutilización de Certificados
El certificado autofirmado no se genera para cada conexión nueva. En lugar de eso, se reutiliza el mismo certificado para todas las conexiones mientras el servidor esté en funcionamiento . Esto significa que cuando te desconectas y te vuelves a conectar,
 SQL Server sigue utilizando el mismo certificado autofirmado.

 

### Recomendaciones

Para un entorno de producción, es recomendable instalar un certificado emitido por una autoridad de certificación de confianza. Aquí tienes los pasos básicos:

1. **Obtener un Certificado**: Solicita un certificado de una autoridad de certificación.
2. **Instalar el Certificado**: Instala el certificado en el servidor SQL utilizando el Administrador de configuración de SQL Server ..
3. **Configurar SQL Server**: Configura SQL Server para usar el certificado instalado.
 









# cadena de conexión SQL Server Management Studio 
```sql
Server=myServerAddress;Database=myDataBase;User Id=myUsername;Password=myPassword;Encrypt=True;TrustServerCertificate=True;
```

# CliperSuites
```sql
# TLS 1.3 
TLS_AES_256_GCM_SHA384

# TLS 1.2 
ECDHE-RSA-AES256-GCM-SHA384
```


# INFO TLS EN SQL SERVER

 **SSL** significa [**Secure Sockets Layer**] y **TLS** significa [**Transport Layer Security**]
Ambos son protocolos utilizados para asegurar la comunicación entre el cliente y el servidor mediante el cifrado de los datos transmitidos a través de la red.
SSL ha sido reemplazado por TLS debido a varias vulnerabilidades de seguridad encontradas en las versiones de SSL.  
   La última versión de SSL fue **SSL 3.0**, y la última versión de TLS es **TLS 1.3**.

## Versiones de TLS compatibles

| **VERSIONES DE SQL SERVER** | **Versión mínima de TLS** | **Versión máxima de TLS** |
|-----------------------------|---------------------------|---------------------------|
| SQL Server 2008 | TLS 1.0 | TLS 1.2 |
| SQL Server 2012 | TLS 1.0 | TLS 1.2 |
| SQL Server 2014 | TLS 1.0 | TLS 1.2 |
| SQL Server 2016 | TLS 1.0 | TLS 1.2 |
| SQL Server 2017 | TLS 1.0 | TLS 1.2 |
| SQL Server 2019 | TLS 1.1 | TLS 1.3 |
| SQL Server 2022 | TLS 1.1 | TLS 1.3 |


- **Nota:** En **Microsoft SQL Server (MSSQL)**, la configuración de **TLS/SSL** no está habilitada por defecto
- **Nota:** El soporte para TLS también depende del sistema operativo subyacente.
- **Nota:** El TLS 1.1 y 1.2 requieren Net Fremawork 4.6.2




# Pre-Implementación TLS
https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/certificate-requirements?view=sql-server-ver16

#### **1.1. Requisitos Previos**
- **Verificar compatibilidad del SO**: Asegúrese de que el sistema operativo soporte TLS 1.2 (Windows Server 2012 R2 o superior).
- **(Recomendable) Certificado SSL/TLS**: Obtenga un certificado válido de una Autoridad Certificadora (CA) confiable.
  - **Requisitos del certificado**:
    - Nombre común (CN) igual al nombre del servidor SQL (ej: `sqlserver.midominio.com`).
    - Uso mejorado de clave: **Autenticación de Servidor**.
    - Clave privada exportable (guardar backup).


**Verifica en REGEDIT TLS 1.2 y 1.3 habilitados**:
 - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols

**Verifica thumbprint en REGEDIT, el Certificate tipo REG_SZ tiene el thumbprint**: 
 - HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER2022\MSSQLServer\SuperSocketNetLib


# Implementación

```sql
Server Autentication 1.3.6.1.5.5.7.3.1. El OID es un valor numérico  (Key usage) que identifica el propósito de un certificado.   

	1. **Generar o Obtener Certificados**:
	   - MSSQL puede usar certificados autofirmados (generados automáticamente) o certificados emitidos por una **CA (Autoridad de Certificación)**.
	   - Para entornos productivos, se recomienda usar un certificado válido de una CA.
 
 
		**Crear certificados autofirmados especialmente para pruebas y desarrollo**
		1.- New-SelfSignedCertificate -CertStoreLocation = 'Cert:\LocalMachine\My' -FriendlyName "SQL Server Certifcate" -DnsName example_tls 
		https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/configure-sql-server-encryption?view=sql-server-ver16#sql-server-generated-self-signed-certificates
		https://learn.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2025-ps
 
 
	2. **Importar certificado de proveedor de manera manual certlm**:
	   - Abra `mmc.exe` > Agregar complemento **Certificados** > **Cuenta de equipo local**.
	   - En **Personal/Certificados**, importe el certificado (.pfx) con su clave privada.

		# Ejemplo de importación de certificado con powershell
			Import-PfxCertificate 
				-FilePath "C:\certificados\sqlserver.pfx" 
				-CertStoreLocation "Cert:\LocalMachine\My"
 

	3. **Asignar certificado a SQL Server**:
	   - Abra **SQL Server Configuration Manager**.
	   - En **Configuración de Red de SQL Server** > **Protocolos para [Instancia]** > **Certificado**.
	   - Seleccione el certificado instalado.


	4.-  Manage user certificates (certlm.msc o certmgr.msc) -> Personal -> CErtificates -> (Aqui debe aparecer el nombre de lenovo por ejemplo)


	5.-  **Asignar permisos a cuenta de servicio**
	Manage user certificates (certmgr) -> Personal -> CErtificates -> Lenovo -> (Click right) -> All Tasks -> Manage Private Keys -> add (Agregamos el usuario que levanta el servicio sql)

	
	6.- **Seleccionar certificado en sql server**
	Sql Server configuration Manager -> SQL Server Network Configuration -> Protocols for MSSQLSERVER -> (Click right) -> Click Properties -> Certificate -> (Select certificado "SQL Server Certifcate")


	7. **Forzar cifrado**:
	   - Sql Server configuration Manager -> SQL Server Network Configuration -> Protocols for MSSQLSERVER -> (Click right) -> Click Properties -> Flags -> Force Encryption -> YES 
	   - (Opcional) Sql Server configuration Manager -> SQL Server Network Configuration -> Protocols for MSSQLSERVER -> (Click right) -> Click Properties -> Flags -> Force Strict Encryption -> YES 
 
 
 
	8. **Reiniciar el Servicio**:
	   - Reinicia el servicio de SQL Server para aplicar los cambios.

 



``` 








# Post-Implementación

**Test de conexión cifrada con sql management studio**
8.- SQL management studio ->  additional connection parameters  -> (agregar) Encrypt=True


#### **3.3. Posibles Errores**
- **Error 1220**: Cliente no soporta TLS 1.2. Actualice el cliente.
- **Error 18456**: Fallo de autenticación si el certificado no está configurado correctamente.
- **Certificado no encontrado**: Asegúrese de que la cuenta de servicio de SQL tiene acceso a la clave privada.

 **VALIDAR ERRORES**
   - **EXEC sp_readerrorlog 0,1, 'cert';** --> tiene que aparece algo como "the certificarte [Cert Hash(SHA1) "asdasasd"] was succesfully loaded for encryption"


**Validar thumbprint**
```sql
EXEC xp_instance_regread 
		N'HKEY_LOCAL_MACHINE',
		N'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib'
```


**Verificar si las conexiones estan cifradas**
  ```sql
	SELECT  
		a.session_id
		,  a.client_net_address + ':'+ CAST(a.client_tcp_port AS varchar) as ip_client
		,a.connect_time
		,net_transport
		,protocol_type
		,encrypt_option
		,auth_scheme
		,b.login_name
		,b.status
		,b.original_login_name
		,host_name
		,program_name
	FROM sys.dm_exec_connections  as a
	LEFT JOIN sys.dm_exec_sessions as b on a.session_id = b.session_id 
	WHERE a.net_transport <> 'Shared memory'  
	order by encrypt_option;  -- Si `encrypt_option` muestra **TRUE**, TLS está activo.


	SELECT * FROM sys.certificates;
```

**Herramientas externas**:
  - **Wireshark**: Filtre con `tls.handshake.version == 0x0303` (TLS 1.2).
  - **OpenSSL**: 
    ```bash
		openssl s_client -connect 192.28.238.123:1433 -starttls mssql
    ```

**Consideraciones Importantes**
1. **Permisos del Certificado**:
   - Asegúrate de que la cuenta del servicio de SQL Server tenga acceso a la clave privada del certificado.
2. **Versiones de TLS**:
   - MSSQL depende del sistema operativo para las versiones de TLS soportadas. Por ejemplo, en Windows Server 2019, TLS 1.2 es el predeterminado.
3. **Clientes Externos**:
   - Los clientes deben confiar en el certificado del servidor (especialmente si es autofirmado).
 




# Mejores Prácticas
- Renovar certificados periódicamente
- Usar certificados de autoridad certificadora reconocida
- Implementar autenticación de doble factor
- Mantener actualizaciones de seguridad
- Configurar políticas de rotación de contraseñas




# Conceptos

**TDS 8.0 (Tabular Data Stream)** es un protocolo de comunicación utilizado por Microsoft SQL Server y Sybase para transferir datos entre el servidor de base de datos y el cliente. Este protocolo define cómo se envían las consultas SQL y los resultados entre el cliente y el servidor

**Características clave de TDS 8.0**:
1. **Cifrado obligatorio**: TDS 8.0 requiere que todas las conexiones estén cifradas utilizando TLS (Transport Layer Security). Esto significa que el protocolo TLS se negocia antes de cualquier mensaje TDS, asegurando que toda la comunicación esté protegida.
2. **Compatibilidad con TLS 1.3**: TDS 8.0 es compatible con TLS 1.3, así como con versiones anteriores como TLS 1.2.
3. **Conexiones estrictas**: SQL Server 2022 introdujo un tipo de cifrado de conexión adicional llamado "strict" (Encrypt=strict), que asegura que todas las conexiones utilicen TDS 8.0 y TLS.

 
**Diferencia principal entre "Force Encryption" y "Force Strict Encryption"**

1. **Force Encryption**:
   - **Propósito**: Obliga a que todas las conexiones al servidor SQL estén cifradas.
   - **Protocolos**: Utiliza los protocolos TLS disponibles y configurados en el servidor, que pueden incluir versiones más antiguas como TLS 1.0 y 1.1, además de TLS 1.2 y 1.3.
   - **Configuración**: Se puede habilitar en SQL Server Configuration Manager y requiere que el servidor tenga un certificado válido instalado.

2. **Force Strict Encryption**:
   - **Propósito**: Obliga a que todas las conexiones al servidor SQL estén cifradas utilizando únicamente los protocolos TLS más recientes y seguros.
   - **Protocolos**: Requiere el uso de TLS 1.2 o superior, asegurando que no se utilicen versiones más antiguas y menos seguras.
   - **Compatibilidad**: Introducido en SQL Server 2022, esta opción garantiza que todas las conexiones utilicen TDS 8.0 y TLS, proporcionando un nivel de seguridad más alto.



### Instlar el Thumbprint desde SQL Server 
```sql
	2. Configuración de Bindings
	-- Configurar puerto para TLS
	EXEC xp_instance_regwrite 
		N'HKEY_LOCAL_MACHINE', 
		N'Software\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQLServer\SuperSocketNetLib', 
		N'Certificate', 
		REG_SZ, 
		N'OID_del_Thumbprint_del_Certificado'
 ```


 
### BibliografÍas : 
```sql



# Configuración del Motor de base de datos de SQL Server para cifrar conexiones
    https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/configure-sql-server-encryption?view=sql-server-ver16#sql-server-generated-self-signed-certificates
    

# Requisitos de certificado para SQL Server
    https://learn.microsoft.com/es-es/sql/database-engine/configure-windows/certificate-requirements?view=sql-server-ver16



# Configuración del cliente para el cifrado
	https://learn.microsoft.com/en-us/sql/connect/jdbc/configuring-the-client-for-ssl-encryption?view=sql-server-ver16


# Conexión con cifrad
	https://learn.microsoft.com/es-es/sql/connect/jdbc/connecting-with-ssl-encryption?view=sql-server-ver16
	
	
# Características obsoletas del motor de base de datos en SQL Server 2016 (13.x)
	https://learn.microsoft.com/en-us/sql/database-engine/deprecated-database-engine-features-in-sql-server-2016?view=sql-server-ver16
	
	
# SQL Server 2016 y versiones anteriores utilizan el algoritmo SHA1, que ya no se considera seguro.
	https://support.microsoft.com/en-us/topic/kb4053407-fix-sql-server-2017-cannot-decrypt-data-encrypted-by-earlier-versions-of-sql-server-by-using-the-same-symmetric-key-a33f8bc7-e01a-55c6-72db-b851334df3dd
	

# Create and Install a Self-Signed SSL/TLS Certificate for SQL Server
	https://codekabinett.com/rdumps.php?Lang=2&targetDoc=create-install-ssl-tls-certificate-sql-server



https://4sysops.com/archives/enable-tls-on-sql-server/

https://bigdatansql.com/2020/08/30/certificate-based-server-logins-sql-server/

https://help.synergetic.net.au/s/article/kb-2297987775-sql-server-network-traffic-encryption-tls

https://www.youtube.com/watch?v=DAsN57lyVFg

https://www.youtube.com/watch?v=yHeA492MUBI


https://www.youtube.com/watch?v=wbT1i-0pru8&list=PLxuuX6jGq7kmqOCqYa1lFxQOKFgTfb8j8

https://learn.microsoft.com/es-es/troubleshoot/sql/database-engine/connect/tls-1-2-support-microsoft-sql-server
https://learn.microsoft.com/es-es/sql/relational-databases/security/networking/connect-with-tls-1-3?view=sql-server-ver16&source=recommendations
```

 
