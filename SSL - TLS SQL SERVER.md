
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



### Extra info 
```sql
	2. Configuración de Bindings
	-- Configurar puerto para TLS
	EXEC xp_instance_regwrite 
		N'HKEY_LOCAL_MACHINE', 
		N'Software\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQLServer\SuperSocketNetLib', 
		N'Certificate', 
		REG_SZ, 
		N'Thumbprint_del_Certificado'
 ```


 
### BibliografÍas : 
```sql
https://4sysops.com/archives/enable-tls-on-sql-server/

https://bigdatansql.com/2020/08/30/certificate-based-server-logins-sql-server/

https://help.synergetic.net.au/s/article/kb-2297987775-sql-server-network-traffic-encryption-tls

https://www.youtube.com/watch?v=DAsN57lyVFg

https://www.youtube.com/watch?v=yHeA492MUBI


https://www.youtube.com/watch?v=wbT1i-0pru8&list=PLxuuX6jGq7kmqOCqYa1lFxQOKFgTfb8j8

https://learn.microsoft.com/es-es/troubleshoot/sql/database-engine/connect/tls-1-2-support-microsoft-sql-server
https://learn.microsoft.com/es-es/sql/relational-databases/security/networking/connect-with-tls-1-3?view=sql-server-ver16&source=recommendations
```

 
