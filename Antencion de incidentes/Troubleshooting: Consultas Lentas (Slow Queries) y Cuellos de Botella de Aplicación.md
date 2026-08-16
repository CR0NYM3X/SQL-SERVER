 

# Troubleshooting: Consultas Lentas (Slow Queries) y Cuellos de Botella de Aplicación

**Objetivo:** Identificar y diagnosticar la causa de consultas de larga duración que consumen mucho tiempo de ejecución sin estar bloqueadas por otras transacciones, analizando sus tiempos reales y tipos de espera (Wait Stats).

---

### Paso 1: Identificar las consultas activas y su tiempo real de ejecución

Para saber exactamente cuánto tiempo lleva corriendo una consulta, no basta con mirar el tiempo de espera actual (`wait_time`), debemos revisar el tiempo total transcurrido (`total_elapsed_time`) y su hora de inicio (`start_time`).

**Comando ejecutado:** Modificamos la consulta a las DMVs para priorizar el tiempo de vida de la solicitud.

```sql
SELECT 
    r.session_id,
    r.status,
    r.command,
    r.start_time,
    r.total_elapsed_time / 1000 AS elapsed_time_sec, -- Tiempo TOTAL que lleva ejecutándose
    r.wait_type,
    r.wait_time / 1000 AS current_wait_sec,          -- Tiempo de la micro-espera actual
    SUBSTRING(t.text, (r.statement_start_offset/2)+1, 
    ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50 AND r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;

```

**Resultado obtenido (Basado en la alerta):**

```text
session_id  status     command  start_time               elapsed_time_sec  wait_type         current_wait_sec query_text
----------  ---------  -------  -----------------------  ----------------  ----------------  ---------------- ----------------------------------------------------
319         suspended  SELECT   2026-08-16 13:00:10.000  980               ASYNC_NETWORK_IO  0                select mdhae1_0.keyx, mdhae1_0.articulo, mdhae1_0...

```

* **Análisis:** La sesión **319** lleva ejecutándose **980 segundos** (más de 16 minutos). Su `current_wait_sec` es 0 porque la espera actual es de apenas unos milisegundos, pero la suma de todas esas pequeñas esperas conforma los 16 minutos. El estado es `suspended` y el tipo de espera es `ASYNC_NETWORK_IO`.

### Paso 2: Interpretar el Wait Type `ASYNC_NETWORK_IO`

Al contrario de lo que su nombre sugiere, este evento **rara vez es un problema de la red física**.

Lo que este estado significa es:

1. SQL Server ejecutó la consulta rapidísimo y ya tiene los resultados listos en memoria.
2. SQL Server está enviando los datos a la aplicación cliente a través de la red.
3. **El cliente (la aplicación) no está leyendo los datos lo suficientemente rápido.**
4. SQL Server tiene que pausar la ejecución (`suspended`) y esperar a que el cliente termine de procesar el bloque de datos actual antes de enviarle el siguiente.

### Paso 3: Identificar el origen de la consulta (El factor ORM)

Observando el texto de la consulta (`select mdhae1_0.keyx, mdhae1_0.articulo...`), esos alias generados automáticamente (`mdhae1_0`) son la firma clásica de un **ORM (Object-Relational Mapper)**, muy probablemente **Hibernate (Java)** o Entity Framework.

Esto nos da la pista final de lo que está ocurriendo en la aplicación.

---

### Conclusión Final del Análisis

1. **Estado del Servidor DB:** SQL Server no es el cuello de botella. La base de datos está despachando los datos eficientemente, pero se ve obligada a esperar a la aplicación.
2. **Causa Raíz:** Lentitud en el procesamiento de la capa de aplicación (Client-Side Processing Bottleneck) evidenciado por la espera masiva en `ASYNC_NETWORK_IO`.
3. **Escenarios Probables en el Cliente:**
* **Extracción masiva de datos:** El ORM está haciendo un `SELECT *` de una tabla con millones de registros y cargándolos en la memoria RAM del servidor de aplicaciones, saturándolo.
* **RBAR (Row-By-Agonizing-Row):** La aplicación está pidiendo los datos a SQL Server, pero en su código hace un ciclo `for` o `while` y procesa reglas de negocio pesadas fila por fila *antes* de pedirle a SQL Server la siguiente fila.
* **Problema real de red:** (Menos común) La tarjeta de red entre el servidor de BD y el servidor de Aplicaciones está saturada o defectuosa.


4. **Acción Correctiva Requerida:**
* **Lado DBA:** La consulta no se puede afinar con índices porque el problema no es de lectura de disco ni de CPU de SQL Server.
* **Lado Desarrollo:** Escalar el texto de la consulta y el nombre de la tabla al equipo de desarrollo para que corrijan el uso del ORM. Deben implementar **paginación** (traer bloques de 100 en 100 registros), evitar traer columnas innecesarias, o mover el procesamiento masivo a un Procedimiento Almacenado del lado del servidor.
* 
