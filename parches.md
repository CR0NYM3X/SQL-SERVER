
# parches y ciclos de vida

```SQL


CATÁLOGO DE PARCHES POSTGRESQL		https://www.postgresql.org/													
CATÁLOGO DE PARCHES MSSQL	 	https://www.catalog.update.microsoft.com/search.aspx?q=sql+server |  https://learn.microsoft.com/es-es/troubleshoot/sql/releases/download-and-install-latest-updates 
CATÁLOGO DE PARCHES MONGODB	 	https://www.mongodb.com/docs/upcoming/release-notes/6.0/													
CATÁLOGO DE PARCHES DB2	 	https://www.ibm.com/support/pages/download-db2-fix-packs-version-db2-linux-unix-and-windows													
CATÁLOGO DE PARCHES MARIADB		https://mariadb.com/kb/en/release-notes/													
CATÁLOGO DE PARCHES VOLTDB	 	https://docs.voltdb.com/													
CATÁLOGO DE PARCHES ORACLE	 	https://support.oracle.com/knowledge/Oracle%20Database%20Products/742060_1.html													
CATÁLOGO DE PARCHES MYSQL		https://dev.mysql.com/doc/relnotes/													

LIFE CYCLES POSTGRESQL 		https://www.postgresql.org/support/versioning/													
LIFE CYCLES MSSQL		https://learn.microsoft.com/en-us/sql/sql-server/end-of-support/sql-server-end-of-support-overview?view=sql-server-ver16
LIFE CYCLES MSSQL	  https://learn.microsoft.com/es-es/lifecycle/products/?products=sql-server						
LIFE CYCLES MONGODB		https://www.mongodb.com/support-policy/lifecycles													
LIFE CYCLES DB2		https://www.ibm.com/support/pages/db2-distributed-end-support-eos-dates													
LIFE CYCLES MARIADB		https://mariadb.org/about/													
LIFE CYCLES VOLTDB		https://www.voltactivedata.com/company/customers/support/													
LIFE CYCLES ORACLE		https://www.oracle.com/us/assets/lifetime-support-technology-069183.pdf													
LIFE CYCLES MYSQL		https://endoflife.software/applications/databases/mysql

```

### La nomenclatura de las versiones de SQL Serve
```
Saber las licencias 
https://learn.microsoft.com/es-es/answers/questions/1458687/consulta-licencia-sql-server2019

Modelos de mantenimiento para SQL Server:
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/servicing-models-sql-server

nomenclatura y descripciones de área de corrección para los paquetes:
 https://learn.microsoft.com/es-es/troubleshoot/sql/releases/naming-schema-and-fix-area

 

-- aparecen todas las versiones:
https://sqlserverbuilds.blogspot.com/


versión del producto	   nivel del producto	       edición
14.0.2027.2             	RTM	                  Developer Edition (64 bits)

```


