# Revisar Consumo de memoria 
Vista dinámica que te da información detallada sobre cómo el motor está usando la memoria internamente.

```sql
SELECT
	type, --  Nombre del componente
	SUM(pages_kb) AS total_memory_kb --  Memoria usada en KB por páginas.
FROM sys.dm_os_memory_clerks
GROUP BY type
ORDER BY total_memory_kb DESC;

```

### ✅ **¿Qué información crucial puedes obtener?**

Cada fila en `sys.dm_os_memory_clerks` representa un tipo de memoria usada por un componente. Las columnas más importantes:

*   **`type`** → Nombre del componente (ej. `CACHESTORE_SQLCP`, `CACHESTORE_OBJCP`, `MEMORYCLERK_SQLBUFFERPOOL`).
*   **`pages_kb`** → Memoria usada en KB por páginas.
*   **`virtual_memory_committed_kb`** → Memoria virtual comprometida.
*   **`awe_allocated_kb`** → Memoria asignada con AWE (en versiones antiguas).
*   **`memory_node_id`** → Nodo NUMA al que pertenece.

### ✅ **¿Qué puedes analizar con esto?**

*   **Buffer Pool**: `MEMORYCLERK_SQLBUFFERPOOL` → indica cuánto ocupa el cache de datos.
*   **Plan Cache**:
    *   `CACHESTORE_SQLCP` → planes ad-hoc.
    *   `CACHESTORE_OBJCP` → planes compilados (procedimientos).
*   **Lock Manager**: `MEMORYCLERK_LOCK_MANAGER` → memoria usada para bloqueos.
*   **Query Execution**: `MEMORYCLERK_SQLQUERYEXECUTOR` → memoria para ejecución de consultas.
 
### ✅ **Casos prácticos donde es útil**

*   Diagnóstico de **falta de memoria**.
*   Identificar **plan cache inflado** (ej. demasiados planes ad-hoc).
*   Ver si el **Buffer Pool** está usando la memoria esperada.
*   Analizar impacto de **NUMA** en asignación de memoria.
 
---




## Problemas de Contención es en TempDB  
Si necesitas más archivos de TempDB en SQL Server, normalmente se analiza la contención en las asignaciones de páginas (PFS, GAM, SGAM) y los esperas en tempdb. Esto se detecta revisando los wait

Si confirma que existe una alta contención de tipo PAGELATCH_UP o PAGELATCH_EX relacionada con las páginas de asignación de tempdb, incremente a 12 archivos.






```sql

-- Introducido en SQL Server 2019 Su objetivo es reducir la contención en las tablas de sistema de TempDB
-- cuando hay muchas operaciones concurrentes que crean y eliminan objetos temporales (#temp tables, variables de tabla, etc.).
-- En lugar de usar páginas en disco para el metadata, se usan tablas optimizadas para memoria (In-Memory OLTP), eliminando bloqueos tipo PAGELATCH_xx en TempDB.
SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');


-- Ver contención en tempdb
SELECT
    session_id,
    CASE 
        WHEN wait_type IS NULL THEN last_wait_type
        ELSE wait_type
    END AS wait_type_final,
FROM sys.dm_exec_requests
WHERE  database_id = 2 -- tempdb  
AND (wait_type LIKE 'PAGELATCH%' OR last_wait_type LIKE 'PAGELATCH%');

-- Ejecute la siguiente consulta para identificar los tipos de espera dominantes en su instancia.
-- Si PAGELATCH_UP o PAGELATCH_EX aparece consistentemente en su lista de Top 5 esperas con un alto tiempo de espera acumulado (wait_time_ms), es una fuerte indicación de contención.
SELECT
    wait_type,
    wait_time_ms,
    waiting_tasks_count,
    CAST(wait_time_ms * 1.0 / waiting_tasks_count AS NUMERIC(10, 2)) AS avg_wait_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
    AND waiting_tasks_count > 0
ORDER BY wait_time_ms DESC;


SELECT
    -- Identificación de la Tarea y Sesión
    wt.session_id,
    wt.wait_duration_ms,
    wt.wait_type,

    -- Recurso de Contención
    wt.resource_description,

    -- Información del Proceso Bloqueado/Esperando
    s.host_name,
    s.program_name,
    s.login_name,
    t.text AS TSQL_en_espera,
    p.query_plan AS Plan_de_ejecucion

FROM sys.dm_os_waiting_tasks AS wt
INNER JOIN sys.dm_exec_sessions AS s
    ON wt.session_id = s.session_id
INNER JOIN sys.dm_exec_requests AS r
    ON wt.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS p

-- Filtro principal: Busca esperas relacionadas con pestillos de página (page latches)
-- Esto incluye PAGELATCH_UP, PAGELATCH_EX, etc.
WHERE wt.wait_type LIKE 'PAGELATCH%'
-- Filtro secundario opcional: Asegura que solo buscamos en tempdb (Database ID = 2)
-- La descripción del recurso tiene el formato: 2:1:1 (DatabaseID:FileID:PageID)
AND wt.resource_description LIKE '2:%'
AND s.is_user_process = 1 -- Excluye procesos internos del sistema
ORDER BY wt.wait_duration_ms DESC;

```

