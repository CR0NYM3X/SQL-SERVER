SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    s.name AS StatisticName,
    STATS_DATE(s.object_id, s.stats_id) AS LastUpdated,
    rows AS RowsInTable,
    rows_sampled AS SampledRows,
    modification_counter AS ModificationCounter,
    (modification_counter * 100.0 / NULLIF(rows_sampled, 0)) AS PercentChanged
FROM 
    sys.stats s
JOIN 
    sys.tables t ON s.object_id = t.object_id
CROSS APPLY 
    sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE 
    sp.modification_counter > 0
    AND STATS_DATE(s.object_id, s.stats_id) IS NOT NULL
    AND (modification_counter * 100.0 / NULLIF(rows_sampled, 0)) > 20  -- Puedes ajustar este umbral
ORDER BY 
    PercentChanged DESC;
