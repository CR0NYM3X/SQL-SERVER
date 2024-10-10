 
 
# Configuraciones Generales y Esenciales

## Configuración a nivel Base de datos 
```Markdown
## Recovery Model
Asegúrate de que el modelo de recuperación sea apropiado (FULL, SIMPLE, BULK_LOGGED) según tus necesidades de respaldo y restauración.

## Auto Growth
Configura el crecimiento automático para que sea adecuado (por porcentaje o por tamaño específico) y evita el autogrowth en pequeñas cantidades frecuentes.

```

## Configuraciones a nivel Servidor SQL server 
```Markdown
************ Concurrencia ************ 
## Max Degree of Parallelism (MAXDOP):
Ajusta este valor según las mejores prácticas para evitar el exceso de paralelismo.

## Cost Threshold for Parallelism:
Establece un valor que permita el uso adecuado del paralelismo para consultas complejas.

************ Memoria ************ 
## Max Server Memory
Ajusta la memoria máxima del servidor para evitar que SQL Server use toda la memoria del sistema.

## Buffer Pool Extension
Considera habilitar la extensión del pool de búfer para mejorar la eficiencia del uso de memoria.

```

## TempDB
TempDB es una base de datos del sistema en SQL Server que se utiliza para almacenar datos temporales y objetos como tablas temporales, variables de tabla, y datos intermedios durante operaciones de clasificación y agregación . Es una base de datos no duradera, lo que significa que se recrea cada vez que se reinicia el servicio SQL Server 

```Markdown

- Habilita el tempdb metadata memory-optimized en versiones 2019 en adelante 
- **TempDB**: Asegúrate de que tempdb esté bien configurada, ya que afecta el rendimiento global. Considera múltiples archivos de datos para reducir la contención.
 
1. **Pre-dimensionamiento de TempDB**
   - **Descripción**: Asignar un tamaño inicial adecuado para evitar el crecimiento automático frecuente.
   - **Acción**: Configurar el tamaño inicial de TempDB para que sea al menos el 25% del tamaño de la base de datos más grande

2. **Ubicación en Discos Rápidos**
   - **Descripción**: Colocar los archivos de TempDB en discos SSD para mejorar el rendimiento de E/S.
   - **Acción**: Utilizar discos SSD dedicados para los archivos de datos y log de TempDB 

3. **Separación de Archivos de Datos y Log**
   - **Descripción**: Mantener los archivos de datos y log en discos separados para aprovechar las operaciones de E/S paralelas.
   - **Acción**: Configurar discos separados para los archivos de datos y log 

4. **Múltiples Archivos de Datos**
   - **Descripción**: Crear múltiples archivos NDF de datos para distribuir la carga de trabajo.
   - **Acción**: Crear un archivo de datos por cada núcleo lógico del procesador, hasta un máximo de 8

5. **Configurar FileGrowth a un Valor Fijo Grande**
   - **Descripción**: Establecer un valor fijo grande para el crecimiento automático de los archivos de TempDB.
   - **Acción**: Configurar el crecimiento automático de los archivos de TempDB a un valor fijo grande para evitar la sobrecarga en la CPU 

6. **Habilitar Trace Flags 1117 y 1118**
   - **Descripción**: Reducir la contención en la metadata.
   - **Acción**: Habilitar estos trace flags si se utiliza una versión anterior a SQL Server 2016 

7. **Optimización de la Contención de Asignación**
   - **Descripción**: Reducir la contención en las páginas de asignación (PFS, SGAM).
   - **Acción**: Aumentar el número de archivos de datos y asegurarse de que tengan un tamaño igual

8. **Monitoreo y Mantenimiento Regular**
   - **Descripción**: Realizar un monitoreo constante del uso de TempDB y planificar tareas de mantenimiento.
   - **Acción**: Utilizar herramientas de monitoreo como SQL Sentry para identificar y resolver problemas de rendimiento
 

```

 
## Índices
```Markdown
## Índices que no se usan
## Índices duplicados
## Identifica Índices grandes
## Índices Perdidos:
	Crear Índices en columnas frecuentemente consultadas: Crea índices en columnas que se usen en cláusulas WHERE, JOIN, y ORDER BY.
## Evita índices en columnas con alta cardinalidad:
	No crees índices en columnas con pocos valores únicos.
## Evita tener demasiados índices innecesarios
	 ya que pueden ralentizar las operaciones de inserción, actualización y eliminación.
## Mantén índices actualizados:
	Usa REORGANIZE y REBUILD para mantener los índices en buen estado.para que el optimizador de consultas pueda generar planes de ejecución óptimos. 
## Evitar tablas sin índices clustered/agrupados.
## No usar más índices que columnas.
## Limitar la fragmentación de índices.
```

