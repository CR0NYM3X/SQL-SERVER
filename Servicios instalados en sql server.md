
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

**SQL Server Browser - Activado** <br>
es un servicio que se ejecuta como parte de SQL Server. Su función principal es escuchar las solicitudes entrantes de recursos de Microsoft SQL Server y proporcionar información sobre las instancias de SQL Server instaladas en el equipo. Algunas de sus funciones clave son:

Explorar servidores disponibles: Permite explorar una lista de los servidores disponibles en el equipo.
Conexión a la instancia correcta: Ayuda a conectarse a la instancia correcta del servidor SQL.
Conexión a los extremos de la conexión de administrador dedicada (DAC): Facilita la conexión a la instancia mediante el DAC, útil para tareas de administración avanzada.
Proporciona nombres e información de versión: Para cada instancia de Motor de base de datos y SSAS, el servicio SQL Server Browser proporciona el nombre de la instancia y el número de versión.

**SQL Server Browser - Desactivado** <br>
Si el SQL Server Browser está desactivado, podrías enfrentar los siguientes problemas:

Descubrimiento de instancias: Sin el SQL Server Browser, no podrás descubrir automáticamente las instancias de SQL Server en tu red. Esto significa que deberás especificar manualmente los nombres de las instancias al conectarte a ellas.
Conexiones a instancias específicas: Si tienes múltiples instancias de SQL Server en el mismo servidor, no podrás conectarte a una instancia específica sin conocer su nombre o puerto.
Administración del DAC: El Dedicated Administrator Connection (DAC) es un canal especial para tareas de administración. Sin el SQL Server Browser, no podrás conectarte al DAC de manera sencilla.
Actualizaciones y parches: Algunas actualizaciones o parches pueden requerir que el SQL Server Browser esté activado. Desactivarlo podría afectar la aplicación de estas actualizaciones

**SQL Server Browser - Observaciones**  <br> 
Si solo tienes una instancia de SQL Server, el hecho de que el SQL Server Browser esté desactivado no debería afectarte significativamente. Dado que no tienes múltiples instancias en el mismo servidor, no tendrás problemas para descubrir o conectarte a una instancia específica.

Sin embargo, ten en cuenta que si en el futuro agregas más instancias o necesitas utilizar el Dedicated Administrator Connection (DAC), es posible que debas activar el SQL Server Browser nuevamente.
