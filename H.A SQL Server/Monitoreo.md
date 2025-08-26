Para saber si estás conectado a una **instancia principal (maestro)** o a una **réplica (secundaria)** en SQL Server, puedes ejecutar la siguiente consulta:

```sql
SELECT
    CONNECTIONPROPERTY('client_net_address') AS ClientIP,
    CONNECTIONPROPERTY('local_net_address') AS ServerIP,
    DATABASEPROPERTYEX(DB_NAME(), 'Updateability') AS Updateability,
    DATABASEPROPERTYEX(DB_NAME(), 'IsSubscribed') AS IsSubscribed,
    DATABASEPROPERTYEX(DB_NAME(), 'IsMergePublished') AS IsMergePublished,
    DATABASEPROPERTYEX(DB_NAME(), 'IsPublished') AS IsPublished,
    sys.fn_hadr_is_primary_replica(DB_NAME()) AS IsPrimaryReplica;
```

### ¿Qué significa cada columna?

- **Updateability**: Si el valor es `READ_WRITE`, estás en una base principal. Si es `READ_ONLY`, podría ser una réplica.
- **IsPrimaryReplica**: Si el valor es `1`, estás en la réplica principal de un grupo de disponibilidad Always On.
- **IsPublished / IsMergePublished / IsSubscribed**: Indican si la base está involucrada en replicación transaccional, de mezcla o como suscriptor.

### Alternativa para grupos de disponibilidad Always On

Si estás usando Always On, puedes ejecutar:

```sql
SELECT 
    ar.replica_server_name,
    ars.role_desc
FROM 
    sys.availability_replicas ar
JOIN 
    sys.dm_hadr_availability_replica_states ars 
    ON ar.replica_id = ars.replica_id
WHERE 
    ars.is_local = 1;
```

Esto te dirá si el servidor local tiene el rol de `PRIMARY` o `SECONDARY`.
