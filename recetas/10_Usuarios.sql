SET NOCOUNT ON;

/* 
		Consulta: BPD-Usuarios Roles
La ejecución muestra en listado de todos los usuarios que se encuentran a nivel instancia y su respectiva 
clasificacion que tienen a nivel base de datos, consultando unicamente la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Nombre_Usuario
- Tipo_Usuario
- DatabaseUserName
- Tipo_Rol
- Tipo_Permiso
- Estatus_Permiso
- Tipo_Objeto
- Nombre_Objeto					

*/

SELECT
    [Nombre_Usuario] = CASE princ.[type]
                    WHEN 'S' THEN princ.[name]
                    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [Tipo_Usuario] = CASE princ.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END,
    [DatabaseUserName] = princ.[name],
    [Tipo_Rol] = null,
    [Tipo_Permiso] = perm.[permission_name],
    [Estatus_Permiso] = perm.[state_desc],
    [Tipo_Objeto] = obj.type_desc,
    [Nombre_Objeto] = OBJECT_NAME(perm.major_id)
FROM sys.database_principals princ
LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE princ.[type] in ('S','U')

UNION

SELECT [UserName] = CASE memberprinc.[type]
                    WHEN 'S' THEN memberprinc.[name]
                    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE memberprinc.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END,
    [DatabaseUserName] = memberprinc.[name],
    [Role] = roleprinc.[name],
    [PermissionType] = perm.[permission_name],
    [PermissionState] = perm.[state_desc],
    [ObjectType] = obj.type_desc,--perm.[class_desc],
    [ObjectName] = OBJECT_NAME(perm.major_id)
FROM sys.database_role_members members
JOIN sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]

UNION

SELECT
    [UserName] = '{All Users}',
    [UserType] = '{All Users}',
    [DatabaseUserName] = '{All Users}',
    [Role] = roleprinc.[name],
    [PermissionType] = perm.[permission_name],
    [PermissionState] = perm.[state_desc],
    [ObjectType] = obj.type_desc,--perm.[class_desc],
    [ObjectName] = OBJECT_NAME(perm.major_id)
FROM sys.database_principals roleprinc
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
JOIN sys.objects obj ON obj.[object_id] = perm.[major_id]
WHERE roleprinc.[type] = 'R' AND roleprinc.[name] = 'public' AND obj.is_ms_shipped = 0
ORDER BY
princ.[Name],
OBJECT_NAME(perm.major_id),
perm.[permission_name],
perm.[state_desc],
obj.type_desc