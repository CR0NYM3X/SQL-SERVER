


--------------------------------------------------------------------------------------------------
-- DBA SQUAD VANGUARD BLACK-OPS: SQL SERVER LOGIN & USER ANNIHILATOR (v10.7 FINAL)
-- Mejora v10.7: AutoClean Seguro (Homónimo). SOLO transfiere esquemas que se llamen IGUAL que el usuario.
-- Mejora v10.6: Módulo Auto-Clean controlado por Panel de Mando.
-- Mejora v10.5: Corrección estricta DDL en DROP USER.
-- Mejora v10.2: Punto y coma defensivo (;WITH). 
-- Mejora v10.0: Entrada Determinística (ANSI SQL VALUES).
--------------------------------------------------------------------------------------------------

SET NOCOUNT ON;

--------------------------------------------------------------------------------------------------
-- 1. ZONA DE CARGA E INTERRUPTORES TÁCTICOS DE SEGURIDAD (PANEL DE MANDO)
--------------------------------------------------------------------------------------------------
-- [ 1 = ACTIVO / ENCENDIDO ]  ---  [ 0 = APAGADO / IGNORAR ]
DECLARE @CheckSchemas         BIT = 0; -- Apagado: No frena el borrado si es dueño de un Esquema
DECLARE @CheckRoles           BIT = 0; -- Apagado: No frena el borrado si es dueño de un Rol
DECLARE @AutoTransferSchemas  BIT = 1; -- ENCENDIDO: Transfiere esquemas a [dbo] SOLO SI se llaman igual que el usuario
DECLARE @CheckCodeModules     BIT = 1; -- ENCENDIDO: Busca Hardcoding dentro de Funciones, SPs y Vistas

IF OBJECT_ID('tempdb..#TargetList') IS NOT NULL DROP TABLE #TargetList;
CREATE TABLE #TargetList (TargetName NVARCHAR(128));

INSERT INTO #TargetList (TargetName)
VALUES 
    ('DOMINIO:COM\jua.perez'),
    ('jose'), -- Ejemplo para esquema homónimo
    ('sysnew'); -- <-- [Ingresa tus objetivos aquí]

--------------------------------------------------------------------------------------------------
-- 1.5. MOTOR DE AUTO-DEDUPLICACIÓN Y SANITIZACIÓN 
--------------------------------------------------------------------------------------------------
;WITH CTE_Duplicates AS (
    SELECT TargetName, ROW_NUMBER() OVER(PARTITION BY TargetName ORDER BY TargetName) as row_num
    FROM #TargetList
)
DELETE FROM CTE_Duplicates WHERE row_num > 1;

UPDATE #TargetList SET TargetName = LTRIM(RTRIM(TargetName));

DELETE FROM #TargetList 
WHERE TargetName IN ('sa', 'dbo', 'guest', 'INFORMATION_SCHEMA', 'sys') 
   OR TargetName LIKE 'NT SERVICE\%' 
   OR TargetName LIKE 'NT AUTHORITY\%';

--------------------------------------------------------------------------------------------------
-- 2. PREPARACIÓN DE MAPAS DE MEMORIA
--------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#FoundUsers') IS NOT NULL DROP TABLE #FoundUsers;
IF OBJECT_ID('tempdb..#FoundLogins') IS NOT NULL DROP TABLE #FoundLogins;
IF OBJECT_ID('tempdb..#SkippedLogins') IS NOT NULL DROP TABLE #SkippedLogins;

CREATE TABLE #FoundUsers (DBName NVARCHAR(128), UserName NVARCHAR(128));
CREATE TABLE #FoundLogins (LoginName NVARCHAR(128));
CREATE TABLE #SkippedLogins (LoginName NVARCHAR(128) COLLATE DATABASE_DEFAULT, Reason NVARCHAR(MAX) COLLATE DATABASE_DEFAULT);

DECLARE @Msg NVARCHAR(2000);
DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @CurrentDB NVARCHAR(128);
DECLARE @CurrentTarget NVARCHAR(128);

--------------------------------------------------------------------------------------------------
-- 3. FASE DE RADAR: MAPEO Y ESCANEO DE HARDCODING GLOBAL CON COORDENADAS EXACTAS
--------------------------------------------------------------------------------------------------
SET @Msg = CHAR(13) + CHAR(10) + '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '>>> FASE 1: RADAR GLOBAL DE ENTIDADES Y AUDITORÍA DE CÓDIGO <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

INSERT INTO #FoundLogins (LoginName)
SELECT name FROM sys.server_principals sp 
INNER JOIN #TargetList t ON sp.name COLLATE DATABASE_DEFAULT = t.TargetName COLLATE DATABASE_DEFAULT;

