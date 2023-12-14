SET NOCOUNT ON;

/* 
		Consulta: BPD-Backup
La ejecución muestra la información sobre la base del sistema, que es donde se alojan los backups que existen a nivel 
instania, consultando unicamente la capa de información propia de ésta. La consulta extrae la siguiente informacion: 
- Nombre_Servidor
- Nombre_BD
- Fecha_Inicio
- Fecha_Termino
- Tipo_Backup
- Tamaño_Backup
- Ruta_fisica
- Nombre_Backup

*/

SELECT 
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Nombre_Servidor, 
msdb.dbo.backupset.database_name Nombre_BD, 
msdb.dbo.backupset.backup_start_date Fecha_Inicio, 
msdb.dbo.backupset.backup_finish_date Fecha_Termino, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
When 'I' THEN 'Differential database'
END AS Tipo_Backup, 
msdb.dbo.backupset.backup_size/1024/1024/1024 Tamaño_Backup, 
msdb.dbo.backupmediafamily.physical_device_name Ruta_fisica, 
isnull(msdb.dbo.backupset.name, 'SN') AS Nombre_Backup
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
ORDER BY msdb.dbo.backupset.backup_finish_date desc