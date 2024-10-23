SELECT 
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(object_id) AS TableName,
    SUM(user_seeks + user_scans + user_lookups) AS TotalAccesses
FROM 
    sys.dm_db_index_usage_stats
WHERE 
    database_id > 4
    AND OBJECTPROPERTY(object_id, 'IsUserTable') = 1
GROUP BY 
    database_id, object_id
ORDER BY 
    SUM(user_seeks + user_scans + user_lookups) DESC;