DECLARE RadarCursor CURSOR LOCAL FAST_FORWARD FOR SELECT name FROM sys.databases WHERE state_desc = 'ONLINE';
OPEN RadarCursor; FETCH NEXT FROM RadarCursor INTO @CurrentDB;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DynamicSQL = N'USE [' + @CurrentDB + N'];
    
    INSERT INTO #FoundUsers (DBName, UserName)
    SELECT DB_NAME(), dp.name FROM sys.database_principals dp 
    INNER JOIN #TargetList t ON dp.name COLLATE DATABASE_DEFAULT = t.TargetName COLLATE DATABASE_DEFAULT;
    
    IF (@ChkCode = 1)
    BEGIN
        INSERT INTO #SkippedLogins (LoginName, Reason)
        SELECT DISTINCT t.TargetName, 
               ''BD ['' + DB_NAME() + ''] -> Objeto: ['' + o.type_desc COLLATE DATABASE_DEFAULT + ''] Nombre: ['' + SCHEMA_NAME(o.schema_id) COLLATE DATABASE_DEFAULT + ''].['' + o.name COLLATE DATABASE_DEFAULT + '']''
        FROM sys.sql_modules sm
        INNER JOIN sys.objects o ON sm.object_id = o.object_id
        CROSS JOIN #TargetList t
        WHERE sm.definition COLLATE DATABASE_DEFAULT LIKE N''%'' + t.TargetName COLLATE DATABASE_DEFAULT + N''%'';
    END
    ';
    EXEC sp_executesql @DynamicSQL, N'@ChkCode BIT', @ChkCode = @CheckCodeModules;
    
    FETCH NEXT FROM RadarCursor INTO @CurrentDB;
END
CLOSE RadarCursor; DEALLOCATE RadarCursor;

--------------------------------------------------------------------------------------------------
-- 4A. REPORTE CATEGORIZADO: OBJETIVOS CONFIRMADOS
--------------------------------------------------------------------------------------------------
SET @Msg = CHAR(13) + CHAR(10) + '-------------------------------------------------------------------'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '[+] REPORTE DE OBJETIVOS CONFIRMADOS (Listos para inspección)'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '-------------------------------------------------------------------'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