## Tablas 
```Markdown
	- Depuración a tablas pesadas o con muchos años

	- Evita Tablas sin Index
	- Evita Tablas sin PK

************ Particionamiento ************ 
	- Divide tablas grandes en particiones para mejorar el rendimiento de las consultas y la administración de datos.
	- Almacenamiento en disco SSD.
```


## Consulta Eficiente
- **Usa JOINs en lugar de subconsultas**: Las subconsultas anidadas pueden ser ineficientes.
- **Filtra temprano**: Aplica filtros en la cláusula WHERE para reducir el conjunto de datos lo antes posible.
- **Selecciona solo las columnas necesarias**: Evita el uso de SELECT *.

## Mantenimiento
- **Backups**: Asegúrate de que las copias de seguridad automáticas estén configuradas adecuadamente.
- **Mantenimiento de Índices**: Realiza mantenimientos periódicos para asegurar el buen estado de los índices.
- **Estadísticas**: Asegúrate de que las estadísticas estén actualizadas para mejorar el rendimiento de las consultas.

 
 
## Usa herramientas de monitoreo
- SQL Server Profiler o Extended Events.
- Analiza los wait types en sys.dm_os_wait_stats.


## Seguridad
- **Permisos**: Revisa los permisos de los usuarios para asegurarte de que sólo tengan los necesarios.
- **Auditoría**: Implementa auditorías para registrar actividades críticas en la base de datos.




--- 
# Parametros de optimización de la tabla sys.databases
 
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
 



### 2. `is_read_committed_snapshot_on`
- **Objetivo**: Indica si la opción `READ_COMMITTED_SNAPSHOT` está habilitada para la base de datos.
- **Valores posibles**:
  - `0`: Deshabilitado.
  - `1`: Habilitado.
- **Ventajas**:
  - Mejora la concurrencia al permitir lecturas consistentes sin bloqueos.
  - Reduce los bloqueos de lectura.
- **Desventajas**:
  - Sobrecarga de almacenamiento: Mantener versiones de fila puede aumentar el uso de espacio en tempdb, ya que es donde se almacenan las versiones anteriores de las filas.
  -  no puede ser configurada a nivel de sesión.
- **Recomendaciones**:
  - Útil en entornos con alta concurrencia de lecturas y escrituras.
  - 
- **Ejemplo**:
  ```sql

  ******** VALIDAR EL VALOR ACTUAL  **********
  SELECT name, is_read_committed_snapshot_on FROM sys.databases WHERE name = 'tu_base_de_datos';

  ******** ACTIVAR EL VALOR ACTUAL  **********
  ALTER DATABASE [TuBaseDeDatos] SET READ_COMMITTED_SNAPSHOT ON;

   ******** DESACTIVAR EL VALOR ACTUAL  **********
  ALTER DATABASE [TuBaseDeDatos] SET READ_COMMITTED_SNAPSHOT OFF;
  ```



### `is_read_committed_snapshot_on` = `ON`

#### Recomendado:
1. **Aplicaciones con Alta Concurrencia**:
   - **Ejemplo**: Una aplicación web de comercio electrónico con muchos usuarios simultáneos realizando consultas y actualizaciones.
   - **Motivo**: Ayuda a reducir los bloqueos y mejorar la concurrencia al permitir que las transacciones lean versiones consistentes de los datos sin bloquearse entre 

