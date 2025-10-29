# Preguntas mas amistosas 
 

### 🧩 **Administración General**

1. **¿Qué versión de SQL Server has administrado más recientemente?**  
   SQL Server 2019, por su estabilidad y mejoras en rendimiento y seguridad.

2. **¿Sabes qué es una instancia nombrada?**  
   Sí, es una instalación de SQL Server con un nombre específico que permite tener varias instancias en el mismo servidor.

3. **¿Has trabajado con SQL Server Agent?**  
   Sí, lo uso para automatizar tareas como respaldos, mantenimiento y alertas.

4. **¿Conoces el propósito del archivo `tempdb`?**  
   Es una base de datos temporal que almacena objetos temporales y operaciones intermedias.

5. **¿Qué herramienta usas para monitorear el rendimiento?**  
   SQL Server Management Studio (SSMS), Extended Events y Performance Monitor.

6. **¿Has configurado el uso de memoria en SQL Server?**  
   Sí, ajustando los valores mínimo y máximo en las propiedades del servidor.

7. **¿Qué es el "Max Degree of Parallelism"?**  
   Es una configuración que limita cuántos núcleos puede usar una consulta paralela.

8. **¿Has usado el "Resource Governor"?**  
   Sí, para asignar recursos como CPU y memoria según el tipo de carga o usuario.

9. **¿Sabes cómo habilitar la autenticación mixta?**  
   Sí, desde las propiedades del servidor en SSMS, en la pestaña de seguridad.

10. **¿Has trabajado con SQL Server en entornos virtualizados?**  
    Sí, funciona bien si se asignan correctamente los recursos.
 

### ⚙️ **Optimización y Rendimiento**

11. **¿Has usado el "Execution Plan" para analizar consultas?**  
    Sí, ayuda a identificar cuellos de botella en el rendimiento.

12. **¿Qué tipo de índice mejora búsquedas por rangos?**  
    El índice `Clustered` o `B-Tree`.

13. **¿Sabes qué es la fragmentación de índices?**  
    Es cuando los datos del índice están desordenados, lo que afecta el rendimiento.

14. **¿Has usado el "Query Store"?**  
    Sí, guarda el historial de ejecución de consultas y ayuda a hacer tuning.

15. **¿Qué es un "deadlock"?**  
    Es un bloqueo mutuo entre dos procesos que esperan recursos del otro.

16. **¿Sabes cómo detectar bloqueos en SQL Server?**  
    Sí, con `sp_who2`, `sys.dm_exec_requests` y Extended Events.

17. **¿Has hecho tuning de procedimientos almacenados?**  
    Sí, optimizando el código y ajustando índices.

18. **¿Qué es el "Fill Factor"?**  
    Es el porcentaje de espacio libre que se deja en cada página de índice.

19. **¿Has optimizado consultas con millones de registros?**  
    Sí, usando índices adecuados, particiones y filtros eficientes.

20. **¿Sabes cómo evitar funciones escalar en SELECT?**  
    Sí, evitando usarlas en columnas del SELECT para no afectar el uso de índices.
 

### 🔐 **Seguridad y Control de Acceso**

21. **¿Has implementado roles personalizados?**  
    Sí, para asignar permisos específicos según el tipo de usuario.

22. **¿Sabes qué es TDE (Transparent Data Encryption)?**  
    Es una forma de cifrar los datos en reposo para proteger los archivos físicos.

23. **¿Has usado "SQL Server Audit"?**  
    Sí, para registrar eventos como accesos, cambios y ejecuciones.

24. **¿Conoces el concepto de "Always Encrypted"?**  
    Sí, cifra datos sensibles incluso en memoria y durante la transmisión.

25. **¿Has configurado permisos por esquema?**  
    Sí, para controlar el acceso a objetos dentro de cada esquema.

26. **¿Sabes cómo auditar accesos a la base de datos?**  
    Sí, con SQL Server Audit o triggers personalizados.

27. **¿Has trabajado con políticas de seguridad?**  
    Sí, definiendo reglas de acceso, cifrado y respaldo.

28. **¿Has implementado cifrado de datos sensibles?**  
    Sí, usando funciones como `EncryptByKey` o `Always Encrypted`.

29. **¿Sabes cómo proteger una base de datos expuesta a internet?**  
    Sí, con firewalls, cifrado, roles mínimos y monitoreo constante.

