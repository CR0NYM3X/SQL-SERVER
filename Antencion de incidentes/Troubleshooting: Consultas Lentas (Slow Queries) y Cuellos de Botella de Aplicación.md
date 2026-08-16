 
# 📄 Consultas Lentas (Slow Queries) y Cuellos de Botella de Aplicación

**Objetivo:** Diagnosticar, mitigar y corregir incidentes donde sesiones de base de datos permanecen activas durante horas consumiendo recursos del servidor, ocasionadas por aplicaciones que solicitan volúmenes masivos de datos y sufren colapsos de memoria o red.

---

### 🔍 Paso 1: Identificar las consultas activas y su tiempo real de ejecución

Para evaluar el impacto de una consulta, debemos revisar su tiempo total transcurrido (`total_elapsed_time`) y contrastarlo con su tipo de espera actual (`wait_type`).

**Comando de diagnóstico:**

```sql
SELECT 
    r.session_id,
    r.status,
    r.command,
    r.start_time,
    r.total_elapsed_time / 1000 AS elapsed_time_sec,
    r.wait_type,
    r.wait_time / 1000 AS current_wait_sec
FROM sys.dm_exec_requests r
WHERE r.session_id > 50 AND r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;

```

**Evidencia recolectada:**

* **session_id:** `319`
* **elapsed_time_sec:** `46735` (Aproximadamente **13 horas** en ejecución).
* **wait_type:** `ASYNC_NETWORK_IO`
* **status:** `suspended`

> **Diagnóstico del Wait Type:** `ASYNC_NETWORK_IO` indica que SQL Server **ya procesó la consulta** y está intentando enviar los datos, pero la red o **la aplicación cliente no los está leyendo o los lee demasiado lento**. SQL Server suspende el proceso hasta que el cliente libere el cuello de botella.

---

### 📡 Paso 2: Rastrear el Origen de la Conexión (El Cliente)

Para entender por qué los datos no están siendo consumidos, identificamos al cliente responsable.

**Comando de diagnóstico:**

```sql
SELECT 
    s.session_id,
    s.status,
    s.host_name,
    s.program_name,
    s.login_time,
    s.last_request_end_time
FROM sys.dm_exec_sessions s
WHERE s.session_id = 319;

```

**Evidencia recolectada:**

* **host_name:** `api-arc-detalle...` (Microservicio / Backend API)
* **program_name:** `Microsoft JDBC Driver for SQL Server` (Aplicación Java)

---

### 🕵️‍♂️ Paso 3: Analizar la Consulta Exacta (El Disparador)

Extraemos el último comando enviado por la aplicación para dimensionar el volumen de la transacción que ahogó al cliente.

**Comando de diagnóstico:**

```sql
DBCC INPUTBUFFER(319);

```

**Evidencia recolectada (Comando SQL ejecutado por el ORM):**

```sql
(@P0 datetime2, @P1 smallint)
SELECT 
    mdhae1_0.keyx, mdhae1_0.articulo, ........
FROM tabla_pruebas mdhae1_0 
WHERE mdhae1_0.fecha < @P0 AND mdhae1_0.tienda = @P1

```

---

### 📊 Conclusión Final del Análisis (Root Cause Analysis)

1. **Estado del Servidor de Base de Datos:** SQL Server operó correctamente. Respondió a la consulta y comenzó a enviar la sábana de datos hacia el cliente, pero la sesión se convirtió en un "zombi" porque el cliente dejó de recibir la información.
2. **Análisis de la Consulta (Anti-patrón ORM):**
* La API de Java (`api-arc-detalle`), a través de Hibernate/Spring Data, ejecutó una extracción sobre la tabla `tabla_pruebas`.
* La condición `fecha < @P0` es un filtro de rango abierto que puede retornar cientos de miles de registros históricos de esa tienda.
* El ORM exigió el retorno de **71 columnas** por cada fila encontrada.


3. **Causa Raíz Exacta:** Al intentar volcar esta cantidad masiva de datos y columnas en la memoria RAM del servidor de la API, la aplicación sufrió un desbordamiento de memoria (**`java.lang.OutOfMemoryError: Java heap space`**) o se colgó procesando. Al "crashear" silenciosamente, la API **nunca cerró la conexión con la base de datos**. SQL Server retuvo los recursos en estado `ASYNC_NETWORK_IO` durante 13 horas esperando a un cliente que ya no existe.

---

### 🛠️ Plan de Acción y Correcciones

#### 🚨 1. Acción Correctiva Inmediata (Lado DBA)

Al tratarse de una consulta `SELECT`, no existe riesgo de corrupción ni necesidad de hacer *Rollback*. Para liberar instantáneamente la red, la memoria y los *threads* secuestrados en el servidor de base de datos, se debe matar la sesión "zombi".

**Comando a ejecutar en el momento del incidente:**

```sql
KILL 319;

```

####   2. Recomendaciones de Arquitectura (Lado Desarrollo / Backend)

Para evitar que este incidente se repita y vuelva a tumbar los recursos de la base de datos, el equipo de desarrollo debe implementar los siguientes cambios obligatorios en el servicio `api-arc-detalle`:

* **Implementar Paginación Estricta:** Queda prohibido hacer extracciones históricas (`fecha < @P0`) sin límite. El repositorio Java debe utilizar paginación (e.g., `Pageable` en Spring Boot) o lotes (`FETCH NEXT 1000 ROWS ONLY`) para procesar bloques de información digeribles.
* **Proyecciones de Datos (Uso de DTOs):** El ORM está haciendo un virtual `SELECT *` trayendo 71 columnas de la entidad. Se debe crear un objeto DTO (*Data Transfer Object*) que consulte **únicamente** las 3 o 4 columnas estrictamente necesarias para el cálculo o reporte.
* **Configurar Timeouts en el Driver JDBC:** Es inaceptable que una conexión sobreviva 13 horas en un estado colgado. Se deben configurar los parámetros `queryTimeout` y `socketTimeout` en la cadena de conexión de la aplicación para abortar automáticamente cualquier consulta que supere los 60 o 120 segundos.