# Hacer todos los archivos de la TempDB del mismo tamaño

### ✅ **Ventaja de tener todos los archivos del mismo tamaño**

*   **Balanceo uniforme**: SQL Server usa un algoritmo de asignación proporcional (Proportional Fill). Si los archivos tienen tamaños diferentes, el motor asigna más páginas a los archivos más grandes, causando que algunos archivos trabajen más que otros.
*   **Reduce contención**: Al distribuir las escrituras de manera equitativa entre los archivos, se disminuye la contención en páginas PFS, GAM y SGAM.
*   **Mejor rendimiento en entornos concurrentes**: Especialmente en sistemas con alta carga de operaciones temporales (ordenamientos, tablas temporales, etc.).
 

 
```sql
use tempdb
SELECT name, physical_name, size*8/1024 AS SizeMB,*
FROM sys.database_files;
```

#  **¿Cuándo se dispara un wait?**

*   Los waits son indicadores clave de **cuellos de botella**.
*   Analizar los waits ayuda a saber si el problema está en **CPU, memoria, disco, red o bloqueos**.

Un wait se dispara cuando:

1.  **Un recurso está ocupado o bloqueado**
    *   Ejemplo: Espera por un **latch**, **lock**, o acceso a disco.
2.  **Hay contención en memoria o CPU**
    *   Ejemplo: Espera por memoria para ejecutar un plan.
3.  **Operaciones externas tardan en responder**
    *   Ejemplo: Espera por I/O en disco, red, o tempdb.
4.  **Sincronización interna**
    *   Ejemplo: Espera por un hilo paralelo en un plan de ejecución.

 
### 🔍 **Tipos comunes de waits**

*   **PAGEIOLATCH\_**\* → Espera por lectura/escritura en disco.
*   **CXPACKET / CXCONSUMER** → Espera por sincronización en consultas paralelas.
*   **ASYNC\_NETWORK\_IO** → Espera porque el cliente no consume datos rápido.
*   **RESOURCE\_SEMAPHORE** → Espera por memoria para ejecutar el plan.
*   **WRITELOG** → Espera por escritura en el log de transacciones.

 
### ✅ **Cómo ver los waits activos**

```sql
SELECT 
    wait_type, 
    waiting_tasks_count, 
    wait_time_ms, 
    max_wait_time_ms, 
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC;
```


---