30. **¿Has trabajado con login triggers?**  
    Sí, para validar condiciones como IP, horario o tipo de usuario al iniciar sesión.
 

### 💾 **Respaldos y Recuperación**

31. **¿Has configurado respaldos automáticos?**  
    Sí, con SQL Server Agent o scripts programados.

32. **¿Sabes qué es un respaldo diferencial?**  
    Guarda solo los cambios desde el último respaldo completo.

33. **¿Has restaurado una base de datos a un punto específico?**  
    Sí, usando el log de transacciones.

34. **¿Conoces el modelo de recuperación "Full"?**  
    Sí, permite respaldos completos y restauraciones precisas.

35. **¿Has usado "Tail-Log Backup"?**  
    Sí, para respaldar el log antes de restaurar una base dañada.

36. **¿Sabes cómo validar un respaldo?**  
    Sí, con `RESTORE VERIFYONLY` o restaurando en un entorno de prueba.

37. **¿Has hecho pruebas de recuperación ante desastres?**  
    Sí, simulando fallos y validando los respaldos.

38. **¿Has usado compresión de respaldos?**  
    Sí, para reducir el tamaño y acelerar el proceso.

39. **¿Sabes qué es un "Page Restore"?**  
    Es una restauración de páginas específicas dañadas.

40. **¿Has definido políticas de retención de respaldos?**  
    Sí, estableciendo tiempos de conservación y ubicación segura.
 

### 🔄 **Migraciones y Actualizaciones**

41. **¿Has migrado bases de datos entre versiones de SQL Server?**  
    Sí, usando respaldos, restauraciones o herramientas como DMA.

42. **¿Has migrado desde Sybase a SQL Server?**  
    Sí, con ODBC, scripts y herramientas como SSIS.

43. **¿Conoces la herramienta "Data Migration Assistant"?**  
    Sí, evalúa compatibilidad y ayuda a migrar objetos.

44. **¿Has usado "SQL Server Data Tools (SSDT)"?**  
    Sí, para desarrollar y versionar bases de datos desde Visual Studio.

45. **¿Sabes cómo actualizar una base sin afectar la operación?**  
    Sí, usando replicación, mantenimiento por etapas o ventanas de mantenimiento.

46. **¿Has documentado procesos de migración?**  
    Sí, detallando pasos, riesgos, tiempos y responsables.

47. **¿Has trabajado con esquemas de compatibilidad?**  
    Sí, ajustando el nivel para evitar errores con funciones nuevas.

48. **¿Sabes por qué evitar "Shrink Database"?**  
    Porque causa fragmentación y pérdida de rendimiento.

49. **¿Has hecho mantenimiento preventivo con DBCC CHECKDB?**  
    Sí, para verificar la integridad de la base de datos.

50. **¿Has gestionado cambios estructurales en producción?**  
    Sí, con pruebas previas, control de versiones y comunicación al equipo.

 

# Pregunta agresivas 

 

### 🧠 **Administración y Configuración de SQL Server**

1. **¿Cómo se configura una instancia de SQL Server para alta disponibilidad?**  
   Se puede usar *Failover Clustering*, *Always On Availability Groups* o *Log Shipping*, dependiendo del nivel de disponibilidad requerido.

2. **¿Qué diferencias hay entre una instancia nombrada y una instancia predeterminada?**  
   La instancia predeterminada no requiere nombre al conectarse; la nombrada sí, y permite múltiples instancias en un mismo servidor.

3. **¿Cómo se realiza el monitoreo de recursos en SQL Server?**  
   Con herramientas como *Performance Monitor*, *Extended Events*, *SQL Profiler* y vistas dinámicas (`DMVs`).

4. **¿Qué es el SQL Server Agent y cómo lo configuras para tareas programadas?**  
   Es un servicio que permite automatizar tareas como respaldos o mantenimiento. Se configura desde SSMS creando *jobs* y *schedules*.

5. **¿Cómo se configura el uso de memoria en SQL Server para evitar sobreconsumo?**  
   En las propiedades del servidor, se ajustan los valores de memoria mínima y máxima para evitar que SQL Server consuma toda la RAM.

6. **¿Qué es el "Max Degree of Parallelism" y cuándo lo ajustarías?**  
   Es el número máximo de núcleos que puede usar una consulta paralela. Se ajusta para evitar sobrecarga en servidores con muchas CPUs.

