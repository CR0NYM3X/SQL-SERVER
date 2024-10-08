 

 
# Configuraciones Generales y Esenciales 

Base de datos: 
    - Recovery Model: Asegúrate de que el modelo de recuperación sea apropiado (FULL, SIMPLE, BULK_LOGGED) según tus necesidades de respaldo y restauración.
    - Auto Growth: Configura el crecimiento automático para que sea adecuado (por porcentaje o por tamaño específico) y evita el autogrowth en pequeñas cantidades frecuentes.

Rendimiento:
	Indexación: Verifica que las tablas más grandes y las más consultadas tengan índices adecuados y realiza mantenimientos periódicos.
	Estadísticas: Asegúrate de que las estadísticas estén actualizadas para mejorar el rendimiento de las consultas.
	TempDB: Asegúrate de que tempdb esté bien configurada, ya que afecta el rendimiento global. Considera múltiples archivos de datos para reducir la contención.


Configuración de Memoria:
	Max Server Memory: Ajusta la memoria máxima del servidor para evitar que SQL Server use toda la memoria del sistema.
	Buffer Pool Extension: Considera habilitar la extensión del pool de búfer para mejorar la eficiencia del uso de memoria.
	select top 50 * from sys.dm_os_performance_counters  where counter_name in( 'Page Life Expectancy' )

Configuraciones de Concurrencia:
	Max Degree of Parallelism (MAXDOP): Ajusta este valor según las mejores prácticas para evitar el exceso de paralelismo.
	Cost Threshold for Parallelism: Establece un valor que permita el uso adecuado del paralelismo para consultas complejas.

Seguridad:

	Permisos: Revisa los permisos de los usuarios para asegurarte de que sólo tengan los necesarios.
	Auditoría: Implementa auditorías para registrar actividades críticas en la base de datos.

Mantenimiento:
	Backups: Asegúrate de que las copias de seguridad automáticas estén configuradas adecuadamente.
	Mantenimiento de Índices: Real
	

TempDB:
	Asegúrate de que tempdb tenga suficientes archivos de datos para evitar contención de recursos.
	Coloca tempdb en un disco rápido y separado si es posible.


Particionado:
	Divide tablas grandes en particiones para mejorar el rendimiento de las consultas y la administración de datos.


Usa herramientas de monitoreo 
	SQL Server Profiler o Extended Events.
	Analiza los wait types en sys.dm_os_wait_stats.


Índices:
	Índices en columnas frecuentemente consultadas: Crea índices en columnas que se usen en cláusulas WHERE, JOIN, y ORDER BY.
	Evita índices en columnas con alta cardinalidad: No crees índices en columnas con pocos valores únicos.
	Mantén índices actualizados: Usa REORGANIZE y REBUILD para mantener los índices en buen estado.

Consulta Eficiente:
	Usa JOINs en lugar de subconsultas: Las subconsultas anidadas pueden ser ineficientes.
	Filtra temprano: Aplica filtros en la cláusula WHERE para reducir el conjunto de datos lo antes posible.
	Selecciona solo las columnas necesarias: Evita el uso de SELECT *.


Generales :  
	Asegúrate de que las consultas usen índices adecuados.
