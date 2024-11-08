# 

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
 
 
