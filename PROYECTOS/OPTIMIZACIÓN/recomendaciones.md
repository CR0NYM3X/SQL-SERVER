
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
	
	-- Consulta para detectar contención en spinlocks:
	-- Si ves valores altos en collisions y spins, hay contención.
	SELECT *  FROM sys.dm_os_spinlock_stats WHERE name LIKE '%CACHESTORE%';
	
	-- Consulta para ver uso del plan cache:
	-- Si hay muchos planes ad-hoc y alta presión en cache, es candidato.
	SELECT cacheobjtype, objtype, COUNT(*) AS Cantidad FROM sys.dm_exec_cached_plans GROUP BY cacheobjtype, objtype;
	
	-- Monitorear waits CXPACKET y SOS_SCHEDULER_YIELD:
	-- Si son muy altos, indica problemas de paralelismo y contención.
	SELECT wait_type, waiting_tasks_count, wait_time_ms FROM sys.dm_os_wait_stats WHERE wait_type IN ('CXPACKET','SOS_SCHEDULER_YIELD');
	


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
# 💾 Estructuras de Asignación de Espacio
**PFS**, **GAM**, y **SGAM** son estructuras críticas de metadatos internas de **SQL Server** que se encuentran en las páginas de datos. Su función principal es rastrear la **asignación y el estado del espacio libre** dentro de los archivos de la base de datos (tanto datos de usuario como TempDB).
  
Estas páginas existen cada cierto intervalo dentro de los archivos de datos (MDF/NDF) y organizan el espacio en unidades lógicas llamadas **Extensiones** (*Extents*). Una Extensión es una unidad de 8 páginas contiguas (64 KB).

 

### 1. PFS: Page Free Space (Espacio Libre de Página)

| Concepto | Detalle |
| :--- | :--- |
| **Función** | Rastrea la **cantidad de espacio libre** dentro de cada página de datos. |
| **Frecuencia** | Existe una página PFS por cada **8,088 páginas** (aproximadamente 64 MB de datos). |
| **Contenido** | Para cada página de datos que rastrea, PFS almacena información sobre: * Si la página está asignada. * Si la página está libre (y qué porcentaje: 0%, 1%-50%, 51%-80%, 81%-95%, 96%-100%). |
| **Rol Clave** | Permite a SQL Server saber rápidamente si hay espacio en una página para un nuevo registro sin tener que leer la página de datos real. |

 
### 2. GAM: Global Allocation Map (Mapa de Asignación Global)

| Concepto | Detalle |
| :--- | :--- |
| **Función** | Rastrea qué **Extensiones** están **libres** y listas para ser usadas. |
| **Frecuencia** | Existe una página GAM por cada **64,000 Extensiones** (aproximadamente 4 GB de datos). |
| **Contenido** | Para cada Extensión que rastrea, la GAM almacena información de **asignación**: * Si la Extensión está completamente libre (sin asignar). * Si la Extensión está parcialmente o completamente en uso. |
| **Rol Clave** | Cuando SQL Server necesita una **Extensión nueva y vacía**, consulta la GAM para encontrar rápidamente un bloque de 64 KB disponible. |

 
### 3. SGAM: Shared Global Allocation Map (Mapa de Asignación Global Compartida)

| Concepto | Detalle |
| :--- | :--- |
| **Función** | Rastrea qué **Extensiones** están **parcialmente llenas** y disponibles para que sean compartidas por varios objetos. |
| **Frecuencia** | Existe una página SGAM por cada **64,000 Extensiones** (misma frecuencia que GAM). |
| **Contenido** | Para cada Extensión que rastrea, la SGAM almacena: * Si la Extensión está siendo utilizada por varias tablas (es decir, es una **Extensión mixta** y tiene espacio libre). * Si la Extensión está completamente utilizada (llena). |
| **Rol Clave** | SQL Server consulta SGAM para encontrar **espacio disponible** dentro de Extensiones que ya están en uso, pero que no están llenas. |

 
## 💥 Contención en TempDB