# ✅ **Trace Flag 174**
[Link oficial](https://support.microsoft.com/es-es/topic/kb3026083-correcci%C3%B3n-sos-cachestore-contenci%C3%B3n-de-bloqueo-en-la-cach%C3%A9-de-planes-sql-server-ad-hoc-provoca-un-uso-elevado-de-la-cpu-en-sql-server-798ca4a5-3813-a3d2-f9c4-89eb1128fe68)
<br>**Propósito:**  
Aumenta el número de **buckets en el plan cache** para reducir la contención en el spinlock `SOS_CACHESTORE` cuando hay muchas consultas ad hoc. Por defecto, en sistemas 64-bit hay 40,009 buckets; con este flag se incrementa a 160,001. [\[sqlservice.se\]](https://www.sqlservice.se/sql-server-trace-flag-174/) 

### **Beneficios**

*   Reduce la contención en el plan cache en entornos con **altísimo volumen de consultas ad hoc**.
*   Disminuye el uso excesivo de CPU causado por spinlocks.
*   Mejora la escalabilidad en servidores mega transaccionales.

### **Consideraciones**

*   Solo aplica en versiones **SQL Server 2012–2017** (en 2019+ el comportamiento puede variar).
*   Requiere habilitarlo como **startup parameter (-T174)** y tener ciertos Cumulative Updates instalados.
*   Verifica el tamaño actual con:
    ```sql
    SELECT name, buckets_count FROM sys.dm_os_memory_cache_hash_tables WHERE name IN ('SQL Plans','Object Plans','Bound Trees');

 	select name, type, pages_kb, entries_count from sys.dm_os_memory_cache_counters where name IN ( 'SQL Plans' , 'Object Plans' ,  'Bound Trees' );
    ```

### **Desventajas**

*   Incrementar buckets aumenta el consumo de memoria para el plan cache.
*   Si tu carga no tiene muchas consultas ad hoc, no aporta beneficio y solo consume más memoria.

### **Si NO está habilitado**

*   En cargas con muchas consultas ad hoc, puedes sufrir:
    *   Alta contención en `SOS_CACHESTORE`.
    *   Elevado uso de CPU.
    *   Degradación general del rendimiento. 

### 🔍 **Recomendaciones para entornos críticos**

*   **174:** Actívalo solo si tu workload tiene miles de consultas ad hoc y notas contención en spinlocks.
*   **Siempre prueba en QA antes de producción** y monitorea impacto en CPU y memoria.
 
### **Ejemplo práctico de contención  en SQL Server**

*   El **plan cache** es una estructura compartida donde se almacenan los planes de ejecución.
*   Cuando miles de consultas intentan leer/escribir en esa estructura al mismo tiempo, se usan mecanismos como **spinlocks** para controlar el acceso.
*   Si hay pocos “buckets” (espacios de hash), muchos hilos intentan entrar al mismo bucket → **alta contención** → más espera → más CPU consumida.

### **Impacto**

*   Incremento en el tiempo de respuesta.
*   Uso excesivo de CPU por hilos que giran esperando (spinlocks).
*   Degradación del rendimiento general.

### **Cómo lo mitiga el Trace Flag 174**

*   Aumenta el número de buckets en el plan cache, reduciendo la probabilidad de que dos hilos compitan por el mismo bucket.
*   Menos contención → mejor escalabilidad en entornos con muchísimas consultas ad hoc.

---


# **low page life expectancy **
- [Ref1](https://www.sqlskills.com/blogs/paul/page-life-expectancy-isnt-what-you-think/)
- [Ref2](https://axial-sql.com/es/comprendiendo-la-esperanza-de-vida-de-las-paginas-en-sql-server-3/)
 

El PLE mide cuántos segundos, en promedio, las páginas permanecen en el buffer pool antes de ser reemplazadas. Un valor bajo significa que hay presión de memoria.

### ✅ ¿Regla?
    *   **PLE recomendado**: mínimo **300 segundos por cada 4 GB de RAM** (regla general).


### ✅ **Por qué es malo**

1.  **Más lecturas desde disco**
    *   Si las páginas no permanecen en memoria el tiempo suficiente, SQL Server debe leerlas repetidamente desde el disco.
    *   El disco (incluso SSD) es miles de veces más lento que la memoria RAM.

2.  **Aumento de latencia en consultas**
    *   Consultas que podrían resolverse desde memoria ahora esperan I/O físico.
    *   Esto impacta directamente el tiempo de respuesta en entornos críticos.

3.  **Mayor presión en subsistema de I/O**
    *   Incrementa la carga en el almacenamiento, lo que puede saturar SAN/NAS o discos locales.
    *   Puede generar colas de espera (`PAGEIOLATCH_*` en `sys.dm_exec_requests`).

4.  **Impacto en CPU**
    *   Más operaciones para gestionar lecturas y escrituras.
    *   Si hay contención, el motor puede gastar ciclos en spinlocks y gestión de memoria.

5.  **Efecto cascada en todo el servidor**
    *   Backups, mantenimiento y consultas pesadas expulsan páginas, afectando otras consultas.
    *   En sistemas mega transaccionales, esto puede provocar bloqueos y timeouts.

 


### 🔍 **Causas comunes de PLE bajo**

1.  **Falta de memoria**: El buffer pool no tiene suficiente RAM para la carga.
2.  **Consultas que hacen grandes lecturas**: Escaneos masivos que expulsan páginas del buffer.
3.  **Planes de ejecución ineficientes**: Falta de índices, uso excesivo de `TABLE SCAN`.
4.  **Mantenimiento intensivo**: Rebuilds de índices o backups que leen grandes volúmenes.
5.  **Configuración incorrecta**: `max server memory` demasiado bajo.
6. - Mantenimiento de Índices
7. - Consultas Grandes
8. - Actividad de Migración de Datos
9. - Planes de Ejecución Múltiples: Tener múltiples planes de ejecución para un solo procedimiento puede afectar PLE.

 
### ✅ **Acciones para mejorar PLE**

*   **Aumentar memoria** (si es posible).
*   **Optimizar consultas**: Crear índices adecuados, evitar escaneos innecesarios.
*   **Revisar mantenimiento**: Programar rebuilds fuera de horas pico.
*   **Configurar `max server memory`** correctamente para evitar presión por otros procesos.
*   **Evita operaciones masivas en horas pico** (rebuilds, backups).
*   **Habilitar Resource Governor** si hay cargas descontroladas.


 


### ✅ **Cómo investigar**

*   **Ver memoria asignada y usada**:
    ```sql
    SELECT total_physical_memory_kb/1024 AS TotalRAM_MB,
           available_physical_memory_kb/1024 AS AvailableRAM_MB,
           system_memory_state_desc
    FROM sys.dm_os_sys_memory;
    ```
*   **Ver PLE actual y por nodo**:
    ```sql
    SELECT [object_name], [instance_name], [cntr_value]
		FROM sys.dm_os_performance_counters
    WHERE [counter_name] = 'Page life expectancy';
    ```

*   **Ejemplo de Resultado:**
    *   `object_name`:
        *   `SQLServer:Buffer Manager` → PLE global.
        *   `SQLServer:Buffer Node` → PLE por nodo NUMA (en tu caso, instancia `000`).
    *   `cntr_value`: **1368 segundos** (≈ 22.8 minutos).

**¿Es bueno o malo?**

*   **Regla general:**
    *   Mínimo aceptable: **300 segundos por cada 4 GB de RAM**.
*   Si tu servidor tiene, por ejemplo:
    *   **64 GB RAM** → Esperarías **4800 segundos** (≈ 80 minutos).
    *   **128 GB RAM** → Esperarías **9600 segundos** (≈ 160 minutos).
*   **1368 segundos** es bajo para servidores grandes → indica **presión de memoria**.


	
*   **Identificar consultas que consumen más I/O**:
    ```sql
    SELECT TOP 10
           qs.total_logical_reads, qs.total_physical_reads, qs.execution_count,
           SUBSTRING(qt.text, 1, 200) AS QueryText
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
    ORDER BY qs.total_physical_reads DESC;
    ```

---
 
## ✅ **Tipos de mantenimiento en SQL Server con frecuencia sugerida**

 
*   **Monitoreo**: **24/7 con alertas**. [\[axial-sql.com\]](https://axial-sql.com/es/optimizando-el-mantenimiento-de-la-base-de-datos-de-sql-server-para-operaciones-24x7/), [\[axial-sql.com\]](https://axial-sql.com/es/tecnicas-de-mantenimiento-esenciales-para-sql-server/)

 

### 1. **Copias de seguridad (Backups)**

*   **Completa**
    *   **Servidor normal:** 1 vez por semana.
    *   **Transaccional:** Diario.
    *   **Muy transaccional:** Diario (o varias veces al día si el RPO es crítico).
*   **Diferencial**
    *   **Normal:** Cada 2-3 días.
    *   **Transaccional:** Diario.
    *   **Muy transaccional:** Varias veces al día.
*   **Log de transacciones**
    *   **Normal:** Cada 4-6 horas.
    *   **Transaccional:** Cada 15-30 minutos.
    *   **Muy transaccional:** Cada 5-10 minutos.
 
### 2. **Mantenimiento de índices**

*   **Reorganización (fragmentación 5%-30%)**
    *   **Normal:** Mensual.
    *   **Transaccional:** Semanal.
    *   **Muy transaccional:** Diario o cada 2 días.
*   **Reconstrucción (fragmentación >30%)**
    *   **Normal:** Mensual.
    *   **Transaccional:** Semanal.
    *   **Muy transaccional:** Semanal (o más frecuente si hay alto impacto en rendimiento).

 

### 3. **Actualización de estadísticas**

*   **Normal:** Mensual.
*   **Transaccional:** Semanal.
*   **Muy transaccional:** Diario (o usar `AUTO_UPDATE_STATISTICS` habilitado).

 

### 4. **Limpieza de archivos y logs**

*   **Normal:** Mensual.
*   **Transaccional:** Semanal.
*   **Muy transaccional:** Semanal (o según política de retención).

 

### 5. **Optimización de consultas y plan cache**

*   **Normal:** Trimestral.
*   **Transaccional:** Mensual.
*   **Muy transaccional:** Semanal (revisar Query Store y limpiar planes obsoletos).

 

### 6. **Verificación de integridad (`DBCC CHECKDB`)**

*   **Normal:** Mensual.
*   **Transaccional:** Semanal.
*   **Muy transaccional:** Semanal (o diario en bases críticas, pero programado en ventana de mantenimiento).

---

# Fragmentación y Desfragmentación

*   Desfragmentar el disco **no corrige la fragmentación de índices**.
*   Desfragmentar índices **no reorganiza sectores físicos del HDD**, solo páginas lógicas en el archivo MDF.


###   **Fragmentación física de disco (HDD)**

En un disco duro tradicional (HDD), los datos se guardan en **sectores físicos** sobre platos magnéticos.  
Cuando decimos que los bloques son **contiguos**, significa que están **uno al lado del otro físicamente en el disco**, sin espacios entre ellos.  
Esto es ideal porque el cabezal del disco puede leerlos **de corrido** sin moverse mucho.

**Ejemplo sencillo:**

*   Imagina un libro con páginas numeradas del 1 al 100.
*   Si las páginas están en orden (1, 2, 3…), lees rápido.
*   Si están desordenadas (1, 50, 2, 99…), tienes que buscar cada página → eso es fragmentación.


*   **Qué es:** Los bloques de un archivo (por ejemplo, el MDF de SQL Server) se almacenan en sectores no contiguos.
*   **Por qué ocurre:**
    1.  El sistema operativo asigna espacio libre donde puede, no siempre contiguo.
    2.  Archivos que crecen dinámicamente (bases de datos, logs) se expanden en fragmentos.
    3.  Eliminación de archivos deja huecos que se reutilizan.
*   **Consecuencia:** El cabezal del disco debe moverse más para leer el archivo completo, aumentando el tiempo de acceso (en SSD esto no importa).


###   **Desfragmentación de disco**

*   **Nivel:** físico.
*   **Objetivo:** reorganizar los bloques en el disco duro para que los archivos estén en sectores contiguos.
*   **Por qué:** en HDD, los datos pueden quedar dispersos por la fragmentación del sistema de archivos, lo que aumenta el tiempo de búsqueda del cabezal.
*   **Impacto:** mejora el rendimiento del disco, no afecta directamente la estructura lógica de la base de datos.
  
*   Solo mejora el acceso físico en HDD (en SSD no tiene impacto real).
*   SQL Server usa su propio motor de almacenamiento, que trabaja con páginas de 8 KB dentro de archivos MDF, por lo que la fragmentación del disco tiene un impacto mínimo en consultas.
*   Es útil en sistemas con muchos archivos pequeños, no tanto en bases de datos grandes.



###   **¿Por qué los archivos que crecen dinámicamente se fragmentan?**

Archivos como bases de datos (MDF, NDF) y logs **no tienen un tamaño fijo**.  
Empiezan pequeños y **van creciendo** conforme se insertan datos.  
El sistema operativo asigna espacio donde encuentra huecos libres en el disco, pero esos huecos **no siempre están juntos**.

**Ejemplo práctico:**

*   Tu base de datos empieza con 1 GB.
*   Luego necesita 500 MB más → el SO busca espacio libre y lo pone donde pueda.
*   Si no hay 500 MB seguidos, los divide en pedazos (fragmentos) y los coloca en diferentes partes del disco.

**Consecuencia:**  
El archivo queda “partido” en varias zonas → el cabezal del HDD debe moverse más para leerlo completo → acceso más lento.

 

###  **Desfragmentación de índices (SQL Server)**
*   **Qué es:** Las páginas del índice (de 8 KB) pierden su orden lógico respecto a la clave indexada.
*   **Por qué ocurre:**
    1.  **INSERT** en posiciones intermedias → genera divisiones de página (page splits).
    2.  **DELETE** → deja espacios vacíos en páginas.
    3.  **UPDATE** que cambia el tamaño de la fila → puede moverla a otra página.
*   **Consecuencia:** El motor necesita más lecturas para recorrer el índice, aumentando I/O lógico.

  
*   **Nivel:** lógico dentro de la base de datos.
*   **Objetivo:** reorganizar las páginas de datos en los índices para que estén ordenadas y contiguas según la clave.
*   **Por qué:** las operaciones DML (INSERT, UPDATE, DELETE) generan fragmentación lógica en los índices.
*   **Impacto:** mejora la eficiencia de las consultas, no cambia la ubicación física en el disco.

###   **Por qué los índices son más críticos**

*   Las consultas dependen de la estructura lógica de los índices.
*   Fragmentación alta en índices = más lecturas de páginas = consultas más lentas.
*   Esto afecta directamente el rendimiento del motor SQL, incluso si el disco está perfectamente desfragmentado.
 
---

# Links 
```
Lista de verificación: Mejores prácticas para SQL Server en máquinas virtuales -> https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist?view=azuresql#sql-server-features
Recommended updates and configuration options for SQL Server -> https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/performance/recommended-updates-configuration-options
Recomendaciones para reducir la contención de asignación en la base de datos tempdb de SQL Server -> https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/performance/recommendations-reduce-allocation-contention#resolution
SQL Server Design Considerations -> https://learn.microsoft.com/en-us/system-center/scom/plan-sqlserver-design?view=sc-om-2025
SQL Server security best practices -> https://learn.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver17
Prácticas recomendadas para las instancias de SQL Server -> https://docs.cloud.google.com/compute/docs/instances/sql-server/best-practices?hl=es-419
SQL Server Best Practices, Part I: Configuration -> https://www.varonis.com/blog/sql-server-best-practices-part-configuration
SQL Server Best Practices, Part II: Virtualized Environments ->  https://www.varonis.com/blog/sql-server-best-practices-in-virtualized-environments

GlennBerry Performance GitHub
https://github.com/yazalpizar/GlennBerry-SQL-Server-Diagnostic-Queries/tree/main
https://github.com/Ratithoglys/GlennBerry_DMV_Queries/tree/master

procedimiento almacenado gratuito para diagnosticar problemas de presión en CPU y memoria en SQL Server.
https://github.com/erikdarlingdata/DarlingData


```
