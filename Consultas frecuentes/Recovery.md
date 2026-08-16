# Base de Datos en Estado `RECOVERING` (SQL Server)
 
## 📌 ¿Qué significa el estado `RECOVERING`?
Significa que SQL Server está procesando el registro de transacciones (*Transaction Log*) para garantizar la **consistencia de datos** (fases de *Analysis*, *Redo* y *Undo*) antes de permitir el acceso a los usuarios.

 En SQL Server, el **Redo** (también conocido como la fase de *Roll Forward*) es el proceso mediante el cual el motor de base de datos **vuelve a aplicar todas las transacciones confirmadas (*committed*) que ya estaban registradas en el Transaction Log, pero que aún no se habían guardado en los archivos físicos de datos (`.mdf` / `.ndf`)**.
 

> ⚠️ **REGLA DE ORO:** **NUNCA** reinicies el servicio de SQL Server ni el servidor mientras la base de datos esté en `RECOVERING`. Interrumpir este proceso reiniciará la recuperación desde el 0% y puede causar corrupción de datos.

---

## 🔍 Causas Principales
1. **Apagón o falla de energía:** Pérdida de energía que interrumpe la escritura de transacciones de la memoria RAM al disco.
2. **Reinicio forzado (Crash):** Pantallazo azul (BSOD), falla del SO o terminación abrupta del proceso `sqlservr.exe`.
3. **Reinicio de servicios con transacciones activas:** Detener/reiniciar el servicio mientras se ejecutaba un proceso masivo (`UPDATE`, `DELETE`, reconstrucción de índices) o un *Rollback*.
4. **Alta Disponibilidad:** Proceso normal durante un *Failover* en *Always On* o *Database Mirroring*.

---

## 🚀 Consultas de Diagnóstico y Monitoreo

### 1. Identificar Bases de Datos que no están `ONLINE`
Permite listar rápidamente todas las bases de datos en estado de recuperación, sospechosas o fuera de línea.

```sql
SELECT 
    name, 
    state_desc 
FROM sys.databases 
WHERE state_desc != 'ONLINE';
```



### 2. Verificar la Hora de Inicio de SQL Server

Útil para determinar exactamente a qué hora se reinició la instancia o el servicio.

```sql
-- Opción A: Desde las vistas del sistema (Recomendado)
SELECT sqlserver_start_time 
FROM sys.dm_os_sys_info;

-- Opción B: A través de la fecha de creación de tempdb
SELECT create_date AS sqlserver_start_time 
FROM sys.databases 
WHERE name = 'tempdb';

-- Opción C: Consultando el Error Log
EXEC xp_readerrorlog 0, 1, N'Microsoft SQL Server';

```

---

### 3. Monitorear el Progreso en Tiempo Real (DMV)

Consulta dinámica para verificar el porcentaje de avance y el tiempo estimado restante.

```sql
SELECT 
    session_id, 
    command, 
    status, 
    percent_complete,                                  -- Porcentaje alcanzado en la fase actual
    estimated_completion_time / 1000 / 60 AS estimated_minutes_left -- Tiempo estimado restante en minutos
FROM sys.dm_exec_requests 
WHERE command = 'DB STARTUP';

```

---

### 4. Consultar Detalle en el Error Log

Permite ver los mensajes oficiales del motor sobre la fase de recuperación (*Phase 1 of 3*, *Phase 2 of 3*, etc.).

```sql
-- Nota: La 'N' antes de la cadena indica tipo NVARCHAR (necesario para evitar Msg 22004)
EXEC xp_readerrorlog 0, 1, N'Recovery of database';

```

---

## 📊 Las 3 Fases de Recuperación

| Fase | Nombre | Descripción |
| --- | --- | --- |
| **1** | **Analysis** | Analiza el log desde el último *Checkpoint* para identificar transacciones. |
| **2** | **Redo (Roll Forward)** | Aplica todas las transacciones confirmadas (*Committed*) al disco. |
| **3** | **Undo (Rollback)** | Deshace las transacciones no confirmadas que quedaron activas. |

---

# Qué hacer como DBA? 
 

### 1. Diagnóstico Inmediato: ¿Qué hacer durante el incidente?

* **No pánico, no "Reboot":** La regla número uno ante un proceso de recuperación activo es **dejar trabajar a SQL Server**. Forzar un reinicio del servicio o del servidor solo destruye el avance (por ejemplo, el 27% que llevaba tu servidor) y reinicia el *Crash Recovery* desde el 0%, prolongando innecesariamente el tiempo de inactividad (*downtime*).
* **Monitoreo dinámico:** Ejecutar los comandos de diagnóstico (`sys.dm_exec_requests` y `xp_readerrorlog`) para dar a la gerencia o al negocio una **estimación realista de tiempo de entrega** (RTO - *Recovery Time Objective*).
* **Esperar al estado `ONLINE`:** Una vez que las tres fases (*Analysis*, *Redo* y *Undo*) concluyen, el motor libera automáticamente la base de datos de forma consistente y sin pérdida de integridad.

---

### 2. Análisis Causa Raíz (RCA): ¿Por qué ocurrió?

Una vez restablecido el servicio, la labor del DBA es determinar el origen del evento para evitar que vuelva a suceder:

1. **Revisar el Event Viewer de Windows y el SQL Error Log:** Confirmar si el reinicio fue provocado por una falla eléctrica, un fallo del sistema operativo (BSOD), una actualización automática de Windows o la terminación forzada del proceso `sqlservr.exe`.
2. **Revisar patrones de carga de trabajo:** Si el servicio se reinició mientras se ejecutaba un proceso masivo (ej. un `DELETE` de millones de filas o un `REINDEX` sin control), la fase de *Undo/Redo* será muy pesada.

---

### 3. Acciones Preventivas a Futuro (Buenas Prácticas de DBA)

Para minimizar la duración de un eventual `RECOVERING` en el futuro, se deben implementar las siguientes medidas:

* **Ajustar el *Target Recovery Time* (Indirect Checkpoints):**
A partir de SQL Server 2016, la opción predeterminada para el tiempo de recuperación es de 60 segundos. Si es una base de datos legada o migrada de versiones anteriores (2012 o previo), verifica que `TARGET_RECOVERY_TIME` no esté en `0` (desactivado).
```sql
ALTER DATABASE [ComprasMuebles] SET TARGET_RECOVERY_TIME = 60 SECONDS;

```