### Tipos de Actualización GDR, CU, OD
```SQL


Actualizaciones GDR (General Distribution Release):

Foco en Correcciones Críticas: Las actualizaciones GDR están diseñadas principalmente para proporcionar correcciones críticas de seguridad y estabilidad para SQL Server.
Conservadoras en Cambios: Tienden a ser más conservadoras en términos de cambios y nuevas características, centrándose en mantener la estabilidad y la seguridad del producto.
Menos Frecuentes: Por lo general, se lanzan con menos frecuencia que los CU y se centran en abordar problemas críticos específicos.
Recomendadas para Entornos de Producción Estables: Son una opción sólida para entornos de producción que valoran la estabilidad y prefieren evitar cambios significativos en el software.
Prioridad en Seguridad: Son esenciales para mantener la seguridad de la base de datos y mitigar los riesgos asociados con vulnerabilidades conocidas.


Cumulative Updates (CU):

Actualizaciones Acumulativas: Incluyen todas las correcciones y mejoras de versiones anteriores, así como nuevas correcciones y mejoras adicionales.
Amplia Gama de Correcciones y Mejoras: Pueden abordar una amplia variedad de problemas, incluidos errores críticos, mejoras de rendimiento y nuevas características.
Lanzamientos Periódicos: Se lanzan periódicamente y ofrecen una oportunidad para mantenerse al día con las últimas correcciones y mejoras disponibles.
Mayor Flexibilidad y Funcionalidad: Ofrecen una mayor flexibilidad y funcionalidad en comparación con las actualizaciones GDR, pero también pueden introducir cambios adicionales en el sistema.
Requieren Pruebas Rigurosas: Dado su alcance más amplio, es importante realizar pruebas rigurosas en un entorno de desarrollo antes de implementarlos en un entorno de producción.


Correcciones a petición (OD)
Contiene solicitudes de corrección críticas que cumplen todas estas condiciones:

No puede esperar a la versión de actualización acumulativa programada.
No hay ninguna solución alternativa o mitigación razonable.
El problema provoca un impacto significativo en la funcionalidad del producto o de la aplicación.


Service Pack (SP)
Los Service Pack ya no se publican para SQL Server 2017 y versiones posteriores. Cada service Pack nuevo contiene todas las correcciones que se encuentran en service packs anteriores,
No es necesario instalar un Service Pack anterior antes de instalar el Service Pack más reciente.


```



