


# Usando el Visor de Eventos:
```
Presiona Win + R, escribe eventvwr.msc y presiona Enter. Esto abrirá el Visor de Eventos.
- Los eventos relacionados con SQL Server podrían estar en los registros de Aplicación o Seguridad.
```

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



**Proporciona información sobre todos los mensajes de error del sistema en la base de datos actual.**
```
SELECT * FROM sys.messages WHERE language_id = 1033;
```

# funciones para validar errores  con TRY  - CATCH

```
BEGIN TRY
    -- Generar un error intencional
    SELECT 1/0;
END TRY
BEGIN CATCH
    -- Manejar el error
    SELECT ERROR_STATE(); -- Devuelve el estado de error del último error que ocurrió. 
    SELECT ERROR_SEVERITY();  -- Devuelve el nivel de gravedad del último error que ocurrió. 
    SELECT ERROR_NUMBER(); --  Devuelve el número de error del último error que ocurrió. Puede ser útil para identificar el código de error específico.
    SELECT ERROR_MESSAGE();  -- devuelve el mensaje de error asociado con el error más reciente. Es útil cuando estás en un bloque CATCH 
END CATCH;
```

# Examinar el log de transacciones
```SQL
SELECT [Current LSN], [Transaction ID], [Operation], [Context],
       [AllocUnitName], [Description]
FROM fn_dblog(NULL, NULL)
WHERE    ( CAST([Begin Time] AS DATETIME) BETWEEN  '20230810 11:40:00' and  '20230810 11:45:00' )
or  
CAST([End Time] AS DATETIME) BETWEEN  '20230810 11:40:00' and  '20230810 11:45:00'

/*
Operation: 
LOP_BEGIN_XACT y LOP_COMMIT_XACT = Inicio y final de transacción
LOP_MODIFY_ROW = indica que se modifico un registro 
*/

```
