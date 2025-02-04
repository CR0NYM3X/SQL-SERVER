
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
 
### BibliografÍas : 
```sql
https://learn.microsoft.com/es-es/troubleshoot/sql/database-engine/connect/tls-1-2-support-microsoft-sql-server
https://learn.microsoft.com/es-es/sql/relational-databases/security/networking/connect-with-tls-1-3?view=sql-server-ver16&source=recommendations
```

 