# Liciencia de MSSQL: 
```SQL

Bibliografía : https://licendi.com/es/blog/cal-y-el-sql-server-para-empresas-como-funcionan-cuantas-necesito-y-que-son-licencias-de-2-nucleos/
 
¿Qué significa CAL?  CAL (Client Access Licence)   para saber qué tipo de licencia debes comprar lo más importante es que tengas en cuenta la cantidad de dispositivos y usuarios que tiene la empresa para averiguar el número de licencias CAL necesitaras comprar. 

¿Qué modelo de SQL Server debería elegir para mi empresa?
para empresas PYME (pequeñas y medianas empresas) el modelo SQL Server CAL suele ser el producto que mejor se ajusta a tus necesidades, es económico y una herramienta que no tendrá problema gestionando la cantidad de datos que tendrás que almacenar y acceder. 

Si tu empresa ya es grande o prevés que vas a crecer de manera exponencial es más barato obtener una licencia por núcleo, debido a que le permite el acceso a tu servidor a un número infinito de usuarios.


Tipos de licencias : 
https://www.microsoft.com/es-xl/licensing/product-licensing/sql-server?activetab=sql-server-pivot%3aprimaryr2


CAL de usuario: Esto es una licencia para un usuario que podrá iniciar sesión en una multitud de distintos equipos con esa misma CAL
 
CAL de dispositivo: Esta CAL se une al dispositivo y permitirá a diferentes usuarios hacer uso de ella para acceder a las funcionalidades del SQL Server para empresas


2 Core? 
 Si suponemos que tienes un servidor físico con 6 núcleos y 3 procesadores puedes licenciar un total de 18 núcleos. Para tener todos tus procesadores cubiertos e incluidos en el SQL Server tendrás que comprar en total 9 licencias SQL Server 2cores, debido a que cada una viene con dos núcleos.
 
Si tu empresa es grande y tienes un número elevado de usuarios te recomendamos comprar la licencia SQL Server 2core, con el modelo CAL sería inviable y muy costoso si se tiene un gran número de usuarios.

SQL Server Enterprise
Es más adecuada para grandes empresas en parte debido a los recursos comerciales y financieros ,  Enterprise Edition no tiene límite en el tamaño de la memoria, de la base de datos ni en el número máximo de núcleos.

SQL Server Standard
ofrece características más básicas en cuanto a analíticas e informes. Esta versión de SQL Server está limitada en el tamaño de la memoria de la base de datos y el número máximo de núcleos. Esta versión es la más adecuada para pequeñas empresas.


Bibliografía : 
https://blog.revolutionsoft.net/diferencias-entre-licencias-sql-core-o-usuario/

SQL Core:

Ventajas
Escala horizontalmente: Ideal para organizaciones con grandes bases de datos y muchas transacciones, pues solo te preocuparás por el número de núcleos, no por el número de usuarios o dispositivos que acceden a la base de datos.
Sin límite de usuarios: Si tienes una aplicación con miles de usuarios, no tendrás que preocuparte por adquirir licencias adicionales a medida que tu base de usuarios crezca.
Parches y Actualizaciones: Al tener una licencia orientada a la capacidad de procesamiento del hardware, las actualizaciones suelen ser más intensivas en recursos y exigen un mantenimiento más riguroso para garantizar el rendimiento óptimo.

Desventajas
Coste inicial más alto: A menudo, especialmente para servidores potentes, el costo inicial de la licencia core puede ser considerablemente más alto que una licencia por usuario.



User CAL: 

Ventajas:
Costo predecible: Si conoces la cantidad de usuarios que tendrás, puedes calcular fácilmente cuántas licencias necesitarás y cuánto te costarán.
Ideal para PYMEs: Las empresas más pequeñas con un número fijo de usuarios pueden encontrar este modelo más económico.
Mantenimiento Simplificado: Al estar ligado al número de usuarios, las actualizaciones y parches suelen ser más sencillos y rápidos de implementar.

Desventajas:
Limitación de escala: A medida que tu empresa crezca y necesites más usuarios o dispositivos conectados, deberás comprar licencias adicionales.
Puede ser más caro a largo plazo: Si experimentas un crecimiento considerable en el número de usuarios o dispositivos, podrías terminar pagando más que con una licencia core.


Per Core : 
Por núcleo significa que necesita una licencia para cada núcleo de la máquina donde se ejecuta SQL Server, independientemente de cuántos usuarios acceden a SQL Server.




Bibliografía : https://softtrader.es/explicacion-sql-server-licencias-cal/
Bibliografía : https://redresscompliance.com/sql-server-2022-licensing-a-comprehensive-guide/#:~:text=With%20the%20Per%20Core%20model,of%20four%20licenses%20per%20VM.
Preguntas más frecuentes, términos y acrónimos usados : https://learn.microsoft.com/es-es/troubleshoot/sql/releases/faq-acronyms



Términos y acrónimos más utilizados
Actualización acumulativa (CU): una actualización acumulativa que contiene todas las revisiones críticas a petición anteriores disponibles hasta la fecha. Además, una CU contiene correcciones para los problemas que cumplen los criterios de aceptación de la revisión. Entre estos criterios cabe mencionar la disponibilidad de una solución, el efecto sobre el cliente, la reproducibilidad del problema, la complejidad del código que se debe cambiar y otros temas.

Revisión: un único paquete acumulativo que incluye uno o varios archivos que se usan para corregir un problema en un producto y son acumulativos tanto en el nivel binario como en el nivel de archivos. La revisión corrige una situación específica de un cliente y no se puede distribuir fuera de la organización del cliente.

RTM: por lo general significa "versión RTM" (del inglés Release to Manufacturing, entrega a fabricación). En el contexto de un producto como SQL Server, indica que no se han aplicado Service Pack ni revisiones al producto.

RTW: por lo general significa "versión RTW" (del inglés Release to Web, entrega en la Web). Hace referencia a un paquete que se ha publicado en web y se ha puesto a disposición de los clientes para su descarga.

Service pack: un conjunto acumulativo y probado de todas las revisiones, actualizaciones de seguridad, actualizaciones críticas y actualizaciones. Los Service Pack también pueden contener correcciones adicionales para problemas encontrados internamente desde el lanzamiento del producto, así como una cantidad limitada de características o cambios de diseño solicitados por el cliente.




```


