 
 
# Configuraciones Generales y Esenciales

## Recovery Model
Asegúrate de que el modelo de recuperación sea apropiado (FULL, SIMPLE, BULK_LOGGED) según tus necesidades de respaldo y restauración.

## Auto Growth
Configura el crecimiento automático para que sea adecuado (por porcentaje o por tamaño específico) y evita el autogrowth en pequeñas cantidades frecuentes.

## Rendimiento
- **Indexación**: Verifica que las tablas más grandes y las más consultadas tengan índices adecuados y realiza mantenimientos periódicos.
- **Estadísticas**: Asegúrate de que las estadísticas estén actualizadas para mejorar el rendimiento de las consultas.
- **TempDB**: Asegúrate de que tempdb esté bien configurada, ya que afecta el rendimiento global. Considera múltiples archivos de datos para reducir la contención.

## Configuración de Memoria
- **Max Server Memory**: Ajusta la memoria máxima del servidor para evitar que SQL Server use toda la memoria del sistema.
- **Buffer Pool Extension**: Considera habilitar la extensión del pool de búfer para mejorar la eficiencia del uso de memoria.
- ```sql
  SELECT TOP 50 * 
  FROM sys.dm_os_performance_counters  
  WHERE counter_name IN ('Page Life Expectancy');
  ```

## Configuraciones de Concurrencia
- **Max Degree of Parallelism (MAXDOP)**: Ajusta este valor según las mejores prácticas para evitar el exceso de paralelismo.
- **Cost Threshold for Parallelism**: Establece un valor que permita el uso adecuado del paralelismo para consultas complejas.

## Seguridad
- **Permisos**: Revisa los permisos de los usuarios para asegurarte de que sólo tengan los necesarios.
- **Auditoría**: Implementa auditorías para registrar actividades críticas en la base de datos.

## Mantenimiento
- **Backups**: Asegúrate de que las copias de seguridad automáticas estén configuradas adecuadamente.
- **Mantenimiento de Índices**: Realiza mantenimientos periódicos para asegurar el buen estado de los índices.

## TempDB
- Asegúrate de que tempdb tenga suficientes archivos de datos para evitar contención de recursos.
- Coloca tempdb en un disco rápido y separado si es posible.

## Particionado
Divide tablas grandes en particiones para mejorar el rendimiento de las consultas y la administración de datos.

## Usa herramientas de monitoreo
- SQL Server Profiler o Extended Events.
- Analiza los wait types en sys.dm_os_wait_stats.

## Índices
- **Índices en columnas frecuentemente consultadas**: Crea índices en columnas que se usen en cláusulas WHERE, JOIN, y ORDER BY.
- **Evita índices en columnas con alta cardinalidad**: No crees índices en columnas con pocos valores únicos.
- **Mantén índices actualizados**: Usa REORGANIZE y REBUILD para mantener los índices en buen estado.

## Consulta Eficiente
- **Usa JOINs en lugar de subconsultas**: Las subconsultas anidadas pueden ser ineficientes.
- **Filtra temprano**: Aplica filtros en la cláusula WHERE para reducir el conjunto de datos lo antes posible.
- **Selecciona solo las columnas necesarias**: Evita el uso de SELECT *.

## Generales
Asegúrate de que las consultas usen índices adecuados.

## Adicionales
- **Índices grandes**
- **Índices que no se usan**
- **Índices duplicados**
- **Depuración a tablas pesadas o con muchos años**
- **Recomendaciones de particiones**

### Validaciones
1. **Validar que todas las tablas tengan PK**: Cuando en una tabla se asigna un primary key, esto genera en automático un índice agrupado, por lo que ya no se puede generar otro. No pueden existir 2 PK.

### Índices Eficientes
2.1. Identifica las consultas más comunes y crea índices adecuados para ellas.
2.2. Evita tener demasiados índices innecesarios, ya que pueden ralentizar las operaciones de inserción, actualización y eliminación.
2.3. Mantén actualizadas las estadísticas de índice para que el optimizador de consultas pueda generar planes de ejecución óptimos.
2.4. Columnas con más de 2 índices.
2.5. Evitar tablas sin índices clustered/agrupados.
2.6. No usar más índices que columnas.
2.7. Limitar la fragmentación de índices.

### Particionamiento de la Tabla
3. Fragmentación de índices.
4. Consultas eficientes.
5. Almacenamiento en disco SSD.
6. Re index.
7. Mantenimientos.
 



# Parametros de optimización de la tabla sys.databases
 

### 2. `is_read_committed_snapshot_on`
- **Objetivo**: Indica si la opción `READ_COMMITTED_SNAPSHOT` está habilitada para la base de datos.
- **Valores posibles**:
  - `0`: Deshabilitado.
  - `1`: Habilitado.
- **Ventajas**:
  - Mejora la concurrencia al permitir lecturas consistentes sin bloqueos.
  - Reduce los bloqueos de lectura.
- **Desventajas**:
  - Puede aumentar el uso de espacio en el disco debido a la versión de filas.
- **Recomendaciones**:
  - Útil en entornos con alta concurrencia de lecturas y escrituras.
- **Ejemplo**:
  ```sql
  SELECT name, is_read_committed_snapshot_on FROM sys.databases WHERE name = 'tu_base_de_datos';
  ```

### 3. `recovery_model_desc`
- **Objetivo**: Describe el modelo de recuperación de la base de datos.
- **Valores posibles**:
  - `SIMPLE`: No se realizan copias de seguridad del log de transacciones.
  - `FULL`: Se realizan copias de seguridad completas del log de transacciones.
  - `BULK_LOGGED`: Minimiza el registro de ciertas operaciones masivas.
- **Ventajas**:
  - `SIMPLE`: Menor administración y uso de espacio.
  - `FULL`: Permite la recuperación completa de datos.
  - `BULK_LOGGED`: Mejora el rendimiento en operaciones masivas.
- **Desventajas**:
  - `SIMPLE`: No permite la recuperación punto en el tiempo.
  - `FULL`: Mayor uso de espacio y administración.
  - `BULK_LOGGED`: No permite la recuperación punto en el tiempo durante operaciones masivas.
- **Recomendaciones**:
  - Elegir el modelo según las necesidades de recuperación y rendimiento.
- **Ejemplo**:
  ```sql
  SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'tu_base_de_datos';
  ```

### 4. `log_reuse_wait_desc`
- **Objetivo**: Describe la razón por la cual el espacio del log de transacciones no puede ser reutilizado.
- **Valores posibles**: Variados, como `CHECKPOINT`, `LOG_BACKUP`, `ACTIVE_TRANSACTION`, etc.
- **Ventajas**:
  - Ayuda a diagnosticar problemas de crecimiento del log de transacciones.
- **Desventajas**:
  - Puede requerir acciones administrativas para resolver el problema.
- **Recomendaciones**:
  - Monitorear regularmente y realizar copias de seguridad del log de transacciones.
- **Ejemplo**:
  ```sql
  SELECT name, log_reuse_wait_desc FROM sys.databases WHERE name = 'tu_base_de_datos';
  ```
 


