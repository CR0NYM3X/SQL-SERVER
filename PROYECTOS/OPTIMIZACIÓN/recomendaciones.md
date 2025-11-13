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
