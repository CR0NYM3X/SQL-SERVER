
#   Troubleshooting:  Bloqueos Silenciosos

**Objetivo:** Identificar la causa raíz cuando los usuarios y la aplicación reportan tiempos de espera extremos (Timeouts) y lentitud severa en la base de datos, pero el consumo de CPU y RAM en el servidor es inusualmente bajo.

---

### Paso 1: Identificar las consultas de larga duración en ejecución

El primer paso es observar qué está haciendo el motor en este instante y verificar si las consultas realmente están consumiendo recursos (CPU/Lecturas) o si están esperando por algo.

**Comando ejecutado:** Consultamos las vistas dinámicas (DMVs) de solicitudes actuales para ver procesos con más de 1 minuto de ejecución.

```sql
SELECT 
    r.session_id,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time / 1000 AS wait_time_sec,
    SUBSTRING(t.text, (r.statement_start_offset/2)+1, 
    ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50 AND r.session_id <> @@SPID;

```

**Resultado obtenido:**

```text
session_id   status      command   wait_type   wait_time_sec   query_text
----------   ---------   -------   ---------   -------------   ----------------------------------------
65           suspended   SELECT    LCK_M_IS    1240            SELECT * FROM Inventario WHERE ItemID = 10;
66           suspended   UPDATE    LCK_M_U     1185            UPDATE Ventas SET Estatus = 'C' ...
68           suspended   SELECT    LCK_M_IS    950             SELECT Stock FROM Inventario ...

```

* **Análisis:** Las consultas llevan hasta 20 minutos (1240 segundos) "ejecutándose", pero su estado es `suspended`. El `wait_type` indica `LCK_M_IS` y `LCK_M_U` (esperas por bloqueos de lectura/escritura). **Conclusión preliminar:** Las consultas no son lentas por falta de índices o exceso de procesamiento; están detenidas en una fila de tráfico porque otra sesión tiene bloqueadas las tablas.

### Paso 2: Rastrear la cabeza del bloqueo (Head Blocker)

Necesitamos encontrar quién es el culpable original que está deteniendo a las sesiones 65, 66 y 68.

**Comando ejecutado:** Buscamos el origen de la cadena de bloqueos cruzando las peticiones con las sesiones.

```sql
SELECT 
    blocking_session_id AS Culpable_Head_Blocker,
    session_id AS Victima_Bloqueada,
    wait_type,
    wait_duration_ms / 1000 AS wait_sec
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL;

```

**Resultado obtenido:**

```text
Culpable_Head_Blocker   Victima_Bloqueada   wait_type   wait_sec
---------------------   -----------------   ---------   --------
54                      65                  LCK_M_IS    1240
54                      66                  LCK_M_U     1185
54                      68                  LCK_M_IS    950

```

* **Análisis:** ¡Hallazgo crítico! La sesión **54** es la responsable de bloquear a todos los demás. Sin embargo, si revisamos el resultado del Paso 1, el SPID 54 **no aparecía en la lista de consultas en ejecución**.

### Paso 3: Descubrir qué está haciendo la sesión culpable (SPID 54)

Si el `Head Blocker` no está ejecutando nada actualmente, debemos ver cuál es su estado, desde qué aplicación viene y cuál fue su último comando enviado.

**Comando ejecutado:**

```sql
SELECT 
    s.session_id,
    s.status,
    s.host_name,
    s.program_name,
    s.login_time,
    s.last_request_end_time
FROM sys.dm_exec_sessions s
WHERE s.session_id = 54;

-- Obtenemos el último comando enviado por esta sesión
DBCC INPUTBUFFER(54);

```

**Resultado obtenido:**

```text
-- Resultado Sesión
session_id   status     host_name    program_name       last_request_end_time
----------   --------   ----------   ----------------   -----------------------
54           sleeping   APP-SRV-01   Ventas-Backend     2026-08-16 12:45:10.000

-- Resultado DBCC INPUTBUFFER
EventType      Parameters   EventInfo
------------   ----------   -------------------------------------------------
Language Event 0            BEGIN TRAN; UPDATE Inventario SET Stock = Stock - 1 WHERE ItemID = 10;

```

* **Análisis:** El misterio está resuelto. La sesión 54 está en estado `sleeping` (dormida/inactiva). Abrió una transacción (`BEGIN TRAN`) e hizo un `UPDATE` hace casi media hora, **pero nunca envió el comando `COMMIT` o `ROLLBACK**`. Los bloqueos exclusivos (`X`) adquiridos por el `UPDATE` se quedan retenidos indefinidamente, paralizando todo el sistema.

### Paso 4: Validar el tamaño de la transacción huérfana

Antes de matar el proceso, validamos cuánto tiempo lleva abierta la transacción activa para dejar evidencia al equipo de desarrollo.

**Comando ejecutado:**

```sql
SELECT 
    st.session_id,
    tat.transaction_begin_time,
    DATEDIFF(MINUTE, tat.transaction_begin_time, GETDATE()) AS minutos_abierta,
    tat.transaction_state
FROM sys.dm_tran_active_transactions tat
INNER JOIN sys.dm_tran_session_transactions st 
    ON tat.transaction_id = st.transaction_id
WHERE st.session_id = 54;

```

**Resultado obtenido:**

```text
session_id   transaction_begin_time    minutos_abierta   transaction_state
----------   -----------------------   ---------------   -----------------
54           2026-08-16 12:45:09.000   28                2 (Active)

```

* **Análisis:** Se confirma el diagnóstico. La transacción lleva 28 minutos abierta sin actividad. Al ser de un aplicativo Backend, es un "leak" de transacción (fuga de conexión o error de código).

---

### Conclusión Final del Análisis

1. **Estado de la BD:** Los recursos de hardware (CPU/RAM/Disco) están sanos y sin estrés. El problema es puramente lógico a nivel de concurrencia.
2. **Causa Raíz:** Inanición de recursos lógicos (Lock Starvation). Las "consultas lentas" en realidad son víctimas esperando a que se liberen bloqueos de tabla/fila (`LCK_M_IS`, `LCK_M_U`).
3. **Responsable probable:** La aplicación `Ventas-Backend` alojada en `APP-SRV-01` abrió una transacción explícita (`BEGIN TRAN`) en el SPID 54 y abandonó la conexión sin cerrarla (`COMMIT`).
4. **Acción correctiva requerida:**
* *Inmediata:* Ejecutar el comando `KILL 54;` en SQL Server para forzar el *Rollback* de la transacción huérfana. Esto liberará los candados y destrabará instantáneamente las sesiones 65, 66 y 68.
* *A largo plazo:* Escalar la evidencia (SPID, Host, y código de la consulta) al equipo de Desarrollo para que revisen el bloque `try-catch` o `using` de su código en la capa de acceso a datos, garantizando que toda transacción se cierre independientemente de los errores.
