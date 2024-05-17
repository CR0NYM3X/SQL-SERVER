
# parches y ciclos de vida

```SQL


CATÁLOGO DE PARCHES POSTGRESQL		https://www.postgresql.org/													
CATÁLOGO DE PARCHES MSSQL	 	https://www.catalog.update.microsoft.com/search.aspx?q=sql+server													
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



### Tipos de Actualización GDR, CU, OD
```SQL
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/servicing-models-sql-server

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


Tipos de CAL : 
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

```


### OTROS Enlaces 
```SQL
Using SQL Server in Windows
https://learn.microsoft.com/en-us/troubleshoot/sql/general/use-sql-server-in-windows

versiones : https://learn.microsoft.com/es-es/troubleshoot/sql/releases/sqlserver-2022/build-versions 

Herramientas para SQL Server
https://www.microsoft.com/es-mx/sql-server/developer-tools

Descargar SQL server:
https://www.microsoft.com/es-mx/sql-server/sql-server-downloads

Recomendaciones de seguridad
https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver16

Últimas actualizaciones e historial de versiones para SQL Server:
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/download-and-install-latest-updates

dónde encontrar información sobre las últimas compilaciones de SQL Server:
https://support.microsoft.com/es-es/topic/kb957826-d%C3%B3nde-encontrar-informaci%C3%B3n-sobre-las-%C3%BAltimas-compilaciones-de-sql-server-43994ba5-9aed-2323-ea7c-d29fe9c4fbe8

Controlador ODBC de Microsoft para SQL Server:
https://learn.microsoft.com/es-es/sql/connect/odbc/microsoft-odbc-driver-for-sql-server?view=sql-server-ver16
https://learn.microsoft.com/es-es/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver16
https://learn.microsoft.com/es-es/sql/connect/odbc/windows/release-notes-odbc-sql-server-windows?view=sql-server-ver16

Modelos de mantenimiento para SQL Server:
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/servicing-models-sql-server

Novedades a la lógica de detección de Microsoft Update para el mantenimiento de SQL Server:
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/new-mu-servicing-model

Determinar la versión y edición de Motor de base de datos de SQL Server que se está ejecutando
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/find-my-sql-version


Determinación de la información de versión de SQL Server componentes y herramientas de cliente:
https://learn.microsoft.com/es-es/troubleshoot/sql/releases/components-client-tools-versions

Características de SQL Server Native Client:
https://learn.microsoft.com/es-es/sql/relational-databases/native-client/features/sql-server-native-client-features?view=sql-server-ver15&viewFallbackFrom=sql-server-ver16

```







### CONFIGURACIONES DE SEGURIDAD
```SQL


Seguridad: 
https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver16

 https://reunir.unir.net/bitstream/handle/123456789/3619/ARMENDARIZ%20PEREZ%2C%20I%C3%91IGO.pdf?sequence=1&isAllowed=y
 https://www.coursesidekick.com/computer-science/4425647
 http://bibliotecadigital.econ.uba.ar/download/tpos/1502-0496_TiebasJ.pdf
 https://www.udb.edu.sv/udb_files/recursos_guias/informatica-ingenieria/base-de-datos-i/2019/i/guia-12.pdf
 https://www.sothis.tech/seguridad-en-microsoft-sql-server/


----------- ecnriptado ------------
cifrar los datos en reposo 
Cifrado de datos transparente (TDE)  - https://learn.microsoft.com/es-es/sql/relational-databases/security/encryption/transparent-data-encryption?view=sql-server-ver16#enable-tde

----------- NIVEL COLUMNA ------------
 Enmascaramiento dinámico de datos (DDM) 

------------ Protección en el nivel de fila ------------
Seguridad de nivel de fila (RLS)  -  https://learn.microsoft.com/es-es/sql/relational-databases/security/row-level-security?view=sql-server-ver16#Typical

------------ AUDITORIAS ------------
Informes y auditoría
https://learn.microsoft.com/es-es/sql/relational-databases/security/auditing/sql-server-audit-database-engine?view=sql-server-ver16

------------ Identidades y autenticación ------------
el modo de autenticación de Windows y el "modo de autenticación de SQL Server y Windows" (modo mixto).

------------ tablas temporales historicas ------------
 registros históricos de los cambios de datos a lo largo del tiempo puede ser beneficioso para abordar los cambios accidentales en los datos.
https://learn.microsoft.com/es-es/sql/relational-databases/tables/temporal-tables?view=sql-server-ver16

------------ Evaluación y herramientas de evaluación de seguridad ------------
Evaluación de vulnerabilidades de SQL Server 
habilite solo las características que necesita : https://learn.microsoft.com/es-es/sql/relational-databases/security/surface-area-configuration?view=sql-server-ver16

Clasificacion de datos sensibles : https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-data-discovery-and-classification?view=sql-server-ver16&tabs=t-sql

------------ Amenazas de SQL comunes ------------
Inyección de código SQL:   https://learn.microsoft.com/es-es/sql/relational-databases/security/sql-injection?view=sql-server-ver16
Inyección de código SQL:  Los desarrolladores y administradores de seguridad deben revisar todo el código que llama a EXECUTE, EXEC o sp_executesql, xp_: Procedimientos almacenados extendidos del catálogo, como xp_cmdshell 
Acceso por fuerza bruta: https://learn.microsoft.com/es-es/defender-for-identity/credential-access-alerts
Riesgos de contraseña :  contraseñas seguras complejas para todas sus cuentas.
Proteger SQL Server: https://learn.microsoft.com/es-es/sql/relational-databases/security/securing-sql-server?view=sql-server-ver16



```