En tu servidor **super transaccional** con 64 *cores* y alto TPS, estas páginas son una fuente común de contención, especialmente en **TempDB**.

* Múltiples procesos (hilos) intentan modificar el estado de estas páginas simultáneamente (por ejemplo, actualizando una página SGAM para marcar una Extensión como usada).
* SQL Server utiliza **latches** (bloqueos ligeros y rápidos) para proteger estas páginas de metadatos.
* Si muchos procesos necesitan acceder a la **misma página PFS, GAM o SGAM** al mismo tiempo, se genera una cola conocida como contención de **PAGELATCH_EX** o **PAGELATCH_SH**.

La solución estándar para este problema, que mencionaste, es crear **múltiples archivos de datos (`.ndf`)** para TempDB. Esto distribuye las páginas PFS, GAM y SGAM en varios archivos, reduciendo la posibilidad de que muchos *threads* necesiten acceder a la misma página de metadatos simultáneamente.

---

# VLF 
¿Qué es un VLF?
Un VLF (Virtual Log File) es una subdivisión interna del Transaction Log en SQL Server.
   El Transaction Log se almacena en archivos `.ldf`.
   Cada archivo de log se divide en múltiples VLFs para administrar las operaciones de registro (INSERT, UPDATE, DELETE, transacciones).
Cada vez que el log crece, SQL Server crea más VLF.
El número y tamaño de los VLF depende de cómo se configuró el crecimiento del log.
   puedes usar la vista  sys.dm_db_log_info(DB_ID())  o DBCC LOGINFO para identificar la cantidad de VLF  
    y   son muy importantes porque afectan directamente el rendimiento y la recuperación de la base de datos

Función principal:  
Permitir que SQL Server gestione el crecimiento y truncamiento del log de manera eficiente.

 ¿Para qué sirve?
   Controla cómo se escriben y reutilizan las porciones del log.
   Facilita el truncamiento del log cuando se hace un checkpoint o backup de log.
   Ayuda a la recuperación de transacciones en caso de fallo.


### ✅ Problemas principales por exceso de VLFs

1.  Inicio lento de la base de datos
       Durante el arranque, SQL Server debe revisar todos los VLFs para la recuperación.
       Si hay miles, el tiempo de inicio aumenta significativamente.
	

2.  Backups del log más lentos
       El backup del log procesa cada VLF.
       Más VLFs = más tiempo para recorrerlos.

3.  Restauración y recuperación más lenta
       Igual que el arranque, la restauración debe validar cada VLF.
	Checkpoint y recuperación se vuelven lentos.

4.  Operaciones de replicación y mirroring afectadas
       Estas tecnologías dependen del log.
       Muchos VLFs pueden causar retrasos en sincronización.

5.  Fragmentación interna del log
       Crecimientos pequeños y frecuentes → demasiados VLFs → fragmentación → menor eficiencia.

6.  Impacto en AlwaysOn y Log Shipping
       La lectura del log para enviar cambios se vuelve más costosa.
	Mirroring, AlwaysOn, replicación pueden fallar por exceso de VLF.
 
  ¿Por qué ocurre?


   Autogrowth configurado en porcentaje o valores muy pequeños (ej. 1 MB).
   Crecimientos frecuentes por falta de tamaño inicial adecuado.
   Cada vez que el log crece poco, se crean muchos VLF pequeños → miles de VLF.
 
 
 

### ✅ Buenas prácticas y recomendaciones 

   Cantidad recomendada:
       Idealmente menos de 100 VLFs por archivo de log.
 

   Configurar tamaño inicial adecuado O grande (ej. 1 GB o más según carga).
   Configurar autogrowth/crecimiento en MB grandes (ej. 512 MB o 1 GB, no en KB).
   Evitar shrink frecuente (provoca fragmentación y más VLF) solo para corregir VLF excesivos.. 
   Monitorear VLF con `DBCC LOGINFO` (o en versiones nuevas `sys.dm_db_log_info`)
   




### ✅ ¿Cuántos VLF son recomendados?