DECLARE @FoundCount INT = 0;
DECLARE FoundCursor CURSOR LOCAL FAST_FORWARD FOR 
SELECT DISTINCT TargetName FROM #TargetList 
WHERE TargetName IN (SELECT LoginName COLLATE DATABASE_DEFAULT FROM #FoundLogins) 
   OR TargetName IN (SELECT UserName COLLATE DATABASE_DEFAULT FROM #FoundUsers);

OPEN FoundCursor; FETCH NEXT FROM FoundCursor INTO @CurrentTarget;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Msg = '   -> [CONFIRMADO] [' + @CurrentTarget + '] existe en el sistema.'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    SET @FoundCount = @FoundCount + 1;
    FETCH NEXT FROM FoundCursor INTO @CurrentTarget;
END
CLOSE FoundCursor; DEALLOCATE FoundCursor;

--------------------------------------------------------------------------------------------------
-- 4B. REPORTE CATEGORIZADO: FANTASMAS (NO EXISTEN)
--------------------------------------------------------------------------------------------------
SET @Msg = CHAR(13) + CHAR(10) + '-------------------------------------------------------------------'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '[-] REPORTE DE FANTASMAS (Objetivos no encontrados)'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '-------------------------------------------------------------------'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

DECLARE @GhostCount INT = 0;
DECLARE GhostCursor CURSOR LOCAL FAST_FORWARD FOR 
SELECT TargetName FROM #TargetList 
WHERE TargetName NOT IN (SELECT LoginName COLLATE DATABASE_DEFAULT FROM #FoundLogins) 
  AND TargetName NOT IN (SELECT UserName COLLATE DATABASE_DEFAULT FROM #FoundUsers);

OPEN GhostCursor; FETCH NEXT FROM GhostCursor INTO @CurrentTarget;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Msg = '   -> [DESCARTADO] [' + @CurrentTarget + '] no existe. Omitiendo.'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    SET @GhostCount = @GhostCount + 1;
    FETCH NEXT FROM GhostCursor INTO @CurrentTarget;
END
CLOSE GhostCursor; DEALLOCATE GhostCursor;

--------------------------------------------------------------------------------------------------
-- 5. FASE DE ANIQUILACIÓN: BASES DE DATOS (CON AUTO-CLEAN SEGURO / HOMÓNIMO)
--------------------------------------------------------------------------------------------------
IF @FoundCount > 0
BEGIN
    SET @Msg = CHAR(13) + CHAR(10) + '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    SET @Msg = '>>> FASE 2: PURGA DE USUARIOS Y AUDITORÍA RELACIONAL <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    SET @Msg = '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

    DECLARE DBExecCursor CURSOR LOCAL FAST_FORWARD FOR SELECT DISTINCT DBName FROM #FoundUsers ORDER BY DBName;
    OPEN DBExecCursor; FETCH NEXT FROM DBExecCursor INTO @CurrentDB;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Msg = CHAR(13) + CHAR(10) + ' [ ENTRANDO A BASE DE DATOS: ' + @CurrentDB + ' ]'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

        DECLARE UserExecCursor CURSOR LOCAL FAST_FORWARD FOR SELECT UserName FROM #FoundUsers WHERE DBName = @CurrentDB;
        OPEN UserExecCursor; FETCH NEXT FROM UserExecCursor INTO @CurrentTarget;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS (SELECT 1 FROM #SkippedLogins WHERE LoginName COLLATE DATABASE_DEFAULT = @CurrentTarget COLLATE DATABASE_DEFAULT)
            BEGIN
                DECLARE @CodeReason NVARCHAR(500) = (SELECT TOP 1 Reason FROM #SkippedLogins WHERE LoginName COLLATE DATABASE_DEFAULT = @CurrentTarget COLLATE DATABASE_DEFAULT);
                DECLARE @LogMsg1 NVARCHAR(2000) = '      (-) [BLINDADO PREVIAMENTE] [' + @CurrentTarget + '] Motivo: ' + @CodeReason;
                RAISERROR (@LogMsg1, 10, 1) WITH NOWAIT;
            END
            ELSE
            BEGIN
                -- Inyectar las variables de control al script dinámico
                SET @DynamicSQL = N'USE [' + @CurrentDB + N'];
                DECLARE @PrinID INT = DATABASE_PRINCIPAL_ID(@TargetParam);
                DECLARE @DepMsg NVARCHAR(500) = '''';

                -- >>>> MÓDULO AUTO-CLEANSE (SOLO ESQUEMAS HOMÓNIMOS) <<<<
                IF (@AutoTx = 1 AND EXISTS (SELECT 1 FROM sys.schemas WHERE principal_id = @PrinID AND name COLLATE DATABASE_DEFAULT = @TargetParam COLLATE DATABASE_DEFAULT))
                BEGIN
                    DECLARE @SchName NVARCHAR(128);
                    DECLARE @AlterSQL NVARCHAR(MAX);
                    
                    -- Seleccionamos estrictamente esquemas que se llamen IGUAL que el usuario
                    DECLARE SchCursor CURSOR LOCAL FAST_FORWARD FOR 
                    SELECT name FROM sys.schemas WHERE principal_id = @PrinID AND name COLLATE DATABASE_DEFAULT = @TargetParam COLLATE DATABASE_DEFAULT;
                    
                    OPEN SchCursor; FETCH NEXT FROM SchCursor INTO @SchName;
                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        SET @AlterSQL = N''ALTER AUTHORIZATION ON SCHEMA::['' + @SchName + N''] TO [dbo];'';
                        EXEC sp_executesql @AlterSQL;
                        
                        DECLARE @TxMsg NVARCHAR(2000) = ''      (>) [AUTOCLEAN SEGURO] Esquema homónimo ['' + @SchName + ''] transferido a [dbo].'';
                        RAISERROR (@TxMsg, 10, 1) WITH NOWAIT;
                        
                        FETCH NEXT FROM SchCursor INTO @SchName;
                    END
                    CLOSE SchCursor; DEALLOCATE SchCursor;
                END

                -- Validaciones relacionales (Atrapará cualquier otro esquema NO homónimo o Roles si los interruptores están en 1)
                IF (@ChkSchemas = 1 AND EXISTS (SELECT 1 FROM sys.schemas WHERE principal_id = @PrinID))
                    SET @DepMsg = @DepMsg + ''[Dueño de Esquema] '';
                
                IF (@ChkRoles = 1 AND EXISTS (SELECT 1 FROM sys.database_principals WHERE owning_principal_id = @PrinID))
                    SET @DepMsg = @DepMsg + ''[Dueño de Rol] '';

                IF LEN(@DepMsg) > 0
                BEGIN
                    INSERT INTO #SkippedLogins (LoginName, Reason) VALUES (@TargetParam, ''BD ['' + DB_NAME() + ''] -> Dependencia: '' + @DepMsg);
                    DECLARE @LogMsg2 NVARCHAR(2000) = ''      (-) [BLINDADO] ['' + @TargetParam + ''] Riesgo: '' + @DepMsg;
                    RAISERROR (@LogMsg2, 10, 1) WITH NOWAIT;
                END
                ELSE
                BEGIN
                    BEGIN TRY
                        -- [CORRECCIÓN V10.5 DDL ESTRICTA]: DROP USER no soporta variables internas, se concatena desde afuera.
                        DROP USER [' + @CurrentTarget + N'];
                        DECLARE @SuccessMsg NVARCHAR(2000) = ''      (+) [EXITO] Usuario erradicado: ['' + @TargetParam + '']'';
                        RAISERROR (@SuccessMsg, 10, 1) WITH NOWAIT;
                    END TRY
                    BEGIN CATCH
                        DECLARE @ErrMsg NVARCHAR(2000) = ''      (X) [FALLO] Error al borrar ['' + @TargetParam + '']: '' + ERROR_MESSAGE();
                        RAISERROR (@ErrMsg, 10, 1) WITH NOWAIT;
                        INSERT INTO #SkippedLogins (LoginName, Reason) VALUES (@TargetParam, ''BD ['' + DB_NAME() + ''] -> Error no capturado: '' + ERROR_MESSAGE());
                    END CATCH
                END';

                EXEC sp_executesql @DynamicSQL, 
                     N'@TargetParam NVARCHAR(128), @ChkSchemas BIT, @ChkRoles BIT, @AutoTx BIT', 
                     @TargetParam = @CurrentTarget, @ChkSchemas = @CheckSchemas, @ChkRoles = @CheckRoles, @AutoTx = @AutoTransferSchemas;
            END
            FETCH NEXT FROM UserExecCursor INTO @CurrentTarget;
        END
        CLOSE UserExecCursor; DEALLOCATE UserExecCursor;

        FETCH NEXT FROM DBExecCursor INTO @CurrentDB;
    END
    CLOSE DBExecCursor; DEALLOCATE DBExecCursor;

    --------------------------------------------------------------------------------------------------
    -- 6. FASE DE ANIQUILACIÓN: LOGINS (NIVEL SERVIDOR)
    --------------------------------------------------------------------------------------------------
    SET @Msg = CHAR(13) + CHAR(10) + '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    SET @Msg = '>>> FASE 3: ERRADICACIÓN DE LOGINS (NIVEL INSTANCIA) <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
    SET @Msg = '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;

    DECLARE LoginExecCursor CURSOR LOCAL FAST_FORWARD FOR SELECT LoginName FROM #FoundLogins;
    OPEN LoginExecCursor; FETCH NEXT FROM LoginExecCursor INTO @CurrentTarget;

    IF @@CURSOR_ROWS = 0 BEGIN SET @Msg = '   -> Ningún Login a nivel servidor para eliminar.'; RAISERROR (@Msg, 10, 1) WITH NOWAIT; END

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM #SkippedLogins WHERE LoginName COLLATE DATABASE_DEFAULT = @CurrentTarget COLLATE DATABASE_DEFAULT)
        BEGIN
            DECLARE @FinalReason NVARCHAR(MAX) = (SELECT TOP 1 Reason FROM #SkippedLogins WHERE LoginName COLLATE DATABASE_DEFAULT = @CurrentTarget COLLATE DATABASE_DEFAULT);
            SET @Msg = '   (-) [OMITIDO] Login [' + @CurrentTarget + '] protegido. Riesgo: ' + @FinalReason; 
            RAISERROR (@Msg, 10, 1) WITH NOWAIT;
        END
        ELSE
        BEGIN
            DECLARE @SrvDepMsg NVARCHAR(500) = '';
            IF EXISTS (SELECT 1 FROM sys.databases WHERE owner_sid = SUSER_SID(@CurrentTarget))
                SET @SrvDepMsg = 'BD [N/A] -> [Es dueño de una Base de Datos]';
            
            IF LEN(@SrvDepMsg) > 0
            BEGIN
                SET @Msg = '   (-) [BLINDADO] Login [' + @CurrentTarget + '] protegido. Riesgo: ' + @SrvDepMsg; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
            END
            ELSE
            BEGIN
                BEGIN TRY
                    SET @DynamicSQL = N'DROP LOGIN [' + @CurrentTarget + N'];';
                    EXEC sp_executesql @DynamicSQL;
                    SET @Msg = '   (+) [EXITO] Login destruido: [' + @CurrentTarget + ']'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
                END TRY
                BEGIN CATCH
                    SET @Msg = '   (X) [ALERTA] Fallo al eliminar Login [' + @CurrentTarget + '] - Motivo: ' + ERROR_MESSAGE(); RAISERROR (@Msg, 10, 1) WITH NOWAIT;
                END CATCH
            END
        END
        FETCH NEXT FROM LoginExecCursor INTO @CurrentTarget;
    END
    CLOSE LoginExecCursor; DEALLOCATE LoginExecCursor;
END
ELSE
BEGIN
    SET @Msg = CHAR(13) + CHAR(10) + '>>> [INFO] Operación abortada: No hay usuarios confirmados para eliminar. <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
END

SET @Msg = CHAR(13) + CHAR(10) + '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '>>> MISIÓN COMPLETADA: OPERACIÓN FINALIZADA CON ÉXITO <<<'; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
SET @Msg = '==================================================================='; RAISERROR (@Msg, 10, 1) WITH NOWAIT;
--------------------------------------------------------------------------------------------------
