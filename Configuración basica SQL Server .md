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

```SQL
-- Habilitar Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- Crear un pool para consultas largas
CREATE RESOURCE POOL LongQueriesPool
WITH (
    MAX_CPU_PERCENT = 50, -- Máximo uso de CPU
    MAX_MEMORY_PERCENT = 50, -- Máximo uso de memoria
    REQUEST_MAX_TIME_SEC = 18000 -- 5 horas en segundos
);
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
 
 
