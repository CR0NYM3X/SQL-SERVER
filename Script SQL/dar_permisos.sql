SET NOCOUNT ON;

-- 1. DEFINE AQUÍ TU LOGIN DE DOMINIO O USUARIO
DECLARE @usuario SYSNAME = N'DOMINIO\user_test';

DECLARE @dbName SYSNAME;
DECLARE @sql NVARCHAR(MAX);
DECLARE @cmdLogin NVARCHAR(MAX);

--------------------------------------------------------------------------------
-- PASO A: VALIDAR Y CREAR EL LOGIN A NIVEL SERVIDOR SI NO EXISTE
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @usuario)
BEGIN
    BEGIN TRY
        SET @cmdLogin = N'CREATE LOGIN ' + QUOTENAME(@usuario) + N' FROM WINDOWS WITH DEFAULT_DATABASE=[master];';
        EXEC (@cmdLogin);
        PRINT '[ LOGIN CREADO ] -> Servidor: Login de Windows ' + QUOTENAME(@usuario) + ' creado exitosamente en el servidor.';
    END TRY
    BEGIN CATCH
        PRINT '[ ERROR LOGIN ]  -> Servidor: No se pudo crear el Login ' + QUOTENAME(@usuario) + '. Detalle: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT '[ LOGIN EXISTE ] -> Servidor: El Login ' + QUOTENAME(@usuario) + ' ya existe a nivel servidor.';
END

PRINT '--------------------------------------------------------------------------------';

--------------------------------------------------------------------------------
-- PASO B: ITERAR EN BASES DE DATOS PARA CREAR USUARIO Y OTORGAR PERMISO
--------------------------------------------------------------------------------
DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT name 
FROM sys.databases 
WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb') 
  AND state_desc = 'ONLINE'
  AND HAS_PERMS_BY_NAME(name, 'DATABASE', 'CONNECT') = 1;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
    USE ' + QUOTENAME(@dbName) + N';

    BEGIN TRY
        -- 1. Validar que el Login exista (por si falló en el Paso A)
        IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @p_user)
        BEGIN
            PRINT ''[ OMITIDO ] -> ['' + DB_NAME() + '']: No existe el Login a nivel servidor.'';
        END
        ELSE
        BEGIN
            -- 2. Si el USUARIO no existe en la BD actual, LO CREAMOS
            IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @p_user)
            BEGIN
                DECLARE @cmdCreate NVARCHAR(MAX) = N''CREATE USER '' + QUOTENAME(@p_user) + N'' FOR LOGIN '' + QUOTENAME(@p_user) + N'';'';
                EXEC (@cmdCreate);
                PRINT ''[ CREADO ]  -> ['' + DB_NAME() + '']: Usuario creado exitosamente.'';
            END

            -- 3. Validar si ya tiene el permiso SELECT a nivel de BD
            IF EXISTS (
                SELECT 1 
                FROM sys.database_permissions dp
                JOIN sys.database_principals dp2 ON dp.grantee_principal_id = dp2.principal_id
                WHERE dp2.name = @p_user 
                  AND dp.permission_name = ''SELECT'' 
                  AND dp.state_desc = ''GRANT''
                  AND dp.class_desc = ''DATABASE''
            )
            BEGIN
                PRINT ''[ EXISTE ]  -> ['' + DB_NAME() + '']: El permiso SELECT YA EXISTÍA previamente.'';
            END
            ELSE
            BEGIN
                -- 4. Otorgar el permiso SELECT
                DECLARE @cmdGrant NVARCHAR(MAX) = N''GRANT SELECT TO '' + QUOTENAME(@p_user) + N'';'';
                EXEC (@cmdGrant);
                PRINT ''[ ÉXITO ]   -> ['' + DB_NAME() + '']: Permiso SELECT otorgado correctamente.'';
            END
        END
    END TRY
    BEGIN CATCH
        PRINT ''[ ERROR ]   -> ['' + DB_NAME() + '']: '' + ERROR_MESSAGE();
    END CATCH;
    ';

    -- Ejecutamos pasando la variable de forma segura
    EXEC sp_executesql @sql, N'@p_user SYSNAME', @p_user = @usuario;

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
