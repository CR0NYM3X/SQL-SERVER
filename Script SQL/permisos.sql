
 
--------------------------------------------------------------------------------------------------
-- DBA AUDIT SCANNER: MAPA GLOBAL DE PERMISOS DE USUARIOS/LOGINS
-- Inspirado en arquitectura multi-database.
--------------------------------------------------------------------------------------------------

SET NOCOUNT ON;

--------------------------------------------------------------------------------------------------
-- 1. ZONA DE CARGA DE OBJETIVOS
--------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TargetList') IS NOT NULL DROP TABLE #TargetList;
CREATE TABLE #TargetList (TargetName NVARCHAR(128));

-- Ingresa aquí los usuarios/logins que deseas auditar
INSERT INTO #TargetList (TargetName)
VALUES  
    ('usuariotest'); 

-- Limpieza básica de la entrada
UPDATE #TargetList SET TargetName = LTRIM(RTRIM(TargetName));

--------------------------------------------------------------------------------------------------
-- 2. PREPARACIÓN DE MAPAS DE MEMORIA PARA EL REPORTE
--------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#ReportePermisos') IS NOT NULL DROP TABLE #ReportePermisos;
CREATE TABLE #ReportePermisos (
    BaseDeDatos NVARCHAR(128) COLLATE DATABASE_DEFAULT,
    NombreUsuario NVARCHAR(128) COLLATE DATABASE_DEFAULT,
    Nivel NVARCHAR(50) COLLATE DATABASE_DEFAULT,      
    Categoria NVARCHAR(50) COLLATE DATABASE_DEFAULT,  
    Permiso_O_Rol NVARCHAR(128) COLLATE DATABASE_DEFAULT,
    TipoObjeto NVARCHAR(60) COLLATE DATABASE_DEFAULT,
    NombreObjeto NVARCHAR(500) COLLATE DATABASE_DEFAULT,
    EstadoPermiso NVARCHAR(60) COLLATE DATABASE_DEFAULT
);

DECLARE @Msg NVARCHAR(2000);
DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @CurrentDB NVARCHAR(128);

SET @Msg = CHAR(13) + CHAR(10) + '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '>>> INICIANDO ESCÁNER DE PERMISOS GLOBAL <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

--------------------------------------------------------------------------------------------------
-- 3. FASE 1: AUDITORÍA A NIVEL SERVIDOR (MASTER)
--------------------------------------------------------------------------------------------------
SET @Msg = '[+] Extrayendo permisos a nivel de Instancia (Servidor)...'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

-- 3.1 Roles de Servidor
INSERT INTO #ReportePermisos
SELECT 
    'MASTER (Nivel Servidor)', sp.name, 'SERVIDOR', 'Membresía de Rol', srp.name, 'SERVER ROLE', @@SERVERNAME, 'GRANTED'
FROM sys.server_role_members AS srm
JOIN sys.server_principals AS sp ON srm.member_principal_id = sp.principal_id
JOIN sys.server_principals AS srp ON srm.role_principal_id = srp.principal_id
JOIN #TargetList t ON sp.name COLLATE DATABASE_DEFAULT = t.TargetName COLLATE DATABASE_DEFAULT;

-- 3.2 Permisos Explícitos de Servidor
INSERT INTO #ReportePermisos
SELECT 
    'MASTER (Nivel Servidor)', sp.name, 'SERVIDOR', 'Permiso Explícito', pe.permission_name, 'SERVER', @@SERVERNAME, pe.state_desc
FROM sys.server_permissions AS pe
JOIN sys.server_principals AS sp ON pe.grantee_principal_id = sp.principal_id
JOIN #TargetList t ON sp.name COLLATE DATABASE_DEFAULT = t.TargetName COLLATE DATABASE_DEFAULT;

--------------------------------------------------------------------------------------------------
-- 4. FASE 2: RADAR DE BASES DE DATOS (RECORRIDO DINÁMICO)
--------------------------------------------------------------------------------------------------
DECLARE RadarCursor CURSOR LOCAL FAST_FORWARD FOR 
SELECT name FROM sys.databases WHERE state_desc = 'ONLINE' AND database_id > 0; -- Se puede excluir las de sistema filtrando id > 4 si lo deseas

OPEN RadarCursor; 
FETCH NEXT FROM RadarCursor INTO @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Msg = '    -> Escaneando Base de Datos: [' + @CurrentDB + ']...'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    
    SET @DynamicSQL = N'USE [' + @CurrentDB + N'];
    
    -- 4.1 Roles de Base de Datos
    INSERT INTO #ReportePermisos
    SELECT 
        DB_NAME(), dp.name, ''BASE DE DATOS'', ''Membresía de Rol'', rp.name, ''DATABASE ROLE'', DB_NAME(), ''GRANTED''
    FROM sys.database_role_members AS drm
    JOIN sys.database_principals AS dp ON drm.member_principal_id = dp.principal_id
    JOIN sys.database_principals AS rp ON drm.role_principal_id = rp.principal_id
    JOIN #TargetList t ON dp.name COLLATE DATABASE_DEFAULT = t.TargetName COLLATE DATABASE_DEFAULT;

    -- 4.2 Permisos Explícitos de Base de Datos (Objetos, Esquemas, etc)
    INSERT INTO #ReportePermisos
    SELECT 
        DB_NAME(), pr.name, ''BASE DE DATOS'', ''Permiso Explícito'', pe.permission_name, 
        CASE pe.class 
            WHEN 0 THEN ''DATABASE''
            WHEN 1 THEN ''OBJECT''
            WHEN 3 THEN ''SCHEMA''
            ELSE ''OTRO ('' + CAST(pe.class AS VARCHAR) + '')'' 
        END,
        CASE pe.class 
            WHEN 0 THEN DB_NAME()
            WHEN 1 THEN ISNULL(OBJECT_SCHEMA_NAME(pe.major_id), '''') + ''.'' + ISNULL(OBJECT_NAME(pe.major_id), ''Objeto Borrado/Desconocido'')
            WHEN 3 THEN SCHEMA_NAME(pe.major_id)
            ELSE ''N/A'' 
        END,
        pe.state_desc
    FROM sys.database_permissions AS pe
    JOIN sys.database_principals AS pr ON pe.grantee_principal_id = pr.principal_id
    JOIN #TargetList t ON pr.name COLLATE DATABASE_DEFAULT = t.TargetName COLLATE DATABASE_DEFAULT;
    ';
    
    BEGIN TRY
        EXEC sp_executesql @DynamicSQL;
    END TRY
    BEGIN CATCH
        SET @Msg = '       (X) [ALERTA] Error al escanear [' + @CurrentDB + '] - Motivo: ' + ERROR_MESSAGE(); 
        RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    END CATCH

    FETCH NEXT FROM RadarCursor INTO @CurrentDB;
END
CLOSE RadarCursor; DEALLOCATE RadarCursor;

--------------------------------------------------------------------------------------------------
-- 5. REPORTE FINAL CONSOLIDADO
--------------------------------------------------------------------------------------------------
SET @Msg = CHAR(13) + CHAR(10) + '>>> ESCANEO COMPLETADO. GENERANDO REPORTE FINAL... <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

SELECT * 
FROM #ReportePermisos
ORDER BY Nivel DESC, BaseDeDatos, NombreUsuario, Categoria;