No existe un número fijo universal, pero la regla práctica es:

   Menos de 1,000 VLFs → aceptable.
   Más de 10,000 VLFs → problema grave (impacta recuperación y rendimiento).
   Ideal: entre 50 y 500 VLFs para la mayoría de bases de datos.


### ✅ Cómo se crean los VLFs (algoritmo clásico hasta SQL Server 2019)

   Crecimiento < 64 MB → 4 VLFs (cada uno ≈ ¼ del tamaño).
   Crecimiento 64 MB – 1 GB → 8 VLFs (cada uno ≈ ⅛ del tamaño).
   Crecimiento > 1 GB → 16 VLFs (cada uno ≈ 1/16 del tamaño).  


En SQL Server 2022, el algoritmo se optimizó:

   ≤ 64 MB → 1 VLF.
   64 MB – 1 GB → 8 VLFs.
   > 1 GB → 16 VLFs. 


 

 
 
#  Correccion en caso de un problema de muchos VLF 

 
 

### ✅ Técnicas para solucionar problemas de VLF

1.  Identificar el número de VLFs
    ```sql
    DBCC LOGINFO;
    ```
    Si hay miles de VLFs, es un problema.


hacer un checkpoint o backup dependiendo del metodo de recuperación

2.  Reducir el número de VLFs
       Shrink controlado:
        ```sql
        DBCC SHRINKFILE (NombreArchivoLog, TamañoDeseadoEnMB);
        ```
        ⚠️ Hazlo solo después de un backup del log para no perder datos.



3.  Recrear el archivo de log con tamaño adecuado
       Pasos recomendados:
           Backup del log.
           Shrink para reducirlo.
           Aumentar el tamaño en un solo crecimiento grande:
            ```sql
            ALTER DATABASE [TuBase]
            MODIFY FILE (NAME = NombreArchivoLog, SIZE = 4GB);
            ```
           Configurar autogrowth en MB grandes (ej. 512 MB o 1 GB) para evitar fragmentación.



	 ¿definir el tamaño inicial adecuado?

	Depende de: Tamaño esperado de la base de datos, Frecuencia de transacciones, Política de backups del log

	Regla práctica:

	   Para bases pequeñas (<10 GB): log inicial de 512 MB – 1 GB
	   Para bases medianas (10–100 GB): log inicial de 2–4 GB
	   Para bases grandes (>100 GB): log inicial de 8 GB o más



4.  Evitar crecimiento automático pequeño
       Ajusta el autogrowth:
        ```sql
        ALTER DATABASE [TuBase]
        MODIFY FILE (NAME = NombreArchivoLog, FILEGROWTH = 512MB);
        ```



5.  Revisar periódicamente
       Usa `DBCC LOGINFO` o en versiones recientes:
        ```sql
        SELECT COUNT() AS VLFCount FROM sys.dm_db_log_info(DB_ID());
        ```

 
 
### ✅ Recomendaciones según tipo de instancia y carga

| Escenario                | Tamaño inicial recomendado                         | Autogrowth recomendado | VLF esperado |
| ---------------------------- | ------------------------------------------------------ | -------------------------- | ---------------- |
| Pequeña (bases <10 GB)   | 512 MB – 1 GB                                          | 256 MB                     | 50 – 100         |
| Mediana (10–100 GB)      | 4 GB                                                   | 512 MB – 1 GB              | 100 – 500        |
| Grande (>100 GB)         | 8–16 GB                                                | 4 GB                       | 500 – 1,000      |
| Alta carga transaccional | Igual que grande, pero evitar autogrowth frecuente | 4 GB                       | Mantener <1,000  |


 ## 🚦 Rangos de VLF (Virtual Log File)

No existe un número mágico, pero los DBAs y las directrices de Microsoft utilizan estos rangos para diagnosticar y prevenir problemas de rendimiento, especialmente en la recuperación de la base de datos:

