--No PKs
SELECT 
  SCHEMA_NAME(schema_id) AS [Schema], 
  name AS [Table]
FROM sys.tables
WHERE OBJECTPROPERTY(object_id, 'TableHasPrimaryKey') = 0
ORDER BY [Schema], [Table];
