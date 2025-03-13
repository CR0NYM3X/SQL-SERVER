Ver el estus de los servicios 
```
https://stackoverflow.com/questions/11682700/how-to-track-the-sql-services-in-ssms

EXEC xp_servicecontrol 'QUERYSTATE', 'SQLBrowser'
EXEC xp_servicecontrol 'QUERYSTATE', 'MSSQLServer'
  
SELECT * FROM sys.dm_server_services

---


EXEC master.sys.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\SQLBrowser',
N'Start' 

------------

DECLARE @RegistryPath NVARCHAR(255)
DECLARE @ValueName NVARCHAR(255)
DECLARE @Value INT

SET @RegistryPath = 'SYSTEM\CurrentControlSet\Services\SQLBrowser'
SET @ValueName = 'Start'

EXEC xp_instance_regread
    @rootkey = 'HKEY_LOCAL_MACHINE',
    @key = @RegistryPath,
    @value_name = @ValueName,
    @value = @Value OUTPUT

SELECT CASE @Value
    WHEN 2 THEN 'Automático'
    WHEN 3 THEN 'Manual'
    WHEN 4 THEN 'Deshabilitado'
    ELSE 'Desconocido'
END AS SQLBrowserStatus

```


**SQL server Agent**

¿Para qué sirve?
Puedes programar tareas para que se ejecuten automáticamente según una programación específica.
Permite automatizar tareas repetitivas y monitorear su éxito o fallo.

---

**SQL server (MSSQLSERVER)**
Este es el que levanta el servicio de la base de datos y te puedas conectar a ella 

---

**SQL server Integration Services**
¿Para qué sirve?
 SSIS  es una plataforma poderosa para implementar soluciones de Extracción, Transformación y Carga (ETL), como por ejemplo obtener 3 archivos con formatos con csv,xml, excel  y cargaro en una servidor sql server

---



**SQL server Full-text Filter deamon Laucher**
¿Para qué sirve?
Es esencial para usar la búsqueda de texto completo en SQL Server.

``FREETEXT``
Propósito: Busca palabras relacionadas y no solo coincidencias exactas. Es ideal para búsquedas “estilo Google”.


``CONTAINS``
Propósito: Busca palabras o frases específicas. Permite precisión y búsqueda exacta.



```
Permite la búsqueda de texto completo de manera automática. Registra eventos y notifica sobre fallas en tareas críticas.
 
Ejemplos de uso:  

-- Supongamos que deseas buscar todos los productos con un precio de $80.99 que contengan la palabra “Mountain”:
SELECT Name, ListPrice
FROM Production.Product
WHERE ListPrice = 80.99 AND CONTAINS(Name, 'Mountain');

-- Si buscas documentos que contengan palabras relacionadas con “vital safety components”:
SELECT Title
FROM Production.Document
WHERE FREETEXT(Document, 'vital safety components');

-- Para encontrar productos cuya descripción contenga la palabra “aluminum” cerca de “light” o “lightweight”:

SELECT FT_TBL.ProductDescriptionID, FT_TBL.Description, KEY_TBL.RANK
FROM Production.ProductDescription AS FT_TBL
INNER JOIN CONTAINSTABLE(Production.ProductDescription, Description,
    '(light NEAR aluminum) OR (lightweight NEAR aluminum)'
) AS KEY_TBL
ON FT_TBL.ProductDescriptionID = KEY_TBL.[KEY]
WHERE KEY_TBL.RANK > 2
ORDER BY KEY_TBL.RANK DESC;

-- Para obtener una clasificación superior y agregar la clasificación a la lista de selección
SELECT Title, KEY_TBL.RANK
FROM Production.Document
INNER JOIN FREETEXTTABLE(Production.Document, *, 'vital safety components') AS KEY_TBL
ON Production.Document.DocumentID = KEY_TBL.[KEY]
ORDER BY KEY_TBL.RANK DESC;


```
---

El **SQL Server Browser** simplifica la administración de **SQL Server**, especialmente cuando existen múltiples instancias de SQL Server en la mismo server. Aquí tienes más detalles sobre su función:

1. **Cuando está desactivado**:
   - Si desactivas el servicio SQL Server Browser, deberás asignar manualmente números de puerto a cada instancia de SQL Server. Esto puede ser un poco incómodo y propenso a errores.
   - Los clientes también deberán especificar explícitamente el número de puerto al conectarse a una instancia específica.

2. **Cuando está activado**:
   - El SQL Server Browser asigna dinámicamente puertos a las instancias de SQL Server. No necesitas configurar manualmente los números de puerto.
   - Los clientes pueden conectarse sin especificar el número de puerto, ya que el servicio les proporciona la información necesaria.
 
 si solo tienes una instancia de SQL Server, desactivar el servicio SQL Server Browser no causará problemas. Sin embargo, si tienes múltiples instancias, mantenerlo activado facilita la conexión y evita la necesidad de configurar puertos manualmente³. ¿Hay algo más en lo que pueda ayudarte? 😊

Sin embargo, ten en cuenta que si en el futuro agregas más instancias o necesitas utilizar el Dedicated Administrator Connection (DAC), es posible que debas activar el SQL Server Browser nuevamente.

--- 

**Sql Server Integration Services (SSIS)** <br>
**Sql Server analysis services (SSAS)** <br>

**Data quality services (DQS)**  <br>
**Master Data services** <br>
**Reporting services**
