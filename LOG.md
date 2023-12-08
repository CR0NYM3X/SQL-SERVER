

# Verificar errores
**xp_readerrorlog** se utiliza para leer los archivos de registro de errores de SQL Server. Estos archivos de registro almacenan información detallada sobre eventos, mensajes de error, advertencias
```
xp_readerrorlog 0, 1, N'Logging SQL Server messages in file', NULL, NULL, N'asc'

****** Especificar un número de archivo de registro: ********
EXEC sp_readerrorlog 0, 1


****** Aplicar filtros de búsqueda: ******
EXEC sp_readerrorlog 0, 1, 'error'
EXEC sp_readerrorlog 0, 1, 'Login failed'
EXEC sp_readerrorlog 0, 1, 'Error: 18456' -- problemas de inicio de sesión.
EXEC sp_readerrorlog 0, 1, 'Backup' -- problemas o confirmar si las copias de seguridad se están realizando correctamente. 
EXEC sp_readerrorlog 0, 1, 'DatabaseName' --  experimentando problemas con una base de datos  
EXEC sp_readerrorlog 0, 1, 'Restore' --  identificar eventos de restauración de base de datos
EXEC sp_readerrorlog 0, 1, 'I/O' --  identificar eventos relacionados con problemas de E/S (entrada/salida), lo que puede ser útil para problemas de rendimiento o de disco.



****** Filtrar por fecha: ****** 
EXEC sp_readerrorlog 0, 1, '2023-01-01', '2023-12-31'

```

# Examinar el log de transacciones
```
SELECT [Current LSN], [Transaction ID], [Operation], [Context],
       [AllocUnitName], [Description]
FROM fn_dblog(NULL, NULL)
WHERE    ( CAST([Begin Time] AS DATETIME) BETWEEN  '20230810 11:40:00' and  '20230810 11:45:00' )
or  
CAST([End Time] AS DATETIME) BETWEEN  '20230810 11:40:00' and  '20230810 11:45:00'
```
