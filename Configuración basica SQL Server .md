# Ver configuraciones 
La configuracion a nivel DB tiene mas prioridad ante la de nivel instancia por lo que primero toma la de nivel db 
```
-- Configuración a nivel de instancia o global 
SELECT * FROM sys.configurations;

-- Configuración a nivel de instancia o global 
EXECUTE sp_configure 'query wait'

--  Configuración a nivel de base de datos.
SELECT * FROM sys.database_scoped_configurations;

----------------- OBTENER TODAS LAS CONFIGURACIONES scoped--
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#db_scoped_configs') IS NOT NULL
    DROP TABLE #db_scoped_configs;

CREATE TABLE #db_scoped_configs (
    database_name                     sysname        NOT NULL,
    configuration_id                  int            NOT NULL,
    name                              sysname        NOT NULL,
    value                             sql_variant    NULL,
    value_for_secondary               sql_variant    NULL,
    is_value_default                  bit            NOT NULL
);

EXEC master..sp_MSforeachdb N'
    IF DB_ID(''?'' ) > 4 AND DATABASEPROPERTYEX(''?'' , ''Status'') = ''ONLINE''
    BEGIN
        USE [?];
        INSERT INTO #db_scoped_configs
        SELECT DB_NAME(), configuration_id, name, value, value_for_secondary,
               is_value_default
        FROM sys.database_scoped_configurations;
    END
';

SELECT *
FROM #db_scoped_configs
ORDER BY database_name, configuration_id;

 

```
---


1. **Query Governor Cost Limit** - Esta configuración previene que se ejecuten consultas que el optimizador estima tomarán más tiempo del especificado:

```sql
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'query governor cost limit', 3600; -- En segundos
GO
RECONFIGURE;
GO
```


2. **Resource Governor** - Te permite establecer límites de recursos por grupo de usuarios:
Permite clasificar y administrar los recursos de CPU entre diferentes grupos de trabajo.

```SQL
-- Habilitar Resource Governor
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.MiClasificacion);
ALTER RESOURCE GOVERNOR RECONFIGURE;


ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- Crear un pool para consultas largas
Paso 1: Crear un Pool de Recursos:
CREATE RESOURCE POOL LongQueriesPool
WITH (
    MIN_CPU_PERCENT = 20,
    MAX_CPU_PERCENT = 50, -- Máximo uso de CPU
    MAX_MEMORY_PERCENT = 50, -- Máximo uso de memoria
    REQUEST_MAX_TIME_SEC = 18000 -- 5 horas en segundos
);
GO

Paso 2: Crear una Clasificación de Carga de Trabajo:
CREATE WORKLOAD GROUP MiWorkloadGroup
USING MiResourcePool;



Paso 3: Configurar una Función de Clasificación:
CREATE FUNCTION dbo.MiClasificacion()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @GrupoTrabajo AS sysname;
    
    -- Aquí puedes añadir lógica para clasificar las solicitudes
    IF (APP_NAME() = 'MiAplicacion')
        SET @GrupoTrabajo = 'MiWorkloadGroup';
    ELSE
        SET @GrupoTrabajo = 'default';
    
    RETURN @GrupoTrabajo;
END;
GO




```


3. **Configurar Timeout a nivel de conexión** en el connection string de las aplicaciones (timeout=300)

```SQL
USE master;
GO
EXECUTE sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXECUTE sp_configure 'query wait', 300; -- segundos
GO
RECONFIGURE;
GO
EXECUTE sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO
```
 
 
# Que hacer si cambian el hostname del S.O 

```SQL
-- Tutorial : https://www.youtube.com/watch?v=xIcCU0oaavE
-------- Esto Requiere reinicio de la instancia

-- Eliminar el nombre anterior
EXEC sp_dropserver 'SRVSQL01';

-- Agregar el nuevo hostname nombre como local
EXEC sp_addserver 'SRVSQLPROD', 'local';


-- Consultar
SELECT @@SERVERNAME AS NombreServidorSQL;


SELECT SERVERPROPERTY('MachineName') AS HostnameWindows,
       SERVERPROPERTY('ServerName') AS NombreInstancia, -- este es el importante de la instancia
       SERVERPROPERTY('InstanceName') AS NombreInstanciaSQL;

SELECT name, data_source, is_linked FROM sys.servers ;



```

