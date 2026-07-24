SET NOCOUNT ON;

-- 0. Limpieza previa de tablas temporales
IF OBJECT_ID('tempdb..#UsuariosABuscar') IS NOT NULL DROP TABLE #UsuariosABuscar;
IF OBJECT_ID('tempdb..#ReporteModulos') IS NOT NULL DROP TABLE #ReporteModulos;

-- ============================================================================
-- 1. CONFIGURACIÓN: Ingresa aquí los usuarios/textos a buscar
-- ============================================================================
CREATE TABLE #UsuariosABuscar (
    Patron NVARCHAR(100)
);

INSERT INTO #UsuariosABuscar (Patron) 
VALUES 
    (N'jose'),
    (N'user_test'),
    (N'maria'); -- Agrega aquí todos los usuarios que necesites


-- ============================================================================
-- 2. TABLA TEMPORAL DE REPORTE (Se añade la columna Definicion)
-- ============================================================================
CREATE TABLE #ReporteModulos (
    BaseDeDatos         SYSNAME,
    Esquema             SYSNAME,
    NombreObjeto        SYSNAME,
    TipoObjeto          NVARCHAR(60),
    UsuariosEncontrados NVARCHAR(MAX),
    Definicion          NVARCHAR(MAX), -- <--- Nueva columna para el código fuente
    FechaCreacion       DATETIME,
    FechaModifica       DATETIME
);

-- ============================================================================
-- 3. CONSTRUCCIÓN DE LA CONDICIÓN LIKE COMBINADA
-- ============================================================================
DECLARE @WhereClause NVARCHAR(MAX) = N'';

SELECT @WhereClause = STRING_AGG(
    CAST(N'm.definition LIKE ''%' + REPLACE(Patron, '''', '''''') + N'%''' AS NVARCHAR(MAX)), 
    N' OR '
)
FROM #UsuariosABuscar;

IF @WhereClause IS NULL OR @WhereClause = N''
BEGIN
    PRINT 'Debes ingresar al menos un usuario en la tabla #UsuariosABuscar.';
    RETURN;
END

-- ============================================================================
-- 4. RECORRIDO POR CADA BASE DE DATOS (1 sola pasada por BD)
-- ============================================================================
DECLARE @DBName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

DECLARE cur_db CURSOR LOCAL FAST_FORWARD FOR
SELECT name 
FROM sys.databases 
WHERE state_desc = 'ONLINE' 
  AND HAS_DBACCESS(name) = 1;

OPEN cur_db;
FETCH NEXT FROM cur_db INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
    INSERT INTO #ReporteModulos (BaseDeDatos, Esquema, NombreObjeto, TipoObjeto, UsuariosEncontrados, Definicion, FechaCreacion, FechaModifica)
    SELECT 
        ' + QUOTENAME(@DBName, '''') + N' AS BaseDeDatos,
        s.name AS Esquema,
        o.name AS NombreObjeto,
        o.type_desc AS TipoObjeto,
        u_match.ListaUsuarios AS UsuariosEncontrados,
        m.definition AS Definicion,
        o.create_date,
        o.modify_date
    FROM ' + QUOTENAME(@DBName) + N'.sys.sql_modules m
    INNER JOIN ' + QUOTENAME(@DBName) + N'.sys.objects o ON m.object_id = o.object_id
    INNER JOIN ' + QUOTENAME(@DBName) + N'.sys.schemas s ON o.schema_id = s.schema_id
    CROSS APPLY (
        SELECT STRING_AGG(u.Patron, '', '') AS ListaUsuarios
        FROM #UsuariosABuscar u
        WHERE m.definition LIKE ''%'' + u.Patron + ''%''
    ) u_match
    WHERE (' + @WhereClause + N')
      AND o.type IN (''P'', ''PC'', ''FN'', ''IF'', ''TF'', ''AF'');';

    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        -- Ignora bases de datos donde no haya permisos o acceso
    END CATCH

    FETCH NEXT FROM cur_db INTO @DBName;
END

CLOSE cur_db;
DEALLOCATE cur_db;

-- ============================================================================
-- 5. REPORTE FINAL CONSOLIDADOS CON CÓDIGO FUENTE COMPLETO
-- ============================================================================
IF EXISTS (SELECT 1 FROM #ReporteModulos)
BEGIN
    EXEC sp_executesql N'
        SELECT 
            BaseDeDatos,
            Esquema,
            NombreObjeto,
            TipoObjeto,
            UsuariosEncontrados,
            Definicion,
            FechaCreacion,
            FechaModifica
        FROM #ReporteModulos
        ORDER BY BaseDeDatos, TipoObjeto, NombreObjeto;
    ';
END
ELSE
BEGIN
    PRINT 'NO SE ENCONTRÓ NINGUNO DE LOS USUARIOS EN NINGUNA BASE DE DATOS.';
END



/**


use model
CREATE OR ALTER PROCEDURE dbo.usp_PruebaProcesoUsuario
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Se incluye explícitamente el usuario en una variable/consulta de prueba
    DECLARE @UsuarioConsulta NVARCHAR(50) = 'user_test';
    
    PRINT 'Ejecutando proceso para el usuario registrado: ' + @UsuarioConsulta;
    
    -- Simulación de una consulta usando el usuario
    SELECT 
        @UsuarioConsulta AS UsuarioAsignado,
        GETDATE() AS FechaEjecucion,
        'Acceso Validado' AS Estado;
END;
GO


use tempdb
CREATE OR ALTER FUNCTION dbo.ufn_ObtenerPerfilUsuario()
RETURNS NVARCHAR(100)
AS
BEGIN
    -- El nombre del usuario está explícito en la definición de la función
    DECLARE @NombreUsuario NVARCHAR(50) = 'user_test';
    DECLARE @PerfilRetorno NVARCHAR(100);

    IF @NombreUsuario = 'user_test'
    BEGIN
        SET @PerfilRetorno = 'Perfil de Pruebas - DBA';
    END
    ELSE
    BEGIN
        SET @PerfilRetorno = 'Perfil Estándar';
    END

    RETURN @PerfilRetorno;
END;
GO


 
SELECT o.name, o.type_desc 
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE m.definition LIKE '%jose%' or m.definition LIKE '%user_test%' or  m.definition LIKE '%maria%';





*/