### OTROS Enlaces 
```SQL
Determinar la versión y edición de Motor de base de datos de SQL Server que se está ejecutando
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/find-my-sql-version

Determinación de la información de versión de SQL Server componentes y herramientas de cliente:
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/components-client-tools-versions


Caracteristicas y diferencias entre Ediciones Enterprise,	Estándar,Web, Express:
https://learn.microsoft.com/es-es/sql/sql-server/editions-and-components-of-sql-server-2019?view=sql-server-ver16

Saber si el sql es compatible con la version de windows:
https://learn.microsoft.com/en-us/troubleshoot/sql/general/use-sql-server-in-windows

Te muestra todas las actualización acumulativa y sus caracteristicas  :
 https://learn.microsoft.com/es-es/troubleshoot/sql/releases/sqlserver-2022/build-versions

https://support.microsoft.com/es-es/topic/kb957826-d%C3%B3nde-encontrar-informaci%C3%B3n-sobre-las-%C3%BAltimas-compilaciones-de-sql-server-43994ba5-9aed-2323-ea7c-d29fe9c4fbe8




-- Descarga de ODBC 
https://learn.microsoft.com/es-es/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver16


---- versión de   ODBC
https://learn.microsoft.com/es-es/sql/connect/odbc/windows/release-notes-odbc-sql-server-windows?view=sql-server-ver16

---- Validar ODBC -> Compatibilidad con versiones de SQL Y Sistemas operativos admitidos
https://learn.microsoft.com/es-es/sql/connect/odbc/windows/system-requirements-installation-and-driver-files?view=sql-server-ver16
 



Características de SQL Server Native Client:
https://learn.microsoft.com/es-es/sql/relational-databases/native-client/features/sql-server-native-client-features?view=sql-server-ver15&viewFallbackFrom=sql-server-ver16


Descargar SQL server:
https://www.microsoft.com/es-mx/sql-server/sql-server-downloads

Herramientas para SQL Server
https://www.microsoft.com/es-mx/sql-server/developer-tools

connection modules or drivers para los  lenguajes de programacion :
https://learn.microsoft.com/en-us/sql/connect/sql-connection-libraries?view=sql-server-ver15


OLE DB :  permite el acceso a una variedad de fuentes de datos, no solo bases de datos relacionales, sino también a datos no relacionales como hojas de cálculo, archivos de texto y servicios web. 

Notas de versiones de OLE DBDescargar

https://learn.microsoft.com/es-es/sql/connect/oledb/release-notes-for-oledb-driver-for-sql-server?view=sql-server-ver15

Validar OLE DB -> Compatibilidad con versiones de SQL Y Sistemas operativos admitidos
https://learn.microsoft.com/es-es/sql/connect/oledb/applications/support-policies-for-oledb-driver-for-sql-server?view=sql-server-ver15

SQL Server Native Client:   ya no se actualiza ni se recomienda
está diseñado específicamente para SQL Server,  optimizado,  mejor rendimiento específicamente para SQL Server
combina tanto el proveedor Genericos como OLE DB y ODBC 
Permite acceder a características avanzadas específicas de SQL Server como la recuperación optimizada, tipos de datos específicos (por ejemplo, geometry, geography), soporte para XML y JSON
y SQL Native Client 11.0 que se instala en SQL Server 2012 a 2019 hasta que el SQL Server ciclo de vida de fin de soporte técnico respectivo
 
 Versiones de sistema operativo compatibles SQL Server Native Client
 https://learn.microsoft.com/es-es/sql/relational-databases/native-client/applications/support-policies-for-sql-server-native-client?view=sql-server-ver15#support-lifecycle-exception

Características de SQL Server Native Client
https://learn.microsoft.com/es-es/sql/relational-databases/native-client/features/sql-server-native-client-features?view=sql-server-ver15&viewFallbackFrom=sql-server-ver16


EXTRASSSSSS:
https://es.wikipedia.org/wiki/Microsoft_SQL_Server
```






