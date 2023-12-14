SET NOCOUNT ON;

/* 
		Consulta: BPD-Roles
La ejecución muestra en listado de los roles en la base de datos asi como usuarios pertenecientes a dihoc roles, 
consultando unicamente la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Nombre_Usuario
- Miembros_Rol				

*/

SELECT role.name AS Nombre_Rol,  member.name AS Miembros_Rol
FROM sys.server_role_members  
JOIN sys.server_principals AS role  
    ON sys.server_role_members.role_principal_id = role.principal_id  
JOIN sys.server_principals AS member  
    ON sys.server_role_members.member_principal_id = member.principal_id;  
