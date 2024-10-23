SELECT 
    name AS [Configuración],
    CONVERT(DECIMAL(10, 2), CONVERT(INT, value) / (1024.0)) AS [Valor_GB],
    CONVERT(DECIMAL(10, 2), CONVERT(INT, value_in_use) / (1024.0)) AS [Valor_Estático_GB]
FROM 
    sys.configurations
WHERE 
    name IN ('min server memory (MB)', 'max server memory (MB)');