| Rango de VLFs | Estado de la Base de Datos | Impacto y Recomendación |
| :--- | :--- | :--- |
| **0 a 100** | **Óptimo / Normal** | Excelente. No se requiere ninguna acción. El rendimiento de la recuperación y la copia de seguridad será muy rápido. |
| **100 a 300** | **Aceptable / Normal** | Bueno. Si bien no es ideal, es común en bases de datos con un crecimiento moderado. No debería causar problemas significativos. |
| **300 a 1,000** | **Advertencia / Atención** | Moderado. El tiempo de recuperación después de un reinicio o fallo podría comenzar a ser notable. **Se recomienda una reestructuración (Shrink y Grow) en el próximo mantenimiento programado.** |
| **Más de 1,000** | **Crítico / Problemático** | Alto. El tiempo de recuperación de la base de datos (e incluso la restauración de backups) puede volverse inaceptablemente largo, impactando la disponibilidad. **Se requiere una acción inmediata (reestructuración del archivo de registro).** |




---

# Query Store 

 
 
El **Query Store** es más que una herramienta de monitoreo; es la **memoria histórica persistente** de tu base de datos SQL Server, ofreciendo una gestión de rendimiento fundamentalmente superior a las DMVs o estadísticas tradicionales, especialmente en tu entorno **OLTP (Transaccional)**.
 
### 1. El "Grabador de Vuelo" Persistente  

A diferencia de las **DMVs**, cuyas métricas se borran al reiniciar el servicio de SQL Server, el Query Store **almacena continuamente** el texto de las consultas, sus planes de ejecución y sus métricas de rendimiento (CPU, I/O, duración) en disco.

* **Beneficio:** Proporciona un **historial completo y persistente** que te permite analizar el rendimiento a lo largo del tiempo, sobreviviendo a los reinicios del servidor y cambios en el código o hardware.

 

### 2. Gestión Proactiva de Planes de Ejecución  

Esta es su funcionalidad más crítica y la principal diferencia con `pg_stat_statements` de PostgreSQL.

* **Identificación de Regresiones:** El Query Store permite identificar rápidamente cuándo una consulta se vuelve lenta (regresión) debido a que el **Optimizador de Consultas** eligió un plan de ejecución peor.
* **Plan Forcing:** Te permite **forzar** al motor a utilizar un plan de ejecución conocido como bueno, estabilizando el rendimiento de consultas volátiles y previniendo futuros problemas.

 

### 3  Forzado Automático - Funcionamiento Después de la Configuración


Una vez que estableces `FORCE_LAST_GOOD_PLAN = ON`, el motor de SQL Server se encarga de la automatización:

1.  **Monitoreo Continuo:** SQL Server monitorea el rendimiento de las consultas y sus planes utilizando los datos del Query Store.
2.  **Identificación de Regresión:** Si el tiempo de ejecución (CPU, duración) de un nuevo plan se degrada significativamente (ej. se vuelve más lento en un 10% o más) en comparación con el plan anterior, lo marca como una regresión.
3.  **Acción Automática:** El motor automáticamente **fuerza** el uso del plan anterior y más eficiente (el "último plan bueno") sin requerir ninguna acción o *hint* en la consulta de tu aplicación.

**En resumen:** Lo **configuras manualmente una vez** a nivel de base de datos, y luego el **motor de SQL Server lo gestiona y aplica automáticamente** a nivel de consulta para estabilizar el rendimiento.


```
---- ********** ACTIVAR AUTOMATICACION ***********
-- ocupas >  SQL Server 2017 o posterior. 
-- Automatic Tuning is available only in the Enterprise and Developer editions of SQL Server. Mens. 5069, Nivel 16, Estado 1, Línea 12 ALTER DATABASE statement failed.
ALTER DATABASE northwind
SET AUTOMATIC_TUNING (
    FORCE_LAST_GOOD_PLAN = ON
);

--- validar si esta activado automaticcamente 
SELECT 
    *
FROM 
    sys.database_automatic_tuning_options AS t
WHERE 
    t.name = 'FORCE_LAST_GOOD_PLAN';
 
```

---

# Flag 3226 
Suprime los mensajes de backup exitoso en el error log. Los backups fallidos sí se registran y el historial completo sigue en msdb.dbo.backupset.


 
###   **Cómo revisar si lo necesitas**