2. **Sistemas de Reportes en Tiempo Real**:
   - **Ejemplo**: Un sistema de análisis de datos en tiempo real donde los usuarios necesitan acceder a datos actualizados constantemente.
   - **Motivo**: Permite que las consultas de lectura no se bloqueen por las transacciones de escritura, mejorando el rendimiento de los reportes 

#### No Recomendado:
1. **Bases de Datos con Transacciones Críticas**:
   - **Ejemplo**: Sistemas bancarios donde la precisión y la consistencia de las transacciones son críticas.
   - **Motivo**: Puede introducir problemas de consistencia si no se maneja adecuadamente, ya que las lecturas pueden no reflejar el estado más reciente de los datos 

2. **Aplicaciones con Baja Concurrencia**:
   - **Ejemplo**: Aplicaciones internas con pocos usuarios y transacciones esporádicas.
   - **Motivo**: El beneficio de reducir bloqueos es mínimo y puede no justificar el overhead adicional de mantener versiones de datos




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
  ******** VALIDAR EL VALOR ACTUAL  **********
  SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'tu_base_de_datos';

  ******** MODIFICAR EL PARAMETRO  **********
  ALTER DATABASE [TuBaseDeDatos] SET RECOVERY SIMPLE;
  ```


### `recovery_model_desc` = `Simple`

#### Recomendado:
1. **Bases de Datos Temporales o de Pruebas**:
   - **Ejemplo**: Bases de datos utilizadas para pruebas de desarrollo o almacenamiento temporal de datos.
   - **Motivo**: No se requiere un respaldo detallado del log de transacciones, lo que simplifica la administración y mejora el rendimiento

2. **Sistemas con Baja Necesidad de Recuperación**:
   - **Ejemplo**: Aplicaciones donde la pérdida de datos recientes es aceptable y se puede recuperar fácilmente.
   - **Motivo**: Minimiza el uso del log de transacciones y reduce la necesidad de administración de respaldos 

#### No Recomendado:
1. **Sistemas Críticos de Producción**:
   - **Ejemplo**: Bases de datos de producción que requieren alta disponibilidad y recuperación ante desastres.
   - **Motivo**: No permite la recuperación a un punto en el tiempo, lo que puede resultar en pérdida de datos significativa en caso de fallo 

2. **Bases de Datos con Replicación o Alta Disponibilidad**:
   - **Ejemplo**: Sistemas que utilizan log shipping, Always On Availability Groups o mirroring.
   - **Motivo**: Estas características requieren un modelo de recuperación FULL   para funcionar correctamente 




# Buffer Pool Extension
El **Buffer Pool Extension** en SQL Server sirve para mejorar el rendimiento de las operaciones de entrada/salida (I/O) al extender la memoria caché del buffer pool utilizando almacenamiento no volátil, como unidades de estado sólido (SSD). Aquí te explico sus principales beneficios:

### Beneficios del Buffer Pool Extension

1. **Aumento del Rendimiento de I/O Aleatorio**:
   - **Descripción**: Al utilizar SSDs, que tienen menor latencia y mejor rendimiento en I/O aleatorio comparado con discos mecánicos, se mejora significativamente el rendimiento de las operaciones de lectura y escritura pequeñas y aleatorias 

2. **Reducción de la Latencia de I/O**:
   - **Descripción**: Al almacenar páginas de datos en el SSD, se reduce la necesidad de acceder a discos mecánicos, lo que disminuye la latencia de las operaciones de I/O 

3. **Mayor Rendimiento de Transacciones**:
   - **Descripción**: Con un buffer pool más grande, se pueden manejar más transacciones simultáneamente, mejorando el rendimiento general del sistema 

4. **Mejora del Rendimiento de Lectura**:
   - **Descripción**: Al tener una caché híbrida más grande (RAM + SSD), se mejora el rendimiento de lectura, ya que más datos pueden ser almacenados en la memoria caché rápida 

### Cuándo Usar Buffer Pool Extension

1. **Limitaciones de Memoria RAM**:
   - Si tu servidor tiene limitaciones de memoria RAM y no puedes agregar más memoria física, habilitar BPE puede ayudar a mejorar el rendimiento al usar un SSD como extensión de la memoria 

2. **Carga de Trabajo con Alta I/O Aleatoria**:
   - En escenarios donde hay muchas operaciones de lectura/escritura aleatorias pequeñas, BPE puede reducir la latencia y mejorar el rendimiento general del sistema 

3. **Presupuesto Limitado**:
   - Si no puedes invertir en más memoria RAM debido a restricciones presupuestarias, usar un SSD para extender el buffer pool puede ser una solución más económica 

### Cuándo No Usar Buffer Pool Extension

1. **Disponibilidad de Memoria RAM Suficiente**:
   - Si tu servidor ya tiene suficiente memoria RAM para manejar la carga de trabajo, habilitar BPE no proporcionará beneficios adicionales significativos 

2. **Discos SSD de Baja Calidad**:
   - Usar SSDs de baja calidad o con baja durabilidad puede resultar en un desgaste rápido del disco, lo que podría afectar negativamente el rendimiento y la fiabilidad del sistema 

3. **Carga de Trabajo con Alta I/O Secuencial**:
   - En escenarios donde las operaciones de I/O son principalmente secuenciales, los beneficios de BPE serán mínimos, ya que los discos mecánicos pueden manejar bien este tipo de carga 
 


### Funcionamiento

El Buffer Pool Extension crea una extensión del buffer pool en un SSD, permitiendo que las páginas de datos que son expulsadas de la memoria RAM se almacenen en el SSD en lugar de ser leídas y escritas directamente en discos mecánicos. Esto ayuda a mantener un mayor número de páginas de datos en almacenamiento rápido, mejorando el rendimiento de las consultas y transacciones 

### Ejemplo de Uso

- **Sistema de Análisis de Datos**: En un sistema de análisis de datos con alta carga de lectura, el Buffer Pool Extension puede mejorar el rendimiento al reducir la latencia de las operaciones de lectura y permitir que más datos se mantengan en la memoria caché rápida 
 
 
1. **Verificar la Configuración Actual**:
   Utiliza la siguiente consulta para revisar la configuración actual del Buffer Pool Extension:
   ```sql
   SELECT [path], state_description, current_size_in_kb, 
          CAST(current_size_in_kb/1048576.0 AS DECIMAL(10,2)) AS [Size (GB)]
   FROM sys.dm_os_buffer_pool_extension_configuration;
   ```

2. **Habilitar y Deshabilitar el Buffer Pool Extension**:
   Si aún no está habilitado, puedes activarlo con el siguiente comando. Asegúrate de ajustar la ruta del archivo y el tamaño según tus necesidades:
   ```sql
   
   **Habilitar el Buffer Pool Extension**
   ALTER SERVER CONFIGURATION SET BUFFER POOL EXTENSION ON 
   (FILENAME = 'C:\\Temp\\BP_Extension.BPE', SIZE = 2 GB);
   
   **Deshabilitar el Buffer Pool Extension**
    ALTER SERVER CONFIGURATION SET BUFFER POOL EXTENSION OFF;
   ```

3. **Validar el Uso del Buffer Pool Extension**:
   Después de habilitarlo, puedes ejecutar una consulta para verificar qué datos están siendo almacenados en el Buffer Pool Extension:
   ```sql
   SELECT DB_NAME(database_id) AS [Database Name], COUNT(page_id) AS [Page Count], 
          CAST(COUNT(*)/128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)], 
          AVG(read_microsec) AS [Avg Read Time (microseconds)]
   FROM sys.dm_os_buffer_descriptors
   WHERE database_id <> 32767 AND is_in_bpool_extension = 1
   GROUP BY DB_NAME(database_id)
   ORDER BY [Buffer size(MB)] DESC;
   ```




 
# Max Server Memory
Limita la cantidad máxima de memoria que SQL Server puede usar, asegurando que no consuma toda la memoria del sistema.
#### Recomendado:
1. **Servidores con Múltiples Aplicaciones**:
   - **Ejemplo**: Un servidor que aloja SQL Server junto con otras aplicaciones como servicios web o aplicaciones de negocio.
   - **Motivo**: Limitar la memoria máxima de SQL Server asegura que otras aplicaciones tengan suficiente memoria para funcionar correctamente

2. **Entornos de Pruebas o Desarrollo**:
   - **Ejemplo**: Un entorno de desarrollo donde varios desarrolladores están probando diferentes aplicaciones en el mismo servidor.
   - **Motivo**: Evita que SQL Server consuma toda la memoria disponible, permitiendo que otras aplicaciones de desarrollo funcionen sin problemas 

#### No Recomendado:
1. **Servidores Dedicados a SQL Server**:
   - **Ejemplo**: Un servidor dedicado exclusivamente a SQL Server sin otras aplicaciones críticas.
   - **Motivo**: Limitar la memoria puede no ser necesario y podría impedir que SQL Server utilice toda la memoria disponible para mejorar el rendimiento 

2. **Sistemas con Alta Disponibilidad de Memoria**:
   - **Ejemplo**: Un servidor con abundante memoria RAM que no tiene problemas de recursos.
   - **Motivo**: No es necesario limitar la memoria si hay suficiente disponible para todas las aplicaciones 

- **Ejemplo**:
  ```sql
  ******** VALIDAR EL VALOR ACTUAL  **********
	select *  FROM sys.configurations WITH (NOLOCK) where name like 'Max Server Memory%';
	
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	
	EXEC sp_configure 'max server memory', <valor_en_MB>;
	RECONFIGURE;
	
  ```


# Cost Threshold for Parallelism
Define el costo mínimo de una consulta para que SQL Server considere ejecutarla en paralelo.
#### Recomendado:
1. **Consultas Complejas y Pesadas**:
   - **Ejemplo**: Un sistema de análisis de datos que ejecuta consultas complejas que requieren mucho tiempo de procesamiento.
   - **Motivo**: Aumentar el umbral permite que solo las consultas realmente costosas se ejecuten en paralelo, mejorando el rendimiento general 

2. **Sistemas con Alta Carga de CPU**:
   - **Ejemplo**: Un servidor con múltiples procesadores que maneja una alta carga de trabajo.
   - **Motivo**: Ajustar el umbral puede ayudar a distribuir mejor la carga de trabajo entre los procesadores 

#### No Recomendado:
1. **Consultas Simples y Rápidas**:
   - **Ejemplo**: Un sistema que ejecuta principalmente consultas simples y rápidas.
   - **Motivo**: Un umbral alto puede evitar que las consultas simples se beneficien del paralelismo, lo que podría ralentizar el rendimiento 

2. **Sistemas con Pocos Procesadores**:
   - **Ejemplo**: Un servidor con pocos núcleos de CPU.
   - **Motivo**: El beneficio del paralelismo es limitado en sistemas con pocos procesadores, y un umbral alto puede no ser necesario 

- **Ejemplo**:
  ```sql
  ******** VALIDAR EL VALOR ACTUAL  **********
	select *  FROM sys.configurations WITH (NOLOCK) where name = 'cost threshold for parallelism';
	
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	
	EXEC sp_configure 'cost threshold for parallelism', <valor>;
	RECONFIGURE;
	
  ```


# Max Degree of Parallelism
Establece el número máximo de procesadores que se pueden usar para ejecutar una sola consulta en paralelo.
#### Recomendado:
1. **Sistemas de Data Warehouse**:
   - **Ejemplo**: Un data warehouse que ejecuta consultas de agregación y análisis de grandes volúmenes de datos.
   - **Motivo**: Permitir un alto grado de paralelismo puede mejorar significativamente el rendimiento de las consultas

2. **Servidores con Múltiples Núcleos de CPU**:
   - **Ejemplo**: Un servidor con muchos núcleos de CPU disponibles.
   - **Motivo**: Aprovechar todos los núcleos disponibles puede mejorar el rendimiento de las consultas paralelas 

#### No Recomendado:
1. **Consultas con Baja Carga de Trabajo**:
   - **Ejemplo**: Un sistema que ejecuta principalmente consultas ligeras y rápidas.
   - **Motivo**: Un alto grado de paralelismo puede introducir overhead innecesario y no mejorar el rendimiento 

2. **Sistemas con Alta Contención de Recursos**:
   - **Ejemplo**: Un servidor donde múltiples aplicaciones compiten por los recursos de CPU.
   - **Motivo**: Limitar el paralelismo puede ayudar a reducir la contención de recursos y mejorar la estabilidad del sistema

- **Ejemplo**:
  ```sql
  ******** VALIDAR EL VALOR ACTUAL  **********
	select *  FROM sys.configurations WITH (NOLOCK) where name = 'max degree of parallelism';
	
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	
	EXEC sp_configure 'max degree of parallelism', <valor>;
	RECONFIGURE;
	
  ```




# Page Life Expectancy
Mide el tiempo promedio que una página de datos permanece en la memoria antes de ser reemplazada, ayudando a evaluar el rendimiento de la memoria del servidor.
#### Recomendado:
1. **Sistemas con Alta Carga de Lectura**:
   - **Ejemplo**: Un sistema de análisis de datos que realiza muchas operaciones de lectura.
   - **Motivo**: Un alto valor de PLE indica que las páginas de datos permanecen en la memoria más tiempo, mejorando el rendimiento de las lecturas

2. **Servidores con Suficiente Memoria RAM**:
   - **Ejemplo**: Un servidor con abundante memoria RAM que puede mantener un alto PLE.
   - **Motivo**: Un alto PLE puede mejorar el rendimiento general del sistema al reducir la necesidad de acceder al disco 

#### No Recomendado:
1. **Sistemas con Alta Carga de Escritura**:
   - **Ejemplo**: Un sistema de transacciones financieras que realiza muchas operaciones de escritura.
   - **Motivo**: Un alto PLE puede no ser tan crítico en sistemas donde las escrituras son más frecuentes que las lecturas 

2. **Servidores con Memoria Limitada**:
   - **Ejemplo**: Un servidor con memoria RAM limitada.
   - **Motivo**: Mantener un alto PLE puede ser difícil y no siempre práctico en servidores con recursos de memoria limitados 
 
- **Ejemplo**:
  ```sql
  
  Este parámetro mide el tiempo promedio (en segundos) que una página de datos permanece en la memoria antes de ser reemplazada. 
  ******** VALIDAR EL VALOR ACTUAL  **********
	SELECT TOP 50 * FROM sys.dm_os_performance_counters  WHERE counter_name IN ('Page Life Expectancy');
	
	 
  ```




# TempDB Metadata Memory-Optimized

#### ¿Para qué sirve?
La característica **TempDB Metadata Memory-Optimized** en SQL Server 2019 y versiones posteriores está diseñada para mejorar el rendimiento de TempDB al mover las tablas de metadatos del sistema más utilizadas a tablas optimizadas para memoria . Esto reduce la contención en las páginas de asignación y mejora la eficiencia de las operaciones que involucran tablas temporales y otras estructuras de TempDB 

#### Ventajas
- **Reducción de Contención**: Al mover los metadatos a tablas optimizadas para memoria, se reduce la contención en las páginas de asignación (PFS, GAM, SGAM), mejorando el rendimiento en entornos con alta concurrencia 
- **Mejora del Rendimiento**: Las tablas optimizadas para memoria ofrecen baja latencia y alta capacidad de procesamiento, lo que acelera las operaciones que dependen de TempDB 
- **Eficiencia en Operaciones Temporales**: Mejora la eficiencia de las operaciones que crean, alteran y eliminan tablas temporales, así como otras estructuras de TempDB 

#### Desventajas
- **Consumo de Memoria**: Esta característica puede aumentar significativamente el consumo de memoria, lo que podría llevar a errores de falta de memoria si no se gestiona adecuadamente 
- **Complejidad de Configuración**: Requiere una configuración cuidadosa y monitoreo constante para evitar problemas de rendimiento relacionados con el uso de memoria 
- **Compatibilidad**: No todas las versiones de SQL Server soportan esta característica, y puede no ser adecuada para todos los entornos 

#### Ejemplos Reales de Cuándo Usarlo
- **Alta Concurrencia**: En entornos con alta concurrencia donde muchas sesiones están creando y manipulando tablas temporales simultáneamente 
- **Operaciones Intensivas en TempDB**: Cuando se realizan operaciones intensivas en TempDB que causan contención en las páginas de asignación 

#### Ejemplos Reales de Cuándo No Usarlo
- **Limitaciones de Memoria**: En sistemas con limitaciones de memoria donde el aumento en el consumo de memoria podría causar problemas de rendimiento 
- **Baja Concurrencia**: En entornos con baja concurrencia donde la contención en TempDB no es un problema significativo 

### Cómo Habilitar TempDB Metadata Memory-Optimized
Para habilitar esta característica, sigue estos pasos:

1. **Modificar la Configuración del Servidor**:
   ```sql
   ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
   GO
   ```

2. **Reiniciar el Servicio de SQL Server**:
   - Después de ejecutar el comando anterior, reinicia el servicio de SQL Server para que los cambios surtan efecto 

3. **Verificar la Configuración**:
   ```sql
   SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');
   GO
   ```
 



### 1. Pre-dimensionamiento de TempDB
**Descripción**: Configurar el tamaño inicial de la base de datos TempDB para evitar el crecimiento automático frecuente.
**Ventajas**:
- Reduce la fragmentación.
- Mejora el rendimiento al evitar el crecimiento automático frecuente.
**Desventajas**:
- Requiere estimar correctamente el tamaño necesario.
**Ejemplo**:
- **Cuándo configurarlo**: En sistemas con alta actividad en TempDB, como grandes operaciones de ordenamiento o uso intensivo de tablas temporales.
- **Cuándo no configurarlo**: En sistemas pequeños o con baja actividad en TempDB.


### 4. Múltiples Archivos de Datos
**Descripción**: Dividir TempDB en múltiples archivos de datos para distribuir la carga de trabajo.
**Ventajas**:
- Mejora el rendimiento al reducir la contención en las páginas de asignación.
- Distribuye la carga de I/O.
**Desventajas**:
- Requiere configuración y monitoreo adicionales.
**Ejemplo**:
- **Cuándo configurarlo**: En servidores con múltiples CPUs y alta concurrencia de transacciones.
- **Cuándo no configurarlo**: En servidores con pocas CPUs o baja concurrencia.


### 5. Configurar FileGrowth a un Valor Fijo Grande
**Descripción**: Configurar el crecimiento automático de los archivos de TempDB a un valor fijo grande en lugar de un porcentaje.
**Ventajas**:
- Reduce la frecuencia de eventos de crecimiento.
- Minimiza la fragmentación.
**Desventajas**:
- Puede requerir más espacio en disco.
**Ejemplo**:
- **Cuándo configurarlo**: En bases de datos con crecimiento rápido y constante.
- **Cuándo no configurarlo**: En bases de datos pequeñas o con crecimiento lento.


### 6. Habilitar Trace Flags 1117 y 1118
**Descripción**: 
- **Trace Flag 1117**: Hace que todos los archivos de TempDB crezcan al mismo tiempo.
- **Trace Flag 1118**: Fuerza la asignación de páginas en extensiones uniformes en lugar de mixtas.
**Ventajas**:
- Reduce la contención en TempDB.
- Mejora el rendimiento de asignación de páginas.
**Desventajas**:
- No es necesario en SQL Server 2016 y versiones posteriores, ya que estas configuraciones son predeterminadas.
**Ejemplo**:
- **Cuándo configurarlo**: En versiones de SQL Server anteriores a 2016.
- **Cuándo no configurarlo**: En SQL Server 2016 y versiones posteriores.


### 7. Optimización de la Contención de Asignación
**Descripción**: Técnicas para reducir la contención en las páginas de asignación de TempDB.
**Ventajas**:
- Mejora el rendimiento en entornos con alta concurrencia.
- Reduce los bloqueos y esperas en TempDB.
**Desventajas**:
- Requiere monitoreo y ajustes continuos.
**Ejemplo**:
- **Cuándo configurarlo**: En sistemas con alta concurrencia y uso intensivo de TempDB.
- **Cuándo no configurarlo**: En sistemas con baja concurrencia y uso moderado de TempDB.




--------------------------------


### 1. Pre-dimensionamiento de TempDB
**Configuración**:
1. Abre SQL Server Management Studio (SSMS).
2. Conéctate a tu instancia de SQL Server.
3. Ejecuta el siguiente script para establecer el tamaño inicial de los archivos de TempDB:
   ```sql
   USE master;
   GO
   ALTER DATABASE tempdb 
   MODIFY FILE (NAME = tempdev, SIZE = 1024MB); -- Ajusta el tamaño según tus necesidades
   ALTER DATABASE tempdb 
   MODIFY FILE (NAME = templog, SIZE = 512MB); -- Ajusta el tamaño según tus necesidades
   GO
   ```

### 4. Múltiples Archivos de Datos
**Configuración**:
1. Abre SSMS y conéctate a tu instancia de SQL Server.
2. Ejecuta el siguiente script para agregar múltiples archivos de datos a TempDB:
   ```sql
   USE master;
   GO
   ALTER DATABASE tempdb 
   ADD FILE (NAME = tempdev2, FILENAME = 'C:\TempDB\tempdev2.ndf', SIZE = 1024MB);
   ALTER DATABASE tempdb 
   ADD FILE (NAME = tempdev3, FILENAME = 'C:\TempDB\tempdev3.ndf', SIZE = 1024MB);
   ALTER DATABASE tempdb 
   ADD FILE (NAME = tempdev4, FILENAME = 'C:\TempDB\tempdev4.ndf', SIZE = 1024MB);
   GO
   ```

### 5. Configurar FileGrowth a un Valor Fijo Grande
**Configuración**:
1. Abre SSMS y conéctate a tu instancia de SQL Server.
2. Ejecuta el siguiente script para establecer el crecimiento automático a un valor fijo:
   ```sql
   USE master;
   GO
   ALTER DATABASE tempdb 
   MODIFY FILE (NAME = tempdev, FILEGROWTH = 256MB); -- Ajusta el valor según tus necesidades
   ALTER DATABASE tempdb 
   MODIFY FILE (NAME = templog, FILEGROWTH = 128MB); -- Ajusta el valor según tus necesidades
   GO
   ```

### 6. Habilitar Trace Flags 1117 y 1118
**Configuración**:
1. Abre SSMS y conéctate a tu instancia de SQL Server.
2. Ejecuta el siguiente script para habilitar los trace flags:
   ```sql
   DBCC TRACEON (1117, -1);
   DBCC TRACEON (1118, -1);
   GO
   ```
3. Para hacer estos cambios permanentes, agrega los trace flags al parámetro de inicio del servicio SQL Server:
   - Abre SQL Server Configuration Manager.
   - Selecciona tu instancia de SQL Server y abre las propiedades.
   - En la pestaña **Startup Parameters**, agrega `-T1117` y `-T1118`.
 


# Bibliofrafía :
```sql

https://www.mssqltips.com/sqlservertip/7012/rebuild-tempdb-sql-server/
https://www.mssqltips.com/sqlservertip/6230/memoryoptimized-tempdb-metadata-in-sql-server-2019/
https://www.mssqltips.com/sqlservertip/6763/sql-server-tempdb-database-facts/
https://www.mssqltips.com/sqlservertip/6493/sql-server-tempdb-tutorial/
https://www.mssqltips.com/sqlservertip/3276/sql-server-alert-for-tempdb-growing-out-of-control/
https://www.mssqltips.com/sqlservertip/1432/tempdb-configuration-best-practices-in-sql-server/
https://www.mssqltips.com/sqlservertip/1388/properly-sizing-the-sql-server-tempdb-database/
```

