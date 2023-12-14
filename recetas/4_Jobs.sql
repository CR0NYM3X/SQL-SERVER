SET NOCOUNT ON;

/* 
		Consulta: BPD-Jobs
La ejecución muestra el listado de jobs que se encuentran dentro de la instancia, consultando unicamente 
la capa de información propia de ésta. La consulta extrae la siguiente informacion: 
- Notificacion_Correo
- Nombre_Job
- Descripcion
- Pasos_Programados
- Script
- Nombre_BD
- Calendarizacion

*/
select notify_level_email Notificacion_Correo, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NAME,CHaR(10),' ') ,CHaR(13),' ') ,' ',' '),'          ', ' '),',',';') Nombre_Job, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(description,CHaR(10),' ') ,CHaR(13),' ') ,' ',' '),'          ', ' '),',',';') Descripcion, step_name Pasos_Programados, 
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(command,CHaR(10),' ') ,CHaR(13),' ') ,' ',' '),'          ', ' '),',',';') Script, database_name Nombre_BD, sch.next_run_date as Calendarizacion
from msdb.dbo.sysjobs job
inner join msdb.dbo.sysjobsteps steps on job.job_id = steps.job_id
inner join msdb.dbo.sysjobschedules sch on job.job_id = sch.job_id
WHERE job.enabled = 1 
order by name