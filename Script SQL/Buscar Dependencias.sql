SET NOCOUNT ON;

-- 1. Definir el usuario / patrón a buscar
DECLARE @SearchText NVARCHAR(100) = N'use_test'; 

-- 2. Tabla temporal para el reporte consolidado
IF OBJECT_ID('tempdb..#ReporteModulos') IS NOT NULL 
    DROP TABLE #ReporteModulos;

CREATE TABLE #ReporteModulos (
    BaseDeDatos     SYSNAME,
    Esquema         SYSNAME,
    NombreObjeto    SYSNAME,
    TipoObjeto      NVARCHAR(60),
    FechaCreacion   DATETIME,
    FechaModifica   DATETIME
);

DECLARE @DBName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

-- 3. Cursor para iterar sobre todas las bases de datos de la instancia
DECLARE cur_db CURSOR LOCAL FAST_FORWARD FOR
SELECT name 
FROM sys.databases 
WHERE state_desc = 'ONLINE' 
  AND HAS_DBACCESS(name) = 1;

OPEN cur_db;
FETCH NEXT FROM cur_db INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Se consulta directamente sys.sql_modules (contiene la definición T-SQL completa)
    SET @SQL = N'
    USE ' + QUOTENAME(@DBName) + N';

    INSERT INTO #ReporteModulos (BaseDeDatos, Esquema, NombreObjeto, TipoObjeto, FechaCreacion, FechaModifica)
    SELECT 
        DB_NAME() AS BaseDeDatos,
        s.name AS Esquema,
        o.name AS NombreObjeto,
        o.type_desc AS TipoObjeto,
        o.create_date,
        o.modify_date
    FROM sys.sql_modules m
    INNER JOIN sys.objects o ON m.object_id = o.object_id
    INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE m.definition COLLATE Latin1_General_CI_AS LIKE ''%' + REPLACE(@SearchText, '''', '''''') + '%''
      AND o.type IN (''P'', ''PC'', ''FN'', ''IF'', ''TF'', ''AF'');';

    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        -- Si ocurre un fallo en alguna BD, continua con las demás sin detenerse
    END CATCH

    FETCH NEXT FROM cur_db INTO @DBName;
END

CLOSE cur_db;
DEALLOCATE cur_db;

-- 4. Generación del reporte final
IF EXISTS (SELECT 1 FROM #ReporteModulos)
BEGIN
    SELECT 
        BaseDeDatos,
        Esquema,
        NombreObjeto,
        TipoObjeto,
        FechaCreacion,
        FechaModifica
    FROM #ReporteModulos
    ORDER BY BaseDeDatos, TipoObjeto, NombreObjeto;
END
ELSE
BEGIN
    PRINT 'NO SE ENCONTRÓ EL USUARIO/TEXTO "' + @SearchText + '" EN NINGÚN PROCEDIMIENTO O FUNCIÓN DE LAS BASES DE DATOS.';
END