1.  **Verifica el tamaño del error log y la cantidad de mensajes de backup**:
    ```sql
    EXEC sp_readerrorlog 0, 1, 'BACKUP';
    ```
    *   Si ves **miles de entradas de backups exitosos**, tu log está saturado.

2.  **Revisa la frecuencia de backups**:
    ```sql
    SELECT database_name, COUNT(*) AS CantidadBackups
    FROM msdb.dbo.backupset
    WHERE backup_start_date > DATEADD(DAY, -1, GETDATE())
    GROUP BY database_name;
    ```
    *   Si haces **muchos backups por día** (ej. log cada 5 minutos), el error log se llenará rápido.

3.  **Evalúa el impacto**:
    *   Si el error log crece demasiado y dificulta encontrar errores críticos, **activar el flag es recomendable**.
 

###  **Conclusión**

*   Si tu servidor tiene **muchas bases** y **backups frecuentes** (FULL, DIFF, LOG), **activa el Trace Flag 3226** para reducir ruido en el error log.
*   Activación:
    ```sql
    DBCC TRACEON(3226, -1); -- Global
    ```
    O como parámetro de inicio:
        -T3226

---


# Max Server Memory 
 [usar la pagina](https://bornsql.ca/s/memory/)
--- 

 

 
# **Estadísticas en SQL Server: Claves para Rendimiento**

Las **estadísticas** son fundamentales para que el **optimizador de consultas** elija el mejor plan de ejecución. Si están desactualizadas o mal gestionadas, el rendimiento se degrada, especialmente en sistemas transaccionales con alta concurrencia.



##  **1. AUTO_CREATE_STATISTICS**

*   **¿Qué es?**  
    Permite que SQL Server Crea automáticamente estadísticas para columnas que no tienen estadísticas  usadas en predicados (WHERE, JOIN) cuando se ejecutan consultas que las necesitan.    
*   **¿Para qué sirve?**  
    Ayuda al optimizador a tener información precisa sin intervención manual.
*   **Ventajas:**
    *   Mejora planes de ejecución sin esfuerzo.
    *   Reduce necesidad de crear estadísticas manualmente.
*   **Desventajas:**
    *   Puede generar muchas estadísticas en entornos con consultas ad-hoc.
    *   Incrementa uso de CPU y disco al crearlas.
*   **¿Cuándo usar?**
    *   **Sí:** En la mayoría de los entornos OLTP y OLAP.
    *   **No:** Si tienes un diseño muy controlado y creas estadísticas manualmente.
*   **Consideraciones críticas:**
	*  Mantenerlo activado en la mayoría de los casos, porque ayuda al optimizador a generar mejores planes sin intervención manual.
    *   No desactivar en sistemas dinámicos.
    *   Monitorear cantidad de estadísticas para evitar sobrecarga.



##  **2. AUTO_UPDATE_STATISTICS**

*   **¿Qué es?**  
    Actualiza automáticamente estadísticas cuando detecta cambios significativos en los datos.
*   **¿Para qué sirve?**  
    Mantiene estadísticas frescas para planes óptimos.
*   **Ventajas:**
    *   Reduce riesgo de planes obsoletos.
    *   Automático, sin intervención manual.
*   **Desventajas:**
    *   Puede causar **pausas** en consultas cuando se actualizan sincrónicamente.
*   **¿Cuándo usar?**
    *   **Sí:** Siempre en entornos OLTP y OLAP.
    *   **No:** Nunca desactivar, salvo casos muy específicos con mantenimiento manual.
*   **Consideraciones críticas:**
    *   Actualización es **sincrónica** → puede afectar tiempos de respuesta.
    *   Ajustar umbrales con `trace flags` o `ALTER DATABASE SET AUTO_UPDATE_STATISTICS`.



##  **3. AUTO_UPDATE_STATISTICS_ASYNC**

*   **¿Qué es?**  
    Permite que la actualización de estadísticas ocurra **asíncronamente**, evitando que la consulta espere.
    Si está activado, la consulta sigue ejecutándose con estadísticas viejas y la actualización ocurre en segundo plano.
*   **¿Para qué sirve?**  
    Evita bloqueos por actualización de estadísticas.
*   **Ventajas:**
    *   Mejora concurrencia en sistemas muy transaccionales.
    *   Reduce tiempos de espera.
*   **Desventajas:**
    *   La primera consulta después del cambio puede usar estadísticas obsoletas.
*   **¿Cuándo usar?**
    *   **Sí:**  Activar en entornos con alta concurrencia y consultas largas donde no quieres bloqueos.
    *   **No:**  Desactivar en entornos donde la precisión del plan es crítica (OLTP muy sensible).
*   **Consideraciones críticas:**
    *   Activar junto con `AUTO_UPDATE_STATISTICS`.
    *   Monitorear impacto en planes de ejecución.
    *   Si desactivas AUTO_UPDATE_STATISTICS, el modo asíncrono no tiene efecto.
	* Si activas ambos, el comportamiento será asíncrono y no sincrono.



##  **4. INCREMENTAL_STATS**

*   **¿Qué es?**  
    Permite actualizar estadísticas **por partición** en tablas particionadas.
*   **¿Para qué sirve?**  
    Evita recalcular estadísticas completas en tablas enormes.
*   **Ventajas:**
    *   Ahorra tiempo y recursos en tablas grandes.
    *   Ideal para entornos de data warehouse.
*   **Desventajas:**
    *   Solo disponible en Enterprise Edition.
    *   Configuración más compleja.
*   **¿Cuándo usar?**
    *   **Sí:** Tablas particionadas con millones de filas.
    *   **No:** Tablas pequeñas o sin particiones.
*   **Consideraciones críticas:**
    *   Requiere habilitar `INCREMENTAL = ON` al crear estadísticas.
    *   Compatible con `UPDATE STATISTICS` por partición.



##  **Importancia y Cuidado**

*   **Estadísticas = corazón del optimizador.**  
    Si están desactualizadas → planes malos → rendimiento pobre.
*   **En tu caso (288 GB RAM, 64 cores, 10 TB):**
    *   Activa **AUTO_CREATE** y **AUTO_UPDATE**.
    *   Activa **ASYNC** para evitar bloqueos.
    *   Usa **INCREMENTAL_STATS** en tablas particionadas.
*   **Monitoreo crítico:**
    *   DMV: `sys.stats`, `sys.dm_db_stats_properties`.
    *   Jobs de mantenimiento: `UPDATE STATISTICS` o `sp_updatestats`.


# Validar si esta activado 

```
SELECT name AS DatabaseName,
       is_auto_create_stats_on,
       is_auto_update_stats_on,
       is_auto_update_stats_async_on
FROM sys.databases;


SELECT name, is_incremental
FROM sys.stats
WHERE object_id = OBJECT_ID('TuTabla');


```


---


# Nivel de aislamiento

## 🛠️ Sintaxis General

La sintaxis es la siguiente:

```sql
SET TRANSACTION ISOLATION LEVEL {
    READ UNCOMMITTED
  | READ COMMITTED
  | REPEATABLE READ
  | SNAPSHOT
  | SERIALIZABLE
}
```
 

## 💡 Niveles de Aislamiento Comunes

Aquí tienes una breve descripción de los niveles de aislamiento más comunes y cómo los estableces:

  * **READ UNCOMMITTED:** Permite que una transacción lea datos que han sido modificados por otras transacciones, pero aún no han sido *commitidos* (confirmados). Esto puede resultar en **lecturas sucias** (*dirty reads*).

    ```sql
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    ```

  * **READ COMMITTED:** Es el nivel por defecto en SQL Server. Una transacción solo puede leer datos que han sido *commitidos* por otras transacciones, previniendo lecturas sucias. Sin embargo, puede experimentar **lecturas no repetibles** (*non-repeatable reads*) o **filas fantasma** (*phantom rows*).

    ```sql
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    ```

  * **REPEATABLE READ:** Una transacción puede leer repetidamente los mismos datos y ve los mismos valores hasta que finaliza. Previene las lecturas no repetibles, pero aún puede experimentar filas fantasma.

    ```sql
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    ```

  * **SERIALIZABLE:** Es el nivel más restrictivo. Garantiza que si la transacción se ejecutara en serie (una tras otra), produciría los mismos resultados. Previene lecturas sucias, no repetibles y filas fantasma.

    ```sql
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    ```

  * **SNAPSHOT:** Utiliza un mecanismo basado en versiones para proveer consistencia a nivel de sentencia o transacción. Las transacciones leen los datos tal como existían al inicio de la transacción, evitando que las operaciones de lectura bloqueen las escrituras.

    ```sql
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    ```

    (Nota: Para usar **SNAPSHOT**, la base de datos debe tener habilitada la opción `ALLOW_SNAPSHOT_ISOLATION`).



## 📝 Ejemplo de Uso

Generalmente, estableces el nivel de aislamiento **antes** de iniciar una transacción explícita:

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;
    -- Aquí van tus sentencias SELECT, INSERT, UPDATE, DELETE
    SELECT * FROM MiTabla WHERE ID = 1;
    UPDATE MiTabla SET Columna = 'NuevoValor' WHERE ID = 1;

COMMIT TRANSACTION;
```


 

###  ¿Cómo ver si están habilitados?

Ejecuta esta consulta en la base de datos que quieres revisar:

```sql
SELECT name, is_read_committed_snapshot_on, snapshot_isolation_state_desc
FROM sys.databases
WHERE name = 'TuBaseDeDatos';
```

*   **is\_read\_committed\_snapshot\_on**
    *   `1` = **READ\_COMMITTED\_SNAPSHOT** habilitado
    *   `0` = deshabilitado

*   **snapshot\_isolation\_state\_desc**
    *   `ON` = **ALLOW\_SNAPSHOT\_ISOLATION** habilitado
    *   `OFF` = deshabilitado



###  ¿Para qué sirve cada uno?

#### **1. ALLOW\_SNAPSHOT\_ISOLATION**

*   Permite que las transacciones usen el nivel de aislamiento **SNAPSHOT**.
*   Este nivel evita bloqueos de lectura porque las lecturas se hacen sobre una versión consistente de los datos (versionado en tempdb).
*   Se activa por transacción con:
    ```sql
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    ```
*   **Uso típico:** sistemas con alta concurrencia donde se quiere evitar bloqueos entre lectores y escritores.



#### **2. READ\_COMMITTED\_SNAPSHOT**

*   Cambia el comportamiento del nivel **READ COMMITTED** para usar **versionado de filas** en lugar de bloqueos.
*   Se aplica automáticamente a todas las transacciones que usan READ COMMITTED (por defecto en SQL Server).
*   **Beneficio:** reduce bloqueos sin necesidad de cambiar el código de la aplicación.
*   Se habilita a nivel de base de datos:
    ```sql
    ALTER DATABASE TuBaseDeDatos SET READ_COMMITTED_SNAPSHOT ON;
    ```



###  ¿Tienen relación?

Sí, ambos usan **versionado en tempdb**, pero:

*   **READ\_COMMITTED\_SNAPSHOT** afecta el nivel por defecto (READ COMMITTED).
*   **ALLOW\_SNAPSHOT\_ISOLATION** habilita un nivel adicional (SNAPSHOT) que debe ser solicitado explícitamente.

**En resumen:**

*   Si habilitas **READ\_COMMITTED\_SNAPSHOT**, todas las lecturas en READ COMMITTED serán con versión.
*   Si habilitas **ALLOW\_SNAPSHOT\_ISOLATION**, puedes usar SNAPSHOT en tus transacciones.


 

# Links 
```
Extensiones de SQL Server, PFS, GAM, SGAM e IAM y corrupciones relacionadas -> https://techcommunity.microsoft.com/blog/sqlserversupport/sql-server-extents-pfs-gam-sgam-and-iam-and-related-corruptions/1606011

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