7. **¿Cómo se realiza el balanceo de carga entre múltiples servidores SQL Server?**  
   Se puede usar *replicación*, *particionamiento horizontal*, *Always On* con *read-only replicas*, o soluciones externas como *Application Request Routing*.

8. **¿Qué es el "Resource Governor" y cómo lo usarías?**  
   Es una herramienta para limitar el uso de CPU y memoria por grupos de usuarios o cargas de trabajo. Se configura con *resource pools* y *workload groups*.

9. **¿Cómo se configura la autenticación mixta en SQL Server?**  
   En las propiedades del servidor, se habilita la opción de *Autenticación de Windows y SQL Server*.

10. **¿Qué consideraciones tomarías al instalar SQL Server en un entorno productivo?**  
    Definir requisitos de hardware, separar discos para logs y datos, configurar seguridad, respaldos, alta disponibilidad y monitoreo.



### 🔧 **Optimización y Tuning**

11. **¿Cómo identificas una consulta lenta en SQL Server?**  
    Usando el *Execution Plan*, *Query Store*, *DMVs* y herramientas como *SQL Profiler*.

12. **¿Qué herramientas usas para hacer tuning de consultas?**  
    *Execution Plan*, *Query Store*, *Database Engine Tuning Advisor*, *DMVs* y *Extended Events*, sentryone plan explorer, sql querystrees

13. **¿Qué tipos de índices existen en SQL Server y cuándo usarías cada uno?**  
    *Clustered* para ordenar físicamente los datos, *Non-Clustered* para búsquedas rápidas, *Full-Text* para texto libre, *Columnstore* para grandes volúmenes.

14. **¿Qué es un "Execution Plan" y cómo lo interpretas?**  
    Es un mapa de cómo SQL Server ejecuta una consulta. Se analiza para detectar operaciones costosas y mejorar el rendimiento.

15. **¿Cómo afecta el uso de funciones escalar en el rendimiento de una consulta?**  
    Impide el uso de índices y puede hacer que la consulta se ejecute fila por fila, reduciendo el rendimiento.

16. **¿Qué es el "Query Store" y cómo lo utilizas?**  
    Es una herramienta que guarda el historial de ejecución de consultas. Se usa para comparar planes y detectar regresiones de rendimiento.

17. **¿Cómo optimizarías una base de datos con millones de registros?**  
    Usando particiones, índices adecuados, evitando operaciones innecesarias y aplicando filtros eficientes.

18. **¿Qué es el "Fill Factor" y cómo influye en el rendimiento?**  
    Es el porcentaje de espacio libre en cada página de índice. Un valor bajo reduce la fragmentación pero aumenta el tamaño.

19. **¿Cómo se detectan bloqueos y deadlocks en SQL Server?**  
    Con *Extended Events*, *SQL Profiler*, vistas como `sys.dm_tran_locks` y el gráfico de bloqueo.

20. **¿Qué es el "Index Fragmentation" y cómo lo solucionas?**  
    Es el desorden en las páginas de índice. Se soluciona con *REORGANIZE* o *REBUILD* según el nivel de fragmentación.




### 🛡️ **Seguridad y Disponibilidad**

21. **¿Cómo implementas roles y permisos en SQL Server?**  
    Creando roles personalizados y asignando permisos mínimos necesarios a cada usuario o grupo.

22. **¿Qué es Transparent Data Encryption (TDE)?**  
    Es una técnica para cifrar los archivos físicos de la base de datos sin modificar las aplicaciones.

23. **¿Cómo se auditan accesos y cambios en SQL Server?**  
    Con *SQL Server Audit*, triggers personalizados o herramientas externas de monitoreo.

24. **¿Qué es el "SQL Server Audit" y cómo se configura?**  
    Es una funcionalidad que registra eventos como accesos, cambios y ejecuciones. Se configura desde SSMS o con T-SQL.

25. **¿Cómo se protege una base de datos expuesta a internet?**  
    Con firewalls, cifrado, roles mínimos, autenticación segura y monitoreo constante.

26. **¿Qué es el "Always Encrypted" y cuándo lo usarías?**  
    Es una técnica para cifrar datos sensibles que ni el servidor puede ver. Se usa en datos como tarjetas o contraseñas.

27. **¿Cómo se configura un "Login Trigger" para controlar accesos?**  
    Se crea un trigger en el evento `LOGON` para validar condiciones como IP, horario o tipo de usuario.

