

```sql

--- Ver top DB ocupan mas espacio
SELECT 'Top 10 por Espacio'
SELECT TOP 10
    CONNECTIONPROPERTY('local_net_address') AS IPServidor,
    DB_NAME(database_id) AS DatabaseName,
    CAST(SUM(size) AS BIGINT) * 8 / 1024 / 1024 AS SizeGB
FROM sys.master_files
GROUP BY database_id
ORDER BY CAST(SUM(size) AS BIGINT) DESC;


--- Ver distribucion de discos
select  SUBSTRING(physical_name, 1, 1) AS [Letra_Unidad]
    ,DB_NAME(database_id),type_desc,name,physical_name from sys.master_files where order by database_id


--- ver cuantaos mdf o ldf existen en cada disco 
SELECT
    -- 1. Extrae la letra de la unidad
    SUBSTRING(mf.physical_name, 1, 1) AS [Letra_Unidad],
    
    -- 2. Cuenta cuántas bases de datos distintas existen en esta unidad
    COUNT(DISTINCT DB_NAME(mf.database_id)) AS [Bases_Datos_Distintas],
    
    -- 3. Indica si existe al menos un archivo de datos (.mdf)
    MAX(CASE WHEN mf.type_desc = 'ROWS' THEN 'SI' ELSE 'NO' END) AS [Contiene_Archivos_MDF],
    
    -- 4. Indica si existe al menos un archivo de registro (.ldf)
    MAX(CASE WHEN mf.type_desc = 'LOG' THEN 'SI' ELSE 'NO' END) AS [Contiene_Archivos_LDF],
    
    -- 5. AGREGACIÓN DE CADENAS (Reemplaza STRING_AGG para compatibilidad)
    STUFF((
        SELECT 
            ', ' + QUOTENAME(DB_NAME(t2.database_id))
        FROM 
            sys.master_files t2
        WHERE 
            -- Compara la unidad de esta subconsulta con la unidad de la consulta principal
            SUBSTRING(t2.physical_name, 1, 1) = SUBSTRING(mf.physical_name, 1, 1)
        
        GROUP BY 
            DB_NAME(t2.database_id)
        
        ORDER BY 
            DB_NAME(t2.database_id)
        
        -- Método de concatenación antiguo
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [Nombres_DBs]

FROM 
    sys.master_files mf
    
-- Excluye unidades del archivo de recursos (Resource Database)
WHERE 
    mf.database_id > 4 
    OR DB_NAME(mf.database_id) IN ('master', 'msdb', 'model', 'tempdb')

GROUP BY 
    SUBSTRING(mf.physical_name, 1, 1)

ORDER BY 
    [Letra_Unidad];

```
