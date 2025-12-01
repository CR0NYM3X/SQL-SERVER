

# Títulos
- Conexion
- Locks
- WAITS
- I/O
- CPU, Memoria




# Tools
- Activity monitor (SQL Server)
- Performance monitor (Windows)
- [Querys GlennBerry ](https://github.com/yazalpizar/GlennBerry-SQL-Server-Diagnostic-Queries/blob/main/SQL%20Server%202022%20Diagnostic%20Information%20Queries.sql)


# Umbrales de rendimiento (CPU, I/O y Memoria)

### ✅ **1. CPU**

*   **Estable:**  
    Uso por consulta < **20%** del total disponible y duración < **1 seg**.
*   **Malo:**  
    Uso por consulta entre **20% – 50%** o duración > **1 seg**.
*   **Crítico:**  
    Uso > **50%** sostenido o duración > **5 seg** (en OLTP) / > **30 seg** (en OLAP).
 


### ✅ **I/O (Lecturas y Escrituras)**

*   **Estable:**
    *   Lecturas lógicas: **< 10.000** páginas por consulta.
    *   Escrituras lógicas: **< 1.000** páginas  por consulta.
    *   Espera en disco: **< 10 ms**.
*   **Malo:**
    *   Lecturas: **10.000 – 100.000** páginas.
    *   Escrituras: **1.000 – 10.000** páginas.
    *   Espera en disco: **10 – 20 ms**.
*   **Crítico:**
    *   Lecturas: **> 100.000**.
    *   Escrituras: **> 10.000**.
    *   Espera en disco: **> 20 ms** (indica problemas serios: falta de índices, consultas mal diseñadas, o saturación de disco).
 

 
### ✅ **3. Memoria**

*   **Estable:**  
    Uso < **25%** del buffer pool asignado.
*   **Malo:**  
    Uso entre **25% – 50%**, con señales de **spills** en tempdb.
*   **Crítico:**  
    Uso > **50%** y presencia de **hash spills** o **sort spills** frecuentes.

----
# Conexion
**¿Por qué monitoreo las conexiones?**  
Porque las conexiones son el punto de entrada a la base de datos y su correcta gestión garantiza la estabilidad, el rendimiento y la disponibilidad del sistema.  
Un exceso de conexiones abiertas o mal administradas puede provocar saturación de recursos, errores de “too many connections”, degradación del rendimiento e incluso caída del servicio.

**¿Qué valido al monitorearlas?**

*   **Número total de conexiones activas**: Para evitar que se alcance el límite máximo definido en el servidor.
*   **Estado de las conexiones**: Activas, inactivas, en espera, para identificar posibles fugas o sesiones huérfanas.
*   **Tiempo de vida de la conexión**: Detectar conexiones que permanecen abiertas demasiado tiempo sin actividad.
*   **Aplicación o cliente que genera la conexión**: Para identificar patrones y ajustar la configuración.
*   **Usuario y base de datos asociada**: Para verificar que no haya accesos indebidos o sobrecarga en una base específica.
*   **Consumo de recursos por conexión**: CPU, memoria y transacciones en curso.
*   **Patrones repetitivos**: Horarios pico, aplicaciones que no cierran conexiones, para aplicar optimizaciones (pooling, límites, alertas).

**Notas**
*   **En SQL Server, el límite crítico es por *sesiones***, porque el parámetro `user connections` controla cuántas sesiones lógicas pueden existir simultáneamente.
*   Cada sesión consume recursos (CPU, memoria, bloqueos) y si se alcanza el límite, **SQL Server rechaza nuevas conexiones**, afectando la disponibilidad.
*   **Conexiones físicas** son solo el canal de comunicación (TCP/IP, Named Pipes). Una sesión normalmente tiene una conexión, pero puede tener varias (MARS).
*   **Para monitoreo de capacidad y alertas críticas → usa sesiones.**
*   **Para diagnóstico de red, seguridad y auditoría → usa conexiones.**

📌 **Regla práctica para tu gráfico y reportes:**

*   Métrica principal: **Porcentaje de sesiones usadas vs límite (`user connections`)**.
*   Métrica complementaria: **Conexiones físicas por host/IP** para análisis de red.

***
```sql

--- Muestra el Máximo de conexiones y conexiones actuales 
SELECT
    cfg.max_connections,
    ses.current_connections ,
    CASE 
        WHEN cfg.max_connections = 0 THEN NULL  -- Si es 0, no calculamos porcentaje
        ELSE CAST(ROUND((ses.current_connections * 100.0) / cfg.max_connections, 2) AS DECIMAL(5,2))
    END AS percent_used
FROM 
    (SELECT CAST(value_in_use AS INT) AS max_connections
     FROM sys.configurations
     WHERE name = 'user connections') AS cfg
CROSS JOIN
    (SELECT
    count(*) AS current_connections
FROM sys.dm_exec_connections AS c
JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
WHERE c.endpoint_id != 2) AS ses;

--- Muestra el cantas conexiones hay por IP 
SELECT
    c.client_net_address ,
    s.host_name,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    --COUNT(c.session_id) AS total_connections,
    SUM(s.cpu_time) AS total_cpu_ms,
    SUM(s.memory_usage) * 8 AS total_memory_kb  -- Cada unidad = 8 KB
FROM sys.dm_exec_sessions AS s
LEFT JOIN sys.dm_exec_connections AS c
    ON s.session_id = c.session_id
WHERE s.host_name IS NOT NULL AND   c.endpoint_id != 2 
GROUP BY c.client_net_address,s.host_name
ORDER BY total_sessions DESC;


-- Muestra los detalles de cada conexion realizada 
SELECT
    s.session_id AS [SessionID],
    c.connect_time AS [ConnectionStartTime],
    c.client_net_address AS [ClientIP],
    c.protocol_type AS [ConnectionType],c.encrypt_option,c.auth_scheme  ,
    s.login_name AS [LoginName],
    s.host_name AS [HostName],
    s.program_name,
    s.status AS [RequestStatus],
    CASE WHEN r.start_time IS NULL THEN s.last_request_start_time ELSE r.start_time END AS [QueryStartTime],
    DATEDIFF(MINUTE,  CASE WHEN r.start_time IS NULL THEN s.last_request_start_time ELSE r.start_time END  , GETDATE()) AS MinutosTranscurridos,
    r.command AS [CommandType],
    r.cpu_time AS [CPU_Time_ms],
    r.total_elapsed_time AS [ElapsedTime_ms],
    SUBSTRING(t.text, (r.statement_start_offset/2)+1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(t.text)
            ELSE r.statement_end_offset END - r.statement_start_offset)/2)+1) AS [ExecutingQuery],
    f.text AS [LastExecutedQuery],
     r.reads, --  lecturas físicas de páginas desde disco (cada página = 8 KB en SQL Server).
     r.writes,  --   escrituras físicas de páginas a disco (también páginas de 8 KB).
     r.logical_reads, --   lecturas lógicas de páginas desde el buffer cache (memoria), no desde disco.
     s.text_size, -- máximo tamaño en bytes que la sesión puede devolver para columnas tipo texto (por defecto 2 GB).
     s.cpu_time, --  tiempo total de CPU consumido por la sesión, medido en milisegundos
     s.memory_usage * 8 AS memory_usage_kb -- cantidad de páginas de memoria asignadas a la sesión. Cada unidad equivale a 8 KB (página estándar en SQL Server).

FROM  sys.dm_exec_sessions s 
LEFT JOIN sys.dm_exec_connections c  ON s.session_id = c.session_id --  Detalles de la conexión (IP, protocolo, hora de conexión).
LEFT JOIN sys.dm_exec_requests r ON c.session_id = r.session_id --  Consultas en ejecución  (estado, tiempo, CPU).
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t --  query que están en ejecución activa 
OUTER APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) f  -- La ultima query ejecutada
WHERE 
  c.endpoint_id != 2  -- Excluye procesos Shared memory que normalmente son conexiones internas
  -- s.is_user_process = 1  -- Excluye procesos internos del sistema
  AND s.session_id <> @@SPID -- Excluye la sesión actual
ORDER BY MinutosTranscurridos DESC;
 ```



 ---

### ✅ **¿Qué es un latch en SQL Server?**

Un **latch** es un **mecanismo interno de sincronización que bloquea temporalmente el acceso físico** se usa SQL Server para **proteger estructuras en memoria** (como páginas del buffer pool, allocation maps) cuando varios hilos (threads) acceden a ellas **al mismo tiempo**.

Piensa en un latch como un **candado rápido y ligero** que asegura que nadie modifique una página mientras otro la está leyendo o escribiendo.  
Es **más bajo nivel que un lock** y **no está asociado a transacciones ni a aislamiento lógico.**, sino con la **integridad física de los datos en memoria**.

 

### ✅ **¿Para qué sirve?**

*   Evita **corrupción de datos** en memoria.
*   Garantiza que las operaciones sobre páginas (lectura/escritura) sean **seguras y consistentes**.
*   Controla la concurrencia en estructuras internas como:
    *   **Páginas de datos** (Buffer Pool).
    *   **Índices**.
    *   **Mapas de asignación** (PFS, GAM, SGAM).
 

### ✅ **Tipos de latch más comunes**

*   **PAGELATCH\_SH** → Lectura compartida en memoria.
*   **PAGELATCH\_EX** → Escritura exclusiva en memoria.
*   **PAGEIOLATCH\_SH / EX** → Similar, pero esperando I/O (disco).

 

### ✅ **Diferencia entre latch y lock**

| **Latch**                              | **Lock**                              |
| -------------------------------------- | ------------------------------------- |
| Protege estructuras físicas en memoria | Protege datos lógicos (filas, tablas) |
| No depende de transacciones            | Depende del aislamiento transaccional |
| Muy rápido, de corta duración          | Puede durar más tiempo                |
| Ejemplo: PAGELATCH                     | Ejemplo: LCK\_M\_X                    |


### ✅ **¿Por qué es importante?**

Si ves muchas esperas **PAGELATCH\_**\* en `sys.dm_os_wait_stats`, significa que hay **contención en memoria**, normalmente por:

*   Alta concurrencia en la misma página (hot page).
*   Tablas con **IDENTITY** o secuencias muy usadas.
*   Operaciones masivas en índices.

*   **PAGELATCH** → Protege **páginas en memoria** (Buffer Pool).
    *   Se usa cuando la página **ya está cargada en RAM**.
    *   Ejemplo: múltiples sesiones intentando leer/escribir la misma página en memoria.
    *   Tipos: `PAGELATCH_SH`, `PAGELATCH_EX`, `PAGELATCH_UP`.

*   **PAGEIOLATCH** → Protege **operaciones de I/O** (lectura/escritura en disco).
    *   Se usa cuando la página **no está en memoria y debe leerse del disco**.
    *   Tipos: `PAGEIOLATCH_SH`, `PAGEIOLATCH_EX`.

 

### 🔍 **Cómo interpretarlo**

*   Si ves **PAGELATCH** alto → Contención interna en memoria (hot pages).
*   Si ves **PAGEIOLATCH** alto → Problemas de I/O (disco lento, falta de RAM, exceso de lectura).

 ---




# Locks 
**¿Por qué monitoreo los locks?**  
Porque los bloqueos son mecanismos que garantizan la integridad y consistencia de los datos cuando varias transacciones acceden a los mismos recursos  (filas, páginas, tablas).
y previenen que modifiquen simultáneamente la misma información y provoquen corrupción o resultados incorrectos.

Si no se controlan, pueden generar cuellos de botella, lentitud, bloqueos en cascada o incluso deadlocks que afectan la disponibilidad del sistema.

**¿Qué valido al monitorearlos?**

*   **Duración del bloqueo**: Cuánto tiempo lleva bloqueado un recurso.
*   **Tipo de lock**: Shared, Exclusive, Update, etc., para entender el nivel de contención.
*   **Proceso bloqueador y bloqueado**: Identificar quién está causando la espera.
*   **Query que genera el bloqueo**: Para optimizarla o corregirla.
*   **Impacto en recursos**: CPU, memoria y base de datos involucrada.
*   **Patrones repetitivos**: Para prevenir problemas recurrentes y deadlocks.

### Obtener los locks usando la vista dm_os_waiting_tasks
```sql
SELECT
    wt.blocking_session_id AS Proceso_Bloqueador,
    wt.session_id AS Proceso_Bloqueado,
    CAST(wt.wait_duration_ms / 60000.0 AS DECIMAL(10,2)) AS TiempoBloqueado_Minutos,

    -- Información del bloqueador
    bl.status AS Bloqueador_Status,
    bl.login_name AS Bloqueador_Login,
    bl.host_name AS Bloqueador_Host,
    DB_NAME(bl.database_id) AS Bloqueador_BaseDatos,
    bl.cpu_time AS Bloqueador_CPU_Time,
    bl.memory_usage AS Bloqueador_MemoriaKB,
    --CAST(DATEDIFF(SECOND, bl.login_time, GETDATE()) / 60.0 AS DECIMAL(10,2)) AS Bloqueador_TiempoSesion_Minutos,
    ISNULL(txt_bl.text, 'No hay query registrada') AS Bloqueador_UltimaQuery,
    -- ISNULL(qp.query_plan, 'No hay plan disponible') AS Bloqueador_QueryPlan,

    -- Información del bloqueado
    bk.status AS Bloqueado_Status,
    bk.login_name AS Bloqueado_Login,
    bk.host_name AS Bloqueado_Host,
    DB_NAME(bk.database_id) AS Bloqueado_BaseDatos,
    bk.cpu_time AS Bloqueado_CPU_Time,
    bk.memory_usage AS Bloqueado_MemoriaKB,
    --CAST(DATEDIFF(SECOND, bk.login_time, GETDATE()) / 60.0 AS DECIMAL(10,2)) AS Bloqueado_TiempoSesion_Minutos,
    ISNULL(txt_bk.text, 'No hay query registrada') AS Bloqueado_UltimaQuery
FROM sys.dm_os_waiting_tasks wt
INNER JOIN sys.dm_exec_sessions bl ON wt.blocking_session_id = bl.session_id
INNER JOIN sys.dm_exec_sessions bk ON wt.session_id = bk.session_id
LEFT JOIN sys.dm_exec_connections conn_bl ON bl.session_id = conn_bl.session_id
LEFT JOIN sys.dm_exec_connections conn_bk ON bk.session_id = conn_bk.session_id
OUTER APPLY sys.dm_exec_sql_text(conn_bl.most_recent_sql_handle) AS txt_bl
OUTER APPLY sys.dm_exec_sql_text(conn_bk.most_recent_sql_handle) AS txt_bk
OUTER APPLY sys.dm_exec_query_plan(conn_bl.most_recent_sql_handle) AS qp
WHERE wt.blocking_session_id IS NOT NULL
  AND wt.blocking_session_id <> wt.session_id
ORDER BY wt.wait_duration_ms DESC;

-- Este funciona para ver que es lo que esta ejecutando pero ya no lo ocupas porque la query te lo dice
-- DBCC INPUTBUFFER (59)   -- num session_id

-- Para cerrar el Proceso utiliza kill
-- kill 80 

```

### Obtener los locks usando la vista dm_tran_locks
```SQL
/*
Sch-S (Schema Stability): Este modo de bloqueo se utiliza cuando una transacción intenta adquirir un bloqueo de esquema (Schema Lock)
 para un objeto. Este tipo de bloqueo permite que otros procesos puedan realizar consultas pero evita que realicen modificaciones
 que puedan interferir con la estructura del esquema del objeto.

S (Shared): El bloqueo compartido permite que múltiples transacciones puedan leer datos simultáneamente, pero ninguna de ellas puede
realizar modificaciones mientras el bloqueo está activo. Este tipo de bloqueo es compatible con otros bloqueos compartidos pero no
con bloqueos exclusivos.

U (Update): Indica un bloqueo de actualización. Este bloqueo se adquiere cuando una transacción necesita realizar una modificación
en un recurso y no quiere permitir que otros procesos realicen cambios simultáneos.

X (Exclusive): El bloqueo exclusivo es el tipo más restrictivo de bloqueo. Se adquiere cuando una transacción necesita realizar
 una modificación en un recurso y no permite que otros procesos realicen ninguna operación (lectura o escritura) en ese recurso
hasta que se libere el bloqueo.

IS (Intent Shared): Este tipo de bloqueo indica la intención de adquirir un bloqueo compartido en un recurso más específico dentro
de una jerarquía. Ayuda a evitar bloqueos incoherentes en la jerarquía de bloqueos.

IU (Intent Update): Similar al IS, indica la intención de adquirir un bloqueo de actualización en un recurso más específico dentro
 de una jerarquía de bloqueos.

IX (Intent Exclusive): Indica la intención de adquirir un bloqueo exclusivo en un recurso más específico dentro de una jerarquía
de bloqueos.

*/

SELECT DISTINCT
    bl.request_session_id AS Proceso_Bloqueador,
    bk.request_session_id AS Proceso_Bloqueado,
    CAST(ISNULL(req_bk.wait_time / 60000.0, 0) AS DECIMAL(10,2)) AS TiempoBloqueado_Minutos,

    -- Información del bloqueador
    ses_bl.status AS Bloqueador_Status,
    ses_bl.login_name AS Bloqueador_Login,
    ses_bl.host_name AS Bloqueador_Host,
    DB_NAME(ses_bl.database_id) AS Bloqueador_BaseDatos,
    ses_bl.cpu_time AS Bloqueador_CPU_Time,
    ses_bl.memory_usage AS Bloqueador_MemoriaKB,
    ISNULL(txt_bl.text, 'No hay query registrada') AS Bloqueador_UltimaQuery,

    -- Información del bloqueado
    ses_bk.status AS Bloqueado_Status,
    ses_bk.login_name AS Bloqueado_Login,
    ses_bk.host_name AS Bloqueado_Host,
    DB_NAME(ses_bk.database_id) AS Bloqueado_BaseDatos,
    ses_bk.cpu_time AS Bloqueado_CPU_Time,
    ses_bk.memory_usage AS Bloqueado_MemoriaKB,
    ISNULL(txt_bk.text, 'No hay query registrada') AS Bloqueado_UltimaQuery
FROM sys.dm_tran_locks bk
INNER JOIN sys.dm_tran_locks bl 
    ON bk.resource_type = bl.resource_type
    AND bk.resource_description = bl.resource_description
    AND bk.request_status = 'WAIT'
    AND bl.request_status = 'GRANT'
INNER JOIN sys.dm_exec_sessions ses_bk ON bk.request_session_id = ses_bk.session_id
INNER JOIN sys.dm_exec_sessions ses_bl ON bl.request_session_id = ses_bl.session_id
LEFT JOIN sys.dm_exec_requests req_bk ON ses_bk.session_id = req_bk.session_id
LEFT JOIN sys.dm_exec_connections conn_bl ON ses_bl.session_id = conn_bl.session_id
LEFT JOIN sys.dm_exec_connections conn_bk ON ses_bk.session_id = conn_bk.session_id
OUTER APPLY sys.dm_exec_sql_text(conn_bl.most_recent_sql_handle) AS txt_bl
OUTER APPLY sys.dm_exec_sql_text(conn_bk.most_recent_sql_handle) AS txt_bk
WHERE bk.request_session_id <> bl.request_session_id
ORDER BY TiempoBloqueado_Minutos DESC;
```









# Waits 
### **¿Por qué monitorear los waits?**

Porque las **esperas (waits)** indican que una tarea en SQL Server está detenida esperando un recurso (CPU, memoria, disco, red, bloqueos, etc.). Son una señal directa de cuellos de botella en el sistema y ayudan a entender dónde está el problema de rendimiento.

### **¿Para qué sirven?**

Los waits son **indicadores de dónde está el cuello de botella** en tu sistema.  
Analizando los tipos y tiempos de espera, puedes saber si el problema está en:

*   **CPU** (signal waits altos → falta de CPU).
*   **Disco / I/O** (esperas como `PAGEIOLATCH` → acceso lento a disco).
*   **Bloqueos** (esperas como `LCK_M_...` → contención entre transacciones).
*   **Memoria** (esperas como `RESOURCE_SEMAPHORE` → falta de memoria para ejecutar consultas).

Si no se controlan, pueden provocar:

*   Lentitud general en consultas.
*   Bloqueos prolongados.
*   Saturación de recursos (CPU, I/O, memoria).
*   Deadlocks y baja disponibilidad.
 
### **¿Qué valido al monitorearlos?**

*   **Tipo de espera (wait\_type):** Para identificar el recurso que causa la espera (Memory, Lock, I/O, Network, etc.).
*   **Duración de la espera:** Cuánto tiempo lleva esperando la tarea.
*   **Cantidad de tareas esperando:** Si hay muchas, indica contención grave.
*   **Categoría de espera:** Agrupación lógica (Memory, Lock, Buffer I/O, Logging, etc.) para priorizar análisis.
*   **Sesión y query involucrada:** Para saber qué proceso está afectado y optimizarlo.
*   **Patrones repetitivos:** Si siempre ocurre el mismo tipo de espera, hay un problema estructural (ej. falta de índices, hardware insuficiente).

### **Analogía del restaurante:**

Imagina que eres un cliente en un restaurante:

1.  **Llegas y pides una mesa**:
    *   Aquí empieza tu **espera total** (`wait_time_ms`).
    *   No hay mesas libres , así que esperas en la lista posiblemente porque esta lleno, no hay comida o otra cosas (Bloqueo, Memoria, I/O o CPU).

2.  **Te asignan una mesa, pero el mesero está ocupado**:
    *   Ahora ya tienes el recurso (la mesa), pero el mesero no puede atenderte todavía.
    *   Este tiempo es el **signal wait** (`signal_wait_time_ms`): tienes la mesa, pero esperas la señal del mesero para comenzar a ordenar.

3.  **Finalmente el mesero viene y toma tu orden**:
    *   Termina la espera.


### **Relación práctica:**

*   Si **`signal_wait_time_ms`** es alto, significa que el CPU está saturado: las tareas tienen recursos listos, pero no hay suficiente CPU para atenderlas.
*   Si **`wait_time_ms`** es alto y **`signal_wait_time_ms`** es bajo, el problema está en la disponibilidad del recurso (por ejemplo, bloqueos, I/O lento).

```sql
-- select * from sys.all_objects  where name like '%wait%'

WITH Waits AS
(
    SELECT 
        wait_type,
        wait_duration_ms
    FROM sys.dm_os_waiting_tasks
)
SELECT 
    Categoria,
    COUNT(*) AS CantidadEsperas,
    SUM(wait_duration_ms) AS TiempoAcumulado_ms,
    AVG(wait_duration_ms) AS TiempoPromedio_ms,
    Descripcion
FROM
(
    SELECT 
        CASE 
            WHEN wait_type LIKE 'MEMORY_%' OR wait_type IN ('RESOURCE_SEMAPHORE', 'CMEMTHREAD') THEN 'Memory'
            WHEN wait_type LIKE 'SQLCLR%' THEN 'SQLCLR'
            WHEN wait_type LIKE 'BUFFER_LATCH%' THEN 'Buffer Latch'
            WHEN wait_type LIKE 'LATCH_%' THEN 'Latch'
            WHEN wait_type LIKE 'NETWORK%' THEN 'Network I/O'
            WHEN wait_type LIKE 'WRITELOG' OR wait_type LIKE 'LOG%' THEN 'Logging'
            WHEN wait_type LIKE 'PAGEIOLATCH%' THEN 'Buffer I/O'
            WHEN wait_type LIKE 'LCK_%' THEN 'Lock'
            ELSE 'Other'
        END AS Categoria,
        wait_duration_ms,
        CASE 
            WHEN wait_type LIKE 'MEMORY_%' OR wait_type IN ('RESOURCE_SEMAPHORE', 'CMEMTHREAD') 
                THEN 'Esperas relacionadas con asignación de memoria y semáforos.'
            WHEN wait_type LIKE 'SQLCLR%' 
                THEN 'Esperas por ejecución de código CLR (Common Language Runtime) en SQL Server.'
            WHEN wait_type LIKE 'BUFFER_LATCH%' 
                THEN 'Esperas para acceder a páginas en memoria (buffer pool).'
            WHEN wait_type LIKE 'LATCH_%' 
                THEN 'Esperas por estructuras internas de sincronización (latches).'
            WHEN wait_type LIKE 'NETWORK%' 
                THEN 'Esperas por operaciones de red, envío/recepción de datos.'
            WHEN wait_type LIKE 'WRITELOG' OR wait_type LIKE 'LOG%' 
                THEN 'Esperas por escritura en el log de transacciones.'
            WHEN wait_type LIKE 'PAGEIOLATCH%' 
                THEN 'Esperas por lectura/escritura de páginas en disco (I/O).'
            WHEN wait_type LIKE 'LCK_%' 
                THEN 'Esperas por bloqueos (locks) en recursos como filas, páginas o tablas.'
            ELSE 'Otras esperas no clasificadas.'
        END AS Descripcion
    FROM Waits
    WHERE wait_type NOT IN ('SLEEP_TASK','BROKER_EVENTHANDLER','BROKER_RECEIVE_WAITFOR','SQLTRACE_BUFFER_FLUSH','CLR_SEMAPHORE')
) AS Categorias
GROUP BY Categoria, Descripcion
ORDER BY TiempoAcumulado_ms DESC;


 
 
-- Estadísticas históricas de todos los tipos de espera con descripción y causa
-- https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/
WITH Waits AS (
    select 
	    wait_type, -- Tipo de Wait
	    waiting_tasks_count, -- Cantidad de transacciones que esperaron 
	    CAST(wait_time_ms  AS DECIMAL(18,2)) as total_time_ms, -- Tiempo total en ms de un wait por tema de algun (Bloqueo +  I/O + Memoria + CPU )
	    CAST((wait_time_ms - signal_wait_time_ms)  AS DECIMAL(18,2)) as total_time_ms_no_cpu , -- Tiempo  total en ms de un wait por tema de algun (Bloqueo + I/O + Memoria  ) pero no de CPU 
        CAST(signal_wait_time_ms  AS DECIMAL(18,2)) as total_time_cpu_ms, -- Tiempo de espera solo de CPU 
		CAST(ws.wait_time_ms * 1.0 / NULLIF(ws.waiting_tasks_count, 0) AS DECIMAL(18,2)) AS avg_wait_ms,-- promedio de espera en ms por un wait junto con el CPU 
		CAST((ws.wait_time_ms - ws.signal_wait_time_ms) * 1.0 / NULLIF(ws.waiting_tasks_count, 0) AS DECIMAL(18,2)) AS avg_resource_wait_m, --- promedio de espera en ms por un wait solo de   (Bloqueo + I/O + Memoria  ) sin el CPU
	    --CAST(signal_wait_time_ms * 100.0 / NULLIF(wait_time_ms, 0) AS DECIMAL(10,2)) AS signal_ratio_percent, -- Porcentaje de % de espera por CPU


        -- Diagnóstico basado en signal wait
        CASE 
            WHEN CAST(100.0 * signal_wait_time_ms / NULLIF(wait_time_ms, 0) AS DECIMAL(10,2)) > 30 
                THEN 'URGENTE: Cuello de botella en CPU'
            WHEN CAST(100.0 * signal_wait_time_ms / NULLIF(wait_time_ms, 0) AS DECIMAL(10,2)) BETWEEN 15 AND 30 
                THEN 'ATENCIÓN: Posible presión de CPU'
            ELSE 'Investigación: Recurso externo (Disco, Memoria, Lock y CPU)'
        END AS prioridad_diagnostico,
		-- 100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum],
		    CASE 
        WHEN ws.wait_type LIKE 'PAGEIOLATCH_%' AND ((ws.wait_time_ms - ws.signal_wait_time_ms) * 1.0 / NULLIF(ws.waiting_tasks_count, 0)) >= 20 THEN 'CRITICO'
        WHEN ws.wait_type = 'WRITELOG' AND ((ws.wait_time_ms - ws.signal_wait_time_ms) * 1.0 / NULLIF(ws.waiting_tasks_count, 0)) >= 10 THEN 'CRITICO'
        WHEN ws.wait_type = 'LOGBUFFER' AND ((ws.wait_time_ms - ws.signal_wait_time_ms) * 1.0 / NULLIF(ws.waiting_tasks_count, 0)) >= 5 THEN 'ALTO'
        WHEN ws.wait_type IN ('ASYNC_IO_COMPLETION','IO_COMPLETION') AND ((ws.wait_time_ms - ws.signal_wait_time_ms) * 1.0 / NULLIF(ws.waiting_tasks_count, 0)) >= 50 THEN 'ALTO'
        WHEN ws.wait_type = 'BACKUPIO' AND ((ws.wait_time_ms - ws.signal_wait_time_ms) * 1.0 / NULLIF(ws.waiting_tasks_count, 0)) >= 100 THEN 'ALTO'
        WHEN ws.wait_type = 'IO_RETRY' AND ws.waiting_tasks_count > 0 THEN 'CRITICO'
        ELSE 'ESTABLE'
    END AS criticidad
    FROM sys.dm_os_wait_stats as ws
    WHERE 
    waiting_tasks_count > 0 AND
    wait_type NOT IN (
		'SLEEP_TASK','SLEEP_SYSTEMTASK','LAZYWRITER_SLEEP',
		'CHECKPOINT_QUEUE','LOGMGR_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH',
		'XE_TIMER_EVENT','FT_IFTS_SCHEDULER_IDLE_WAIT',
		'BROKER_EVENTHANDLER','BROKER_RECEIVE_WAITFOR',
		'SQLTRACE_INCREMENTAL_FLUSH_SLEEP','SQLTRACE_WAIT_ENTRIES',
		'DIRTY_PAGE_POLL','LOGMGR_RESERVE_APPEND','LOGMGR_FLUSH',
		'DISPATCHER_QUEUE_SEMAPHORE','FT_IFTSHC_MUTEX','XE_DISPATCHER_JOIN',
		'XE_DISPATCHER_WAIT','XE_DISPATCHER_SHUTDOWN','XE_SESSION_CREATE',
		'XE_SESSION_TERMINATE','XE_BUFFERMGR_ALLPROCESSED_EVENT',
		'XE_BUFFERMGR_FREEBUF_EVENT','XE_BUFFERMGR_FREEBUF_SINGLE_EVENT',
		'XE_BUFFERMGR_FREEBUF_WAIT','XE_BUFFERMGR_FREEBUF_SINGLE_WAIT',
		'XE_BUFFERMGR_FREEBUF_SHUTDOWN','XE_BUFFERMGR_FREEBUF_SHUTDOWN_WAIT',
		'HADR_FILESTREAM_IOMGR_IOCOMPLETION','HADR_WORK_QUEUE','HADR_TIMER_TASK',
		'BROKER_TO_FLUSH','BROKER_TASK_STOP','BROKER_TRANSMITTER',
		'BROKER_CONNECTION_RECEIVE','BROKER_CONNECTION_SEND',
		'BROKER_CONNECTION_ACCEPT','BROKER_CONNECTION_CLOSE','SQLTRACE_BUFFER_FLUSH','CLR_SEMAPHORE'
      )


),
WaitTypes AS (
	SELECT
	    WaitType,
	    Descripcion,
	    CausaComun
	FROM (
	    VALUES
	    -- Bloqueos (Locks) y Latches en Memoria
	    ('LCK_M_X', 'Esperando un Bloqueo Exclusivo para modificar un recurso (fila, página, tabla).', 'Transacciones largas o conflictos de escritura. Dos o más procesos quieren modificar lo mismo al mismo tiempo.'),
	    ('LCK_M_S', 'Esperando un Bloqueo Compartido para leer un recurso.', 'Lectores bloqueados por Escritores. Una transacción de escritura (X) está reteniendo el recurso, impidiendo la lectura (S).'),
	    ('LCK_M_U', 'Esperando un Bloqueo de Actualización. Bloqueo intermedio para evitar deadlocks antes de la escritura.', 'Contención por Actualización. Múltiples procesos intentan actualizar la misma fila o página.'),
	    ('LCK_M_SCH_M', 'Esperando un Bloqueo de Modificación de Esquema.', 'Cambios de Estructura. Un proceso está realizando un ALTER TABLE o DROP INDEX, bloqueando cualquier acceso.'),
	    ('LCK_M_SCH_S', 'Esperando un Bloqueo de Estabilidad de Esquema.', 'Consulta de Larga Duración. Una consulta compleja requiere garantizar que la estructura de la tabla no cambie.'),
	    ('PAGELATCH_EX', 'Esperando un Latch Exclusivo en Memoria. Un proceso quiere modificar una página que ya está en el Buffer Pool.', 'Contención de Escritura en Memoria. Procesos con alta concurrencia intentan modificar la misma página ("página caliente").'),
	    ('PAGELATCH_SH', 'Esperando un Latch Compartido en Memoria. Un proceso quiere leer una página que ya está en el Buffer Pool.', 'Contención de Lectura en Memoria. Múltiples procesos leen la misma página caliente constantemente.'),
	    ('PAGELATCH_UP', 'Esperando un Latch de Actualización en Memoria. Un proceso quiere reservar la página para modificarla mientras otros la leen.', 'Contención en Memoria. Muchos lectores intentan convertirse en escritores en la misma página con alta frecuencia.'),
	    ('PAGELATCH_KP', 'Latch en páginas clave (Key Pages).', 'Contención interna en estructuras críticas en memoria.'),
	    ('LCK_M_IU', 'Bloqueo de intención de actualización.', 'Preparación para actualizar filas, puede generar contención.'),
	    ('LCK_M_IS', 'Bloqueo de intención compartida.', 'Lecturas concurrentes que bloquean actualizaciones.'),
	    ('LCK_M_IX', 'Bloqueo de intención exclusiva.', 'Preparación para operaciones de escritura.'),
	    ('LCK_M_BU', 'Bloqueo de actualización masiva (Bulk Update).', 'Operaciones masivas que bloquean recursos.'),
	
	    -- I/O (Input/Output) y Disco
	    ('WRITELOG', 'Esperando la confirmación de que la escritura en el Log de Transacciones está completa en el disco.', 'Log de Transacciones Lento. El disco que aloja el archivo .LDF tiene una latencia de escritura muy alta.'),
	    ('PAGEIOLATCH_SH', 'Esperando Leer una página del disco a la memoria (Buffer Pool).', 'Latencia de I/O en Lectura. El disco es lento para responder a las solicitudes de lectura de datos.'),
	    ('PAGEIOLATCH_EX', 'Esperando Cargar una página del disco a la memoria con el objetivo de escribir en ella.', 'Latencia de I/O en Escritura. El disco es lento para cargar la página previa a la modificación.'),
	    ('PAGEIOLATCH_UP', 'Esperando Cargar una página del disco a la memoria con un latch de actualización (UP).', 'Combinación de Contención e I/O Lenta. Muchos procesos quieren modificar datos, y el disco lento amplifica la espera.'),
	    ('ASYNC_IO_COMPLETION', 'Esperando la finalización de una operación de I/O Asíncrona (no bloqueante, ej. backup, restore).', 'Carga de I/O Pesada o Disco Lento. El sistema de almacenamiento está tardando en completar tareas grandes en segundo plano.'),
	    ('IO_COMPLETION', 'Esperando la finalización de una operación de I/O Genérica o Síncrona.', 'Latencia General del Disco. Problemas de rendimiento en el almacenamiento fuera de la gestión del Buffer Pool.'),
	    ('BACKUPIO', 'Esperando durante la transferencia de datos de un backup o restore.', 'Discos de Backup Lentos. El disco de destino es demasiado lento para la tasa de transferencia de datos.'),
	    ('HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'Espera en operaciones FILESTREAM en Always On.', 'Latencia en I/O FILESTREAM.'),
	
	    -- CPU y Paralelismo
	    ('SOS_SCHEDULER_YIELD', 'El hilo de SQL Server cede voluntariamente la CPU para que otros hilos puedan ejecutarse.', 'Presión Alta de CPU. El servidor está saturado de trabajo y las consultas tienen que esperar su turno para procesar.'),
	    ('CXPACKET', 'Esperando que los hilos paralelos en una consulta se sincronicen y avancen juntos.', 'Paralelismo Excesivo o Desbalanceado. El grado de paralelismo (MAXDOP) es demasiado alto, o el plan de ejecución está desequilibrado.'),
	    ('CXCONSUMER', 'Un hilo consumidor de un plan paralelo está esperando que un hilo productor le entregue filas.', 'Procesamiento Paralelo Desbalanceado. La producción de datos entre los hilos no es uniforme (sesgo de datos).'),
	    ('CXROWSET_SYNC', 'Sincronización en operaciones paralelas con rowsets.', 'Paralelismo en consultas complejas.'),
	    ('THREADPOOL', 'Espera por disponibilidad de hilos.', 'Alta concurrencia, falta de recursos en el pool de threads.'),
	
	    -- Memoria
	    ('RESOURCE_SEMAPHORE', 'Esperando que se le asigne memoria para ejecutar una consulta (Memory Grant).', 'Consultas Hambrientas de Memoria. Consultas grandes (ej. sorts, hashes) están esperando por la asignación de RAM disponible.'),
	    ('LOGBUFFER', 'Esperando espacio en el buffer para escribir entradas del Log de Transacciones.', 'Log de I/O Lento y Transacciones Masivas. El buffer se llena porque la escritura en disco no lo vacía lo suficientemente rápido.'),
	    ('MEMORY_ALLOCATION_EXT', 'Problemas internos de asignación de memoria.', 'Presión de memoria o fragmentación interna.'),
	
	    -- Red y Conectividad
	    ('ASYNC_NETWORK_IO', 'Esperando la confirmación de que los datos fueron enviados y consumidos por el cliente.', 'Aplicación Cliente Lenta. El cliente está tardando en aceptar los resultados del servidor.'),
	    ('NETWORK_IO', 'Esperando la finalización de operaciones de red genéricas.', 'Latencia o Saturación de la Red. Problemas de comunicación entre el servidor y el cliente.'),
	
	    -- Always On y Service Broker
	    ('HADR_SYNC_COMMIT', 'Esperando la confirmación de que la transacción fue confirmada en la réplica secundaria sincrónica.', 'Latencia entre Réplicas. La red o el disco del servidor secundario son lentos.'),
	    ('BROKER_TRANSMITTER', 'Espera en transmisión de mensajes del Service Broker.', 'Procesamiento de colas o problemas de red.'),
	    ('BROKER_TO_FLUSH', 'Espera por vaciado de mensajes en Service Broker.', 'Procesamiento interno para enviar mensajes pendientes en colas.'),
	
	    -- Otros/Internos
	    ('FT_IFTS_SCHEDULER_IDLE_WAIT', 'Espera en tareas de índice de texto completo.', 'Procesamiento de índices full-text.'),
	    ('PREEMPTIVE_OS_AUTHENTICATION', 'Espera por autenticación en el sistema operativo.', 'Problemas de autenticación externa.'),
	    ('QDS_ASYNC_QUEUE', 'Espera en cola asíncrona del Query Data Store.', 'Carga alta en Query Store o mantenimiento.'),
	    ('WAIT_XTP_HOST_WAIT', 'Espera relacionada con operaciones In-Memory OLTP.', 'Procesamiento de tablas optimizadas para memoria.'),
	    ('XTP_PREEMPTIVE_TASK', 'Espera por tareas preemptivas en In-Memory OLTP.', 'Operaciones internas de memoria.'),
	    ('PVS_PREALLOCATE', 'Espera por preasignación de recursos internos.', 'Inicialización de estructuras internas.'),
	    ('FT_IFTSHC_MUTEX', 'Espera por mutex en índice de texto completo.', 'Contención en operaciones full-text.'),
	    ('ONDEMAND_TASK_QUEUE', 'Espera en cola de tareas bajo demanda.', 'Procesamiento interno de tareas diferidas.'),
	    ('KSOURCE_WAKEUP', 'Espera por activación de fuente de eventos.', 'Procesamiento interno de eventos.'),
	    ('CLR_AUTO_EVENT', 'Espera por eventos automáticos en CLR.', 'Operaciones internas del CLR.'),
	    ('SP_SERVER_DIAGNOSTICS_SLEEP', 'Espera durante diagnóstico del servidor.', 'Proceso interno de salud del servidor.'),
	    ('QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', 'Espera en persistencia de Query Store.', 'Grabación de datos en Query Store.'),
	    ('CHECKPOINT_QUEUE', 'Espera en cola de checkpoints.', 'Procesamiento de páginas sucias en disco.'),
	    ('SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'Espera en flush incremental de SQL Trace.', 'Procesamiento interno de trazas.'),
	    ('REQUEST_FOR_DEADLOCK_SEARCH', 'Espera en búsqueda de deadlocks.', 'Proceso interno para detectar bloqueos.'),
	    ('XE_DISPATCHER_WAIT', 'Espera en despachador de eventos extendidos.', 'Procesamiento de eventos XE.'),
	    ('XE_TIMER_EVENT', 'Espera en temporizador de eventos extendidos.', 'Procesamiento interno de XE.'),
	    ('LAZYWRITER_SLEEP', 'Espera del Lazy Writer.', 'Liberación de páginas en buffer pool.'),
	    ('LOGMGR_QUEUE', 'Espera en cola del Log Manager.', 'Procesamiento interno del log.'),
	    ('DIRTY_PAGE_POLL', 'Espera en sondeo de páginas sucias.', 'Proceso interno para escribir páginas modificadas.'),
	    ('SOS_WORK_DISPATCHER', 'Espera en el despachador de trabajos del Scheduler.', 'Procesamiento interno de tareas en el motor de SQL Server.')
	
	) AS WT(WaitType, Descripcion, CausaComun)
 
)
SELECT 
    W.wait_type,
    W.waiting_tasks_count AS CantidadWaits,
	W.total_time_ms,
	W.total_time_ms_no_cpu,
	W.total_time_cpu_ms,
	W.avg_wait_ms,
	W.avg_resource_wait_m,
	--W.signal_ratio_percent,
	W.prioridad_diagnostico,
	WT.Descripcion,
    WT.CausaComun,
	criticidad
	,W.[RowNum]
FROM Waits W
LEFT JOIN WaitTypes WT ON W.wait_type = WT.WaitType
/*
WHERE 
    -- PAGEIOLATCH_*: Espera por lectura de páginas desde DISCO al buffer pool (indica almacenamiento lento o falta de memoria).
	--     Acciones: Aumentar **RAM** para reducir lecturas desde disco, revisar **missing indexes**, optimizar consultas, validar **latencias del storage** y **read throughput**.
    W.wait_type LIKE 'PAGEIOLATCH_%'
    OR 
    -- WRITELOG: Espera para escribir el TRANSACTION LOG (cuello de botella en el disco del log).
	-- Acciones: Asegurar que el **log esté en un volumen dedicado y rápido** (idealmente SSD), revisar **tamaño inicial** y **autogrowth** (evitar muchos crecimientos pequeños), confirmar que no haya **contenión** por VMs/host.
    W.wait_type = 'WRITELOG'
    OR
    -- LOGBUFFER: Espera para copiar datos al buffer del log antes de escribir en disco (si sube junto con WRITELOG, problemático).
	--     Acciones: Corrobora el cuello en log. Revisa **flushes**, **tamaño del buffer**, frecuencia de **commits**.
    W.wait_type = 'LOGBUFFER'
    OR 
    -- BACKUPIO: Espera durante operaciones de backup (disco de destino lento o red lenta si es backup a share).
	--     Acciones: Optimiza ventana y destino de **backup**, usa `COPY_ONLY` en escenarios específicos, valida velocidad del almacenamiento o share.
    W.wait_type = 'BACKUPIO'
    OR 
    -- IO_COMPLETION: Espera por operaciones de I/O asincrónicas (backups/restores/operaciones de archivos).
	--     Acciones: Optimiza ventana y destino de **backup**, usa `COPY_ONLY` en escenarios específicos, valida velocidad del almacenamiento o share.
    W.wait_type = 'IO_COMPLETION'
    OR 
    -- ASYNC_IO_COMPLETION: Espera por I/O asincrónico en archivos de BD (crecimiento, creación de archivos).
	--     Acciones: Configurar **autogrowth grande y fijo**, pre-crear tamaño adecuado, revisar **instant file initialization** (solo para data files; no aplica a log).
    W.wait_type = 'ASYNC_IO_COMPLETION'
    OR 
    -- IO_RETRY: SQL Server reintenta operaciones de I/O por errores temporales (posibles fallos físicos del disco o controlador).
	--     Acciones: Revisar **event logs**, **firmware de storage**, **drivers**, **multipathing**, **timeouts**; posible problema **físico**.
    W.wait_type = 'IO_RETRY'
*/
order by  avg_resource_wait_m desc ;
```




# I/O

### **¿Por qué monitorear el I/O?**

Porque las operaciones de **entrada/salida** son críticas para el rendimiento de SQL Server: implican lectura y escritura de datos en disco y en memoria. Si el I/O es lento, las consultas se retrasan, los bloqueos se prolongan y el throughput general del sistema cae.

Problemas comunes si no se controla:

*   Cuellos de botella en disco.
*   Alta latencia en lectura/escritura.
*   Saturación del buffer pool.
*   Esperas prolongadas por PAGEIOLATCH (lectura) o WRITELOG (escritura).
*   Impacto en transacciones críticas y procesos batch.
 

### **¿Qué valido al monitorearlo?**

*   **Tasa de I/O (MB/s):** Cuánto se está leyendo/escribiendo en disco.
*   **Tipos de espera relacionados:** PAGEIOLATCH (lectura), WRITELOG (escritura), IO\_COMPLETION.
*   **Duración de las esperas:** Si son altas, indica problemas de disco o almacenamiento.
*   **Contención en buffer pool:** Si hay muchas esperas por Buffer I/O.
*   **Patrones de uso:** Si hay picos durante backups, cargas masivas o consultas grandes.
*   **Impacto en queries:** Identificar qué procesos generan más I/O para optimizarlos.

```sql

-- muestra todas las solicitudes de I/O que están pendientes en el nivel del subsistema de almacenamiento.
  SELECT * from sys.dm_io_pending_io_requests ;
  SELECT * FROM sys.dm_io_virtual_file_stats(NULL, NULL);

--  ✅ Consultar cantidad de escritura y lectura (UPDATE,DELETE,INSERT,SELECT):
-- ⚠ **Notas importantes:**
-- 
-- *   Estas estadísticas se reinician al reiniciar SQL Server.
-- *   Solo reflejan actividad desde el último reinicio.
-- *   Si quieres ver actividad en tiempo real, necesitarías Extended Events o Profiler.


---- Cantidad de lecutras, escrituras , promedio y tiempo de respuesta por files mdf , ldf y ndf  

 
SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS file_name,
    mf.type_desc AS file_type,
    vfs.num_of_reads, -- número total de operaciones de lectura
    vfs.num_of_writes,
    vfs.io_stall_read_ms, -- tiempo total en ms que las lecturas esperaron
    vfs.io_stall_write_ms,
    (vfs.io_stall_read_ms + vfs.io_stall_write_ms) AS total_io_stall_ms, 
    CASE WHEN vfs.num_of_reads > 0 THEN vfs.io_stall_read_ms / vfs.num_of_reads ELSE 0 END AS avg_read_latency_ms,
    CASE WHEN vfs.num_of_writes > 0 THEN vfs.io_stall_write_ms / vfs.num_of_writes ELSE 0 END AS avg_write_latency_ms,

    -- Nivel textual según el peor caso (read/write)
    CASE 
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 500) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 500)
             ) THEN 'Severe'
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 100) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 100)
             ) THEN 'Critical'
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 20) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 20)
             ) THEN 'Poor'
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 10) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 10)
             ) THEN 'Fair'
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  >= 5) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes >= 5)
             ) THEN 'Good'
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  >= 1) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes >= 1)
             ) THEN 'Excellent'
        ELSE 'Outstanding'
    END AS nivel,

    -- Ranking numérico (para ordenar: 7 = peor, 1 = mejor)
    CASE 
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 500) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 500)
             ) THEN 7  -- Severe - Grave
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 100) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 100)
             ) THEN 6  -- Critical - Crítico
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 20) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 20)
             ) THEN 5  -- Poor - Deficiente:
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  > 10) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes > 10)
             ) THEN 4  -- Fair - Regular
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  >= 5) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes >= 5)
             ) THEN 3  -- Good - Bueno
        WHEN (
              (vfs.num_of_reads  > 0 AND vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads  >= 1) OR
              (vfs.num_of_writes > 0 AND vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes >= 1)
             ) THEN 2  -- Excellent - Excelente:
        ELSE 1          -- Outstanding - Sobresaliente
    END AS nivel_rank,

    vfs.size_on_disk_bytes / 1024 / 1024 AS size_mb, -- tamaño actual del archivo en disco, expresado en bytes
	mf.physical_name AS PhysicalFileName,
    
    --DATEDIFF(SECOND, sysinfo.sqlserver_start_time, GETDATE()) AS uptime_seconds,  -- Calcular segundos desde inicio
    -- sample_ms : cantidad total de tiempo, en milisegundos (ms), que la instancia de SQL Server ha estado midiendo la actividad de E/S (Entrada/Salida)

    -- NOTA: los IOPS representados son por archivo no por base de datos, para obtener el verdadero IOPS tienes que hacer la suma de todos sus files mdf y ldf o ndf 
    -- Read IOPS (Lecturas por Segundo)
    CAST((vfs.num_of_reads * 1000.0) / NULLIF(vfs.sample_ms, 0) AS DECIMAL(18,2)) AS read_iops,
    
    -- Write IOPS (Escrituras por Segundo)
    CAST((vfs.num_of_writes * 1000.0) / NULLIF(vfs.sample_ms, 0) AS DECIMAL(18,2)) AS write_iops,
    
    -- Total IOPS
    CAST(((vfs.num_of_reads + vfs.num_of_writes) * 1000.0) / NULLIF(vfs.sample_ms, 0) AS DECIMAL(18,2)) AS total_iops

FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf 
  ON vfs.database_id = mf.database_id 
 AND vfs.file_id     = mf.file_id
CROSS JOIN sys.dm_os_sys_info AS sysinfo
ORDER BY nivel_rank DESC, total_io_stall_ms DESC;


 
--- Ver cantidad de lecutras y escrituras por tabla
WITH alltables
AS (
 SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    fg.name AS FileGroupName,
    -- Tamaño total (datos + índices)
    CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(18,2)) AS TotalSizeMB,
    -- Solo datos (heap o índice clustered)
    CAST(SUM(CASE WHEN i.type IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS DataSizeKB,
    -- Solo índices (nonclustered, XML, spatial, etc.)
    CAST(SUM(CASE WHEN i.type NOT IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS IndexSizeKB,
    CASE 
        WHEN COUNT(DISTINCT p.partition_number) > 1 THEN 'Sí'
        ELSE 'No'
    END AS IsPartitioned,
    COUNT(DISTINCT p.partition_number) AS PartitionCount,
    SUM(ps.row_count) AS TotalRows,
    t.create_date AS FechaCreacion,
    p.data_compression_desc AS TipoCompresion

FROM sys.tables AS t
LEFT JOIN sys.schemas AS s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
LEFT JOIN sys.filegroups AS fg ON i.data_space_id = fg.data_space_id 
LEFT JOIN sys.dm_db_partition_stats AS ps ON p.partition_id = ps.partition_id
GROUP BY s.name, t.name, fg.name,t.create_date,p.data_compression_desc
)
 
SELECT 
top 10
    OBJECT_NAME(s.[object_id]) AS Tabla,
    FileGroupName,
    SUM(s.leaf_insert_count) AS Cantidad_Inserts,
    SUM(s.leaf_update_count) AS Cantidad_Updates,
    SUM(s.leaf_delete_count) AS Cantidad_Deletes,
    SUM(u.user_seeks + u.user_scans + u.user_lookups) AS TotalLecturas,
    SUM(s.leaf_insert_count + s.leaf_update_count + s.leaf_delete_count) AS totalEscrituras,
    TotalSizeMB,DataSizeKB,IndexSizeKB, FechaCreacion,TipoCompresion,IsPartitioned,PartitionCount  ,TotalRows
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS s
INNER JOIN sys.dm_db_index_usage_stats AS u
    ON s.[object_id] = u.[object_id] AND s.index_id = u.index_id
INNER JOIN sys.objects AS o ON s.[object_id] = o.[object_id]
LEFT JOIN alltables AS J ON OBJECT_NAME(s.[object_id])= j.TableName
WHERE o.type = 'U' -- Solo tablas de usuario
GROUP BY s.[object_id], j.TotalSizeMB, j.DataSizeKB, j.IndexSizeKB,FechaCreacion,TipoCompresion,PartitionCount,IsPartitioned,PartitionCount ,TotalRows,FileGroupName
-- HAVING j.TotalSizeMB > 500 -- ocupa mucho espacio (>500 MB)
--   AND SUM(s.leaf_insert_count + s.leaf_update_count + s.leaf_delete_count) < 10000 -- pocas escrituras
  -- AND SUM(u.user_seeks + u.user_scans + u.user_lookups) > 10000 -- muchas lecturas
ORDER BY j.TotalSizeMB DESC, TotalLecturas DESC;
--ORDER BY TotalSizeMg desc,  total_Cantidad_escrituras asc  , total_Cantidad_Lecturas desc  





--- Ver por toda la base de datos 
SELECT 
    DB_NAME(u.database_id) as  [dbname],
    SUM(s.leaf_insert_count) AS Cantidad_Inserts,
    SUM(s.leaf_update_count) AS Cantidad_Updates,
    SUM(s.leaf_delete_count) AS Cantidad_Deletes,
    SUM(u.user_seeks + u.user_scans + u.user_lookups) AS Cantidad_Lecturas
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS s
INNER JOIN sys.dm_db_index_usage_stats AS u
    ON s.[object_id] = u.[object_id] AND s.index_id = u.index_id
INNER JOIN sys.objects AS o ON s.[object_id] = o.[object_id]
 WHERE u.database_id= DB_ID()  -- o.type = 'U' -- Solo tablas de usuario
GROUP BY u.database_id
ORDER BY (SUM(s.leaf_insert_count) + SUM(s.leaf_update_count) + SUM(s.leaf_delete_count)) DESC;



--  **Identificar consultas que consumen más I/O**:
 
    SELECT TOP 10
           qs.total_logical_reads, qs.total_physical_reads, qs.execution_count,
           SUBSTRING(qt.text, 1, 200) AS QueryText
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
    ORDER BY qs.total_physical_reads DESC;


-- SQL Server NUMA Node information  (Query 13) (SQL Server NUMA Info)
-- Cada nodo NUMA tiene su propio conjunto de CPU y memoria local.
-- SQL Server optimiza el acceso a memoria y CPU según estos nodos.
-- Permite ver cómo SQL Server distribuye el buffer pool y otras estructuras por nodo.
-- Útil para diagnosticar problemas de rendimiento en servidores con NUMA.
SELECT osn.node_id, osn.node_state_desc, osn.memory_node_id, osn.processor_group, osn.cpu_count, osn.online_scheduler_count, 
       osn.idle_scheduler_count, osn.active_worker_count, 
	   osmn.pages_kb/1024 AS [Committed Memory (MB)], 
	   osmn.locked_page_allocations_kb/1024 AS [Locked Physical (MB)],
	   CONVERT(DECIMAL(18,2), osmn.foreign_committed_kb/1024.0) AS [Foreign Commited (MB)],
	   osmn.target_kb/1024 AS [Target Memory Goal (MB)],
	   osn.avg_load_balance, osn.resource_monitor_state
FROM sys.dm_os_nodes AS osn WITH (NOLOCK)
INNER JOIN sys.dm_os_memory_nodes AS osmn WITH (NOLOCK)
ON osn.memory_node_id = osmn.memory_node_id
WHERE osn.node_state_desc <> N'ONLINE DAC' OPTION (RECOMPILE);


-- Drive level latency information (Query 31) (Drive Level Latency)
SELECT tab.[Drive], tab.volume_mount_point AS [Volume Mount Point], 
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) 
	END AS [Read Latency],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
	END AS [Write Latency],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE (io_stall/(num_of_reads + num_of_writes)) 
	END AS [Overall Latency],
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (num_of_bytes_read/num_of_reads) 
	END AS [Avg Bytes/Read],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (num_of_bytes_written/num_of_writes) 
	END AS [Avg Bytes/Write],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
	END AS [Avg Bytes/Transfer]
FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
	         SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
	         SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
	         SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.volume_mount_point 
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
	  CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs 
      GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.volume_mount_point) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);



-- Calculates average latency per read, per write, and per total input/output for each database file  (Query 32) (IO Latency by File)
-- Latency above 30-40ms is usually a problem 
SELECT DB_NAME(fs.database_id) AS [Database Name], CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_latency_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_latency_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_latency_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io],
io_stall_queued_read_ms AS [Resource Governor Total Read IO Latency (ms)], io_stall_queued_write_ms AS [Resource Governor Total Write IO Latency (ms)] 
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_latency_ms DESC OPTION (RECOMPILE);

 


 -- Get I/O utilization by database (Query 39) (IO Usage By Database)
WITH Aggregate_IO_Statistics
AS (SELECT DB_NAME(database_id) AS [Database Name],
    CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS [ioTotalMB],
    CAST(SUM(num_of_bytes_read ) / 1048576 AS DECIMAL(12, 2)) AS [ioReadMB],
    CAST(SUM(num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS [ioWriteMB]
    FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
    GROUP BY database_id)
SELECT ROW_NUMBER() OVER (ORDER BY ioTotalMB DESC) AS [I/O Rank],
        [Database Name], ioTotalMB AS [Total I/O (MB)],
        CAST(ioTotalMB / SUM(ioTotalMB) OVER () * 100.0 AS DECIMAL(5, 2)) AS [Total I/O %],
        ioReadMB AS [Read I/O (MB)], 
		CAST(ioReadMB / SUM(ioReadMB) OVER () * 100.0 AS DECIMAL(5, 2)) AS [Read I/O %],
        ioWriteMB AS [Write I/O (MB)], 
		CAST(ioWriteMB / SUM(ioWriteMB) OVER () * 100.0 AS DECIMAL(5, 2)) AS [Write I/O %]
FROM Aggregate_IO_Statistics
ORDER BY [I/O Rank] OPTION (RECOMPILE);





-- I/O Statistics by file for the current database  (Query 61) (IO Stats By File)
SELECT DB_NAME(DB_ID()) AS [Database Name], df.name AS [Logical Name], vfs.[file_id], df.type_desc,
df.physical_name AS [Physical Name], CAST(vfs.size_on_disk_bytes/1048576.0 AS DECIMAL(15, 2)) AS [Size on Disk (MB)],
vfs.num_of_reads, vfs.num_of_writes, vfs.io_stall_read_ms, vfs.io_stall_write_ms,
CAST(100. * vfs.io_stall_read_ms/(vfs.io_stall_read_ms + vfs.io_stall_write_ms) AS DECIMAL(10,1)) AS [IO Stall Reads Pct],
CAST(100. * vfs.io_stall_write_ms/(vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(10,1)) AS [IO Stall Writes Pct],
(vfs.num_of_reads + vfs.num_of_writes) AS [Writes + Reads], 
CAST(vfs.num_of_bytes_read/1048576.0 AS DECIMAL(15, 2)) AS [MB Read], 
CAST(vfs.num_of_bytes_written/1048576.0 AS DECIMAL(15, 2)) AS [MB Written],
CAST(100. * vfs.num_of_reads/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(15,1)) AS [# Reads Pct],
CAST(100. * vfs.num_of_writes/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(15,1)) AS [# Write Pct],
CAST(100. * vfs.num_of_bytes_read/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(15,1)) AS [Read Bytes Pct],
CAST(100. * vfs.num_of_bytes_written/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(15,1)) AS [Written Bytes Pct]
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) AS vfs
INNER JOIN sys.database_files AS df WITH (NOLOCK)
ON vfs.[file_id]= df.[file_id] OPTION (RECOMPILE);
```


# CPU
#### **¿Por qué monitoreo el CPU?**

Porque el **procesador** es el recurso principal para ejecutar consultas, procesos internos y operaciones del motor. Si el CPU está saturado, las consultas se vuelven lentas, las tareas en segundo plano se retrasan y el sistema puede quedar inestable.

Problemas comunes si no se controla:

*   Cuellos de botella por alta concurrencia.
*   Consultas mal optimizadas consumiendo CPU excesivo.
*   Bloqueos prolongados por falta de ciclos de CPU.
*   Impacto en procesos críticos como backups, replicación o jobs.

#### **¿Qué valido al monitorearlo?**

*   **% de uso del CPU por SQL Server:** Si está cerca del 100%, hay sobrecarga.
*   **Esperas relacionadas:** SOS\_SCHEDULER\_YIELD (indica presión de CPU).
*   **Consultas más costosas:** Identificar queries que consumen más CPU.
*   **Patrones de uso:** Picos durante horarios específicos o procesos batch.
*   **Impacto en sesiones activas:** Si hay muchas tareas esperando CPU.

```SQL
-- Get CPU utilization by database (Query 38) (CPU Usage by Database)
WITH DB_CPU_Stats
AS
(SELECT pa.DatabaseID, DB_Name(pa.DatabaseID) AS [Database Name], SUM(qs.total_worker_time/1000) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS pa
 GROUP BY DatabaseID)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
       [Database Name], [CPU_Time_Ms] AS [CPU Time (ms)], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE);


-- Get CPU Utilization History for last 256 minutes (in one minute intervals)  (Query 47) (CPU Utilization History)
DECLARE @ts_now bigint = (SELECT ms_ticks FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(256) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM (SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
              record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
                      AS [SystemIdle], 
              record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') 
                      AS [SQLProcessUtilization], [timestamp] 
         FROM (SELECT [timestamp], CONVERT(xml, record) AS [record] 
                      FROM sys.dm_os_ring_buffers WITH (NOLOCK)
                      WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
                      AND record LIKE N'%<SystemHealth>%') AS x) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);
```


# Memoria

#### **¿Por qué monitoreo la memoria?**

Porque la **memoria** es esencial para el rendimiento: SQL Server usa el buffer pool para almacenar páginas y reducir I/O en disco. Si hay poca memoria disponible, se incrementan las lecturas desde disco y las consultas se vuelven lentas.

Problemas comunes si no se controla:

*   Alta presión en el buffer pool.
*   Incremento de PAGEIOLATCH (lecturas desde disco).
*   Uso excesivo por consultas grandes o falta de índices.
*   Fragmentación interna y falta de memoria para operaciones críticas.

#### **¿Qué valido al monitorearla?**

*   **Memoria total asignada vs disponible:** Si SQL Server está cerca del límite.
*   **Esperas relacionadas:** RESOURCE\_SEMAPHORE (indica falta de memoria para ejecutar consultas).
*   **Tamaño del buffer pool:** Si es insuficiente para la carga.
*   **Consultas que consumen mucha memoria:** Para optimizarlas.
*   **Patrones de uso:** Picos durante cargas masivas o procesos ETL.

```SQL
-- SQL Server Process Address space info  (Query 6) (Process Memory)
-- (shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
	   locked_page_allocations_kb/1024 AS [SQL Server Locked Pages Allocation (MB)],
       large_page_allocations_kb/1024 AS [SQL Server Large Pages Allocation (MB)], 
	   page_fault_count, memory_utilization_percentage, available_commit_limit_kb, 
	   process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);


-- Good basic information about OS memory amounts and state  (Query 14) (System Memory)
SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
       available_physical_memory_kb/1024 AS [Available Memory (MB)], 
       total_page_file_kb/1024 AS [Page File Commit Limit (MB)],
	   total_page_file_kb/1024 - total_physical_memory_kb/1024 AS [Physical Page File Size (MB)],
	   available_page_file_kb/1024 AS [Available Page File (MB)], 
	   system_cache_kb/1024 AS [System Cache (MB)],
       system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- Get information on location, time and size of any memory dumps from SQL Server  (Query 23) (Memory Dump Info)
SELECT [filename], creation_time, size_in_bytes/1048576.0 AS [Size (MB)]
FROM sys.dm_server_memory_dumps WITH (NOLOCK) 
ORDER BY creation_time DESC OPTION (RECOMPILE);
 
-- Resource Governor Resource Pool information (Query 34) (RG Resource Pools)
-- Es una característica de SQL Server que permite administrar y limitar el uso de recursos (CPU y memoria) para diferentes cargas de trabajo.
-- 
--    ¿Para qué sirve?
--        Controlar el consumo de recursos por grupos de usuarios o aplicaciones.
--        Evitar que una consulta pesada afecte el rendimiento global.
--    Cómo funciona:
--        Define Pools de recursos (máximo y mínimo de CPU/memoria).
--        Define Grupos de carga de trabajo (workload groups) que asignan sesiones a esos pools.
--    Ejemplo de uso:  
--     Limitar que procesos ETL no consuman toda la memoria y CPU, dejando recursos para consultas OLTP.

SELECT pool_id, [Name], statistics_start_time,
       min_memory_percent, max_memory_percent,  
       max_memory_kb/1024 AS [max_memory_mb],  
       used_memory_kb/1024 AS [used_memory_mb],   
       target_memory_kb/1024 AS [target_memory_mb],
	   min_iops_per_volume, max_iops_per_volume
FROM sys.dm_resource_governor_resource_pools WITH (NOLOCK)
OPTION (RECOMPILE);


-- Memory Grants Pending value for current instance  (Query 50) (Memory Grants Pending)
-- Son reservas de memoria que SQL Server asigna a una consulta antes de ejecutarla, principalmente para operaciones como:
-- 
--    Ordenamientos (Sort)
--    Joins complejos
--    Operaciones de agregación
-- 
-- ¿Por qué son importantes?
-- 
--    Si una consulta necesita más memoria de la que se le concede, puede usar tempdb (más lento).
--    Si hay muchas consultas esperando memory grants, se genera RESOURCE\_SEMAPHORE waits (bloqueos por falta de memoria).

SELECT @@SERVERNAME AS [Server Name], RTRIM([object_name]) AS [Object Name], cntr_value AS [Memory Grants Pending]                                                                                                       
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

SELECT * FROM sys.dm_exec_query_memory_grants;



-- Memory Clerk Usage for instance  (Query 51) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
-- Un Memory Clerk es un componente interno que rastrea y administra el uso de memoria por diferentes partes del motor:
-- 
--    Ejemplos:
--        CACHESTORE\_SQLCP → Planes de consultas ad-hoc.
--        CACHESTORE\_OBJCP → Planes de procedimientos almacenados.
--        MEMORYCLERK\_SQLBUFFERPOOL → Buffer Pool (páginas de datos).
--    ¿Para qué sirve?
--        Diagnóstico de consumo de memoria por cada área del motor.

SELECT TOP(10) mc.[type] AS [Memory Clerk Type], 
       CAST((SUM(mc.pages_kb)/1024.0) AS DECIMAL (15,2)) AS [Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks AS mc WITH (NOLOCK)
GROUP BY mc.[type]  
ORDER BY SUM(mc.pages_kb) DESC OPTION (RECOMPILE);



/* Estatus de  Lock pages in memory */
SELECT 
    a.memory_node_id,  -- 0 Nodo principal. 
    node_state_desc, -- ONLINE  Nodo principal. | ONLINE DAC Nodo activo para DAC.
    a.locked_page_allocations_kb --  páginas bloqueadas en memoria gracias al LPIM 
FROM sys.dm_os_memory_nodes AS a
INNER JOIN sys.dm_os_nodes AS b
    ON a.memory_node_id = b.memory_node_id;

SELECT
    physical_memory_in_use_kb / 1024 AS [Memoria Física en Uso (MB)],
    locked_page_allocations_kb / 1024 AS [Páginas Bloqueadas por LPI (MB)],
    (locked_page_allocations_kb / 1024.0) / 1024.0 AS [Páginas Bloqueadas por LPI (GB)]
FROM
    sys.dm_os_process_memory;




```
 

# Buffer 
```sql
-- Get total buffer usage by database for current instance  (Query 40) (Total Buffer Usage by Database)
-- This may take some time to run on a busy instance with lots of RAM
WITH AggregateBufferPoolUsage
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(COUNT_BIG(*) * 8/1024.0 AS DECIMAL (15,2)) AS [CachedSize],
COUNT(page_id) AS [Page Count],
AVG(read_microsec) AS [Avg Read Time (microseconds)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
GROUP BY DB_NAME(database_id))
SELECT ROW_NUMBER() OVER(ORDER BY CachedSize DESC) AS [Buffer Pool Rank], [Database Name], 
       CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS [Buffer Pool Percent],
       [Page Count], CachedSize AS [Cached Size (MB)], [Avg Read Time (microseconds)]
FROM AggregateBufferPoolUsage
ORDER BY [Buffer Pool Rank] OPTION (RECOMPILE);




-- Breaks down buffers used by current database by object (table, index) in the buffer cache  (Query 74) (Buffer Usage)
-- Note: This query could take some time on a busy instance
SELECT fg.name AS [Filegroup Name], SCHEMA_NAME(o.Schema_ID) AS [Schema Name],
OBJECT_NAME(p.[object_id]) AS [Object Name], p.index_id, 
CAST(COUNT(*)/128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)],  
COUNT(*) AS [BufferCount], p.[Rows] AS [Row Count],
p.data_compression_desc AS [Compression Type]
FROM sys.allocation_units AS a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON a.container_id = p.hobt_id
INNER JOIN sys.objects AS o WITH (NOLOCK)
ON p.object_id = o.object_id
INNER JOIN sys.database_files AS f WITH (NOLOCK)
ON b.file_id = f.file_id
INNER JOIN sys.filegroups AS fg WITH (NOLOCK)
ON f.data_space_id = fg.data_space_id
WHERE b.database_id = CONVERT(int, DB_ID())
AND p.[object_id] > 100
AND OBJECT_NAME(p.[object_id]) NOT LIKE N'plan_%'
AND OBJECT_NAME(p.[object_id]) NOT LIKE N'sys%'
AND OBJECT_NAME(p.[object_id]) NOT LIKE N'xml_index_nodes%'
GROUP BY fg.name, o.Schema_ID, p.[object_id], p.index_id, 
         p.data_compression_desc, p.[Rows]
ORDER BY [BufferCount] DESC OPTION (RECOMPILE);


-- Get input buffer information for the current database (Query 86) (Input Buffer)
SELECT es.session_id, DB_NAME(es.database_id) AS [Database Name],
       es.[program_name], es.[host_name], es.login_name,
       es.login_time, es.cpu_time, es.logical_reads, es.memory_usage,
       es.[status], ib.event_info AS [Input Buffer]
FROM sys.dm_exec_sessions AS es WITH (NOLOCK)
CROSS APPLY sys.dm_exec_input_buffer(es.session_id, NULL) AS ib
WHERE es.database_id = DB_ID()
AND es.is_user_process = 1 OPTION (RECOMPILE); 
```


--- 


# Consultas que están usando tempdb (spills)
significa que SQL Server no puede mantener toda la información en memoria y necesita usar espacio en disco para operaciones temporales. Esto ocurre principalmente en:

### **¿Cuándo sucede?**

*   **Consultas con operaciones de ordenamiento grandes** (ORDER BY, GROUP BY) que exceden la memoria asignada.
*   **Joins complejos** (especialmente hash joins) que no caben en memoria.
*   **Operaciones de agregación masiva** (SUM, COUNT, etc.) sobre grandes volúmenes.
*   **Consultas que usan tablas temporales o variables de tabla**.
*   **Spills a tempdb**: Cuando el operador (Sort, Hash) no tiene suficiente memoria grant y “derrama” datos a disco.

 

### **¿Cómo detectarlo?**

1.  **Plan de ejecución**:
    *   Busca advertencias como **“Hash Warning”** o **“Sort Warning”**.
    *   Indicadores: `Spill Level` > 0 en operadores Hash o Sort.

2.  **DMVs en tiempo real**:
    *   `sys.dm_exec_query_stats` + `sys.dm_exec_query_plan` para ver spills.
    *   `sys.dm_exec_requests` → columna `grant_memory_kb` vs `used_memory_kb`.

3.  **Eventos extendidos**:
    *   Evento: `sort_warning` o `hash_spill_details`.
    *   Captura cuándo ocurre el spill y cuánto se escribe en tempdb.

4.  **Monitoreo de tempdb**:
    *   Si hay crecimiento repentino en tempdb durante consultas grandes, es señal de spills.

```SQL
-- ver las consultas ejecutadas actualmente 
SELECT
    r.session_id,
    r.status,
    r.command,
    mg.requested_memory_kb AS MemoriaSolicitada_KB,
    mg.granted_memory_kb AS MemoriaConcedida_KB,
    tu.internal_objects_alloc_page_count * 8 AS TempdbAllocado_KB,
    tu.user_objects_alloc_page_count * 8 AS TempdbUsuario_KB,
    t.text AS QueryTexto
FROM sys.dm_exec_requests AS r
JOIN sys.dm_exec_query_memory_grants AS mg
    ON r.session_id = mg.session_id
JOIN sys.dm_db_task_space_usage AS tu
    ON r.session_id = tu.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE tu.internal_objects_alloc_page_count > 0 OR tu.user_objects_alloc_page_count > 0
ORDER BY TempdbAllocado_KB DESC;



--- Saber las consultas que consumen mucha memoria y generan mucho spill
SELECT
	TOP 50
    DB_NAME(qt.dbid) AS database_name,  -- Nombre de la base de datos
    qs.execution_count,
    qs.total_grant_kb,        -- Total de memoria solicitada por todas las ejecuciones
    qs.min_grant_kb,
    qs.max_grant_kb,
    qs.total_used_grant_kb,   -- Memoria realmente usada
    qs.total_spills,          -- Número total de spills
    -- Cálculos promedio por ejecución:
    CASE WHEN qs.execution_count > 0 THEN qs.total_grant_kb / qs.execution_count ELSE 0 END AS avg_grant_kb_per_exec,
    CASE WHEN qs.execution_count > 0 THEN qs.total_used_grant_kb / qs.execution_count ELSE 0 END AS avg_used_grant_kb_per_exec,
    CASE WHEN qs.execution_count > 0 THEN qs.total_spills / qs.execution_count ELSE 0 END AS avg_spills_per_exec,
    qp.query_plan,
    qt.text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE qs.total_spills > 0    -- Filtra consultas con spills
ORDER BY avg_spills_per_exec DESC;

```


# VLF
```
-- Determine whether you will be able to shrink the transaction log file

-- vlf_status Values
-- 0 is inactive 
-- 1 is initialized but unused 
-- 2 is active


SELECT TOP(1) DB_NAME(li.database_id) AS [Database Name], li.[file_id],
              li.vlf_size_mb, li.vlf_sequence_number, li.vlf_active, li.vlf_status
FROM sys.dm_db_log_info(DB_ID()) AS li 
ORDER BY vlf_sequence_number DESC OPTION (RECOMPILE);


-- Get VLF Counts for all databases on the instance (Query 34) (VLF Counts)
SELECT [name] AS [Database Name], [VLF Count]
FROM sys.databases AS db WITH (NOLOCK)
CROSS APPLY (SELECT file_id, COUNT(*) AS [VLF Count]
		     FROM sys.dm_db_log_info(db.database_id)
			 GROUP BY file_id) AS li
ORDER BY [VLF Count] DESC OPTION (RECOMPILE);
```

# **Otras querys que sirven**:
```SQL
SELECT 'Top 10 por Espacio'
SELECT TOP 10
    CONNECTIONPROPERTY('local_net_address') AS IPServidor,
    DB_NAME(database_id) AS DatabaseName,
    CAST(SUM(size) AS BIGINT) * 8 / 1024 / 1024 AS SizeGB
FROM sys.master_files
GROUP BY database_id
ORDER BY CAST(SUM(size) AS BIGINT) DESC;

SELECT 'Top 10 por I/O'
SELECT TOP 10
	CONNECTIONPROPERTY('local_net_address') AS IPServidor,
    DB_NAME(database_id) AS DatabaseName,
    SUM(num_of_reads + num_of_writes) AS TotalIO
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
GROUP BY database_id
ORDER BY TotalIO DESC
 
SELECT 'Top 10 por Memoria'
SELECT TOP 10
	CONNECTIONPROPERTY('local_net_address') AS IPServidor,
    DB_NAME(database_id) AS DatabaseName,
    COUNT(*) * 8 / 1024 AS BufferPoolMB
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY BufferPoolMB DESC;


SELECT 'Top 10 por CPU'
SELECT 
    DB_NAME(st.dbid) AS BaseDeDatos,
    SUM(qs.total_worker_time) / 1000 AS CPU_ms,
    SUM(qs.execution_count) AS CantidadEjecuciones,
    SUM(qs.total_elapsed_time) / 1000 AS TiempoTotal_ms
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
GROUP BY DB_NAME(st.dbid)
ORDER BY CPU_ms DESC;


-- Cantidad de peticiones por segundo
-- [NOTA] ->  el valor de cntr_value NO significa que actualmente tienes esa cantidad peticiones por segundo.  
-- ese contador es acumulativo, por lo que debes calcular la diferencia entre dos lecturas en un intervalo de tiempo. tomando un punto de referencia y despues restar 
SELECT
   cntr_value AS BatchRequestsPerSec
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec';


-- las tablas ,  PartitionSchema y Partitionfunction
SELECT
    Distinct 
    s.name AS SchemaName,
    t.name AS TableName,
    ps.name AS PartitionScheme,
    pf.name AS PartitionFunction,
    ds.name AS FileGroup
FROM sys.tables AS t
JOIN sys.schemas AS s ON t.schema_id = s.schema_id
JOIN sys.indexes AS i ON t.object_id = i.object_id
JOIN sys.partition_schemes AS ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
JOIN sys.destination_data_spaces AS dds ON ps.data_space_id = dds.partition_scheme_id
JOIN sys.filegroups AS ds ON dds.data_space_id = ds.data_space_id
WHERE i.index_id IN (0,1)  -- heap o índice clustered
ORDER BY t.name;

---- Ver tamaño total de la tabla y su indice
 SELECT
    TOP 10
    s.name AS SchemaName,
    t.name AS TableName,
    --fg.name AS FileGroupName,
	CASE WHEN fg.name IS NULL THEN 'PRIMARY' ELSE fg.name END AS FileGroupName ,
    -- Tamaño total (datos + índices)
    CAST(SUM(a.total_pages) * 8.0 AS DECIMAL(18,2)) AS TotalSizeKB,
    -- Solo datos (heap o índice clustered)
    CAST(SUM(CASE WHEN i.type IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS DataSizeKB,
    -- Solo índices (nonclustered, XML, spatial, etc.)
    CAST(SUM(CASE WHEN i.type NOT IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS IndexSizeKB,
    CASE 
        WHEN COUNT(DISTINCT p.partition_number) > 1 THEN 'Sí'
        ELSE 'No'
    END AS IsPartitioned,
    COUNT(DISTINCT p.partition_number) AS PartitionCount,
    SUM(ps.row_count) AS TotalRows
FROM sys.tables AS t
LEFT JOIN sys.schemas AS s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
LEFT JOIN sys.filegroups AS fg ON i.data_space_id = fg.data_space_id 
LEFT JOIN sys.dm_db_partition_stats AS ps ON p.partition_id = ps.partition_id
GROUP BY s.name, t.name, fg.name
having COUNT(DISTINCT p.partition_number) > 1 ;



---- Ver tamaño por partición de la tabla y sus índices
 SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    -- fg.name AS FileGroupName,
	CASE WHEN fg.name IS NULL THEN 'PRIMARY' ELSE fg.name END AS FileGroupName ,
    p.partition_number AS PartitionNumber,
    CAST(SUM(a.total_pages) * 8.0 AS DECIMAL(18,2)) AS TotalSizeKB,
    CAST(SUM(CASE WHEN i.type IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS DataSizeKB,
    CAST(SUM(CASE WHEN i.type NOT IN (0,1) THEN a.total_pages ELSE 0 END) * 8.0 AS DECIMAL(18,2)) AS IndexSizeKB,
    SUM(ps.row_count) AS TotalRows
FROM sys.tables AS t
LEFT JOIN sys.schemas AS s ON t.schema_id = s.schema_id
LEFT JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
LEFT JOIN sys.data_spaces ds ON i.data_space_id = ds.data_space_id
LEFT JOIN sys.filegroups fg ON ds.data_space_id = fg.data_space_id
LEFT JOIN sys.dm_db_partition_stats AS ps ON p.partition_id = ps.partition_id
WHERE t.name = 'ClientesTest'
GROUP BY s.name, t.name, fg.name, p.partition_number
ORDER BY t.name,p.partition_number


 --- Ver los indices de la tabla 
SELECT
    i.name AS Indice,
    i.type_desc AS TipoIndice,  -- Clustered o Nonclustered
    fg.name AS Filegroup,
    SUM(a.total_pages) * 8 AS Tamaño_KB
FROM sys.indexes i
LEFT JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE OBJECT_NAME(i.object_id) = 'ClientesTest'
GROUP BY i.name, i.type_desc, fg.name;



------- Ver index y sus fragmentacion y mas inforamción 
SELECT 
top 100
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    i.object_id,
    i.name AS Index_Name,
    i.index_id,
    i.type_desc,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ips.avg_fragmentation_in_percent AS Fragmentacion_Porcentaje,
    ic.is_descending_key AS Orden_Desc -- 1 = DESC, 0 = ASC
FROM sys.schemas s
INNER JOIN sys.tables t ON s.schema_id = t.schema_id
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
LEFT JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE i.type_desc <> 'HEAP' 
ORDER BY s.name, t.name, i.name, ic.key_ordinal;



------------------------- Ver detalles de isolation --------------------
DBCC USEROPTIONS;


SELECT IsolationLevel,count(*) as cnt FROM
(SELECT CASE transaction_isolation_level
    WHEN 0 THEN 'Unspecified'
    WHEN 1 THEN 'Read Uncommitted'
    WHEN 2 THEN 'Read Committed'
    WHEN 3 THEN 'Repeatable Read'
    WHEN 4 THEN 'Serializable'
    WHEN 5 THEN 'Snapshot'
END AS IsolationLevel
FROM sys.dm_exec_sessions
WHERE session_id = @@SPID ) as a 
group by IsolationLevel


SELECT name, is_read_committed_snapshot_on
FROM sys.databases
-- WHERE name = 'TuBaseDeDatos';
--------------------------------------------------------------------------------


--- Ver los   files, su % de  espacio disponible y usado , modo de recovery y porque no se puede libera el espacio "LogReuseWaitDesc"
SELECT 
    DB_NAME() AS DatabaseName,
    df.name AS FileName,
    df.type_desc AS FileType,  -- ROWS = datos, LOG = log
    df.physical_name AS PhysicalPath,
    CAST(df.size AS BIGINT) * 8 / 1024 AS SizeMB,  -- Tamaño actual en MB
    CAST(FILEPROPERTY(df.name, 'SpaceUsed') AS BIGINT) * 8 / 1024 AS UsedSpaceMB,
    CAST(100.0 * FILEPROPERTY(df.name, 'SpaceUsed') / df.size AS DECIMAL(5,2)) AS UsedPercent,
    CAST(100.0 - (100.0 * FILEPROPERTY(df.name, 'SpaceUsed') / df.size) AS DECIMAL(5,2)) AS FreePercent,
    CASE 
        WHEN df.is_percent_growth = 1 THEN CAST(df.growth AS VARCHAR(10)) + ' %'
        ELSE CAST(CAST(df.growth AS BIGINT) * 8 / 1024 AS VARCHAR(20)) + ' MB'
    END AS GrowthSetting,
    CASE 
        WHEN df.max_size = -1 THEN 'Sin límite'
        ELSE CAST(CAST(df.max_size AS BIGINT) * 8 / 1024 AS VARCHAR(20)) + ' MB'
    END AS MaxSize,
    df.state_desc AS FileState,
    d.recovery_model_desc AS RecoveryModel,
    d.log_reuse_wait_desc AS LogReuseWaitDesc
FROM sys.database_files AS df
CROSS JOIN sys.databases AS d
WHERE d.database_id = DB_ID();



```