28. **¿Qué medidas tomarías para garantizar la disponibilidad de los datos?**  
    Implementar respaldos, alta disponibilidad, monitoreo, replicación y pruebas de recuperación.

29. **¿Cómo se configura un "Failover Cluster" en SQL Server?**  
    Usando Windows Server Failover Clustering (WSFC) y una instancia de SQL Server configurada para alta disponibilidad.

30. **¿Qué es el "Log Shipping" y cómo se implementa?**  
    Es una técnica de respaldo y restauración automática entre servidores. Se configura desde SSMS con respaldos del log de transacciones.



### 💾 **Respaldos y Recuperación**

31. **¿Qué tipos de respaldos existen en SQL Server?**  
    *Completo*, *diferencial*, *log de transacciones*, *copias de seguridad parciales* y *de archivos/páginas*.

32. **¿Cómo se realiza una restauración punto en el tiempo?**  
    Restaurando el respaldo completo, luego el diferencial (si existe) y finalmente los logs hasta el punto deseado.

33. **¿Qué es el "Recovery Model" y cómo afecta los respaldos?**  
    Define cómo se manejan los logs. *Full* permite restauraciones precisas, *Simple* no guarda logs, *Bulk-Logged* es intermedio.

34. **¿Cómo automatizarías los respaldos diarios?**  
    Con *SQL Server Agent*, creando jobs programados con scripts de respaldo.

35. **¿Qué es el "Backup Compression" y cuándo lo usarías?**  
    Es una opción para reducir el tamaño del respaldo. Se usa cuando hay poco espacio o se necesita rapidez.

36. **¿Cómo validarías la integridad de un respaldo?**  
    Con `RESTORE VERIFYONLY` o restaurando en un entorno de prueba.

37. **¿Qué es el "Tail-Log Backup" y cuándo se usa?**  
    Es un respaldo del log antes de restaurar una base dañada. Se usa para evitar pérdida de datos recientes.

38. **¿Cómo se configura una política de retención de respaldos?**  
    Definiendo tiempos de conservación, ubicación segura y automatización de limpieza.

39. **¿Qué es el "Page Restore" y en qué casos se aplica?**  
    Es una restauración de páginas específicas dañadas. Se usa en corrupción parcial.

40. **¿Cómo se realiza una prueba de recuperación ante desastres?**  
    Simulando fallos, restaurando respaldos y validando que todo funcione correctamente.



### 🔄 **Migraciones y Mantenimiento**

41. **¿Cómo migrarías una base de datos de Sybase a SQL Server?**  
    Usando ODBC, scripts de exportación/importación, SSIS o herramientas de terceros.

42. **¿Qué herramientas usarías para migrar entre versiones de SQL Server?**  
    *Data Migration Assistant (DMA)*, *SSMS*, *SSIS* y respaldos/restauraciones.

43. **¿Cómo se realiza el mantenimiento preventivo de una base de datos?**  
    Ejecutando tareas como *DBCC CHECKDB*, reorganización de índices, actualización de estadísticas y limpieza de logs.

44. **¿Qué es el "DBCC CHECKDB" y cada cuánto lo ejecutarías?**  
    Verifica la integridad de la base de datos. Se recomienda ejecutarlo semanalmente o según el entorno.

45. **¿Cómo se actualiza una base de datos sin afectar la operación?**  
    Usando replicación, mantenimiento por etapas, ventanas de mantenimiento y pruebas previas.

46. **¿Qué consideraciones tomarías al migrar una base de datos crítica?**  
    Validar compatibilidad, respaldar, probar en entorno de staging, documentar y tener plan de reversión.

47. **¿Cómo se realiza una limpieza de datos obsoletos sin afectar el rendimiento?**  
    Usando procesos por lotes, índices adecuados, particiones y validaciones previas.

48. **¿Qué es el "Shrink Database" y por qué se recomienda evitarlo?**  
    Reduce el tamaño físico de la base, pero causa fragmentación. Se recomienda solo en casos específicos.

49. **¿Cómo se documenta una migración correctamente?**  
    Detallando pasos, tiempos, responsables, riesgos, pruebas y resultados.

50. **¿Qué es el "SQL Server Data Tools (SSDT)" y cómo lo usas en migraciones?**  
    Es una herramienta para desarrollar, versionar y desplegar bases de datos desde Visual Studio.
