


USE msdb;

--- ejecutar un job 
EXEC msdb.dbo.sp_start_job @job_name = 'NombreDelTrabajo';

---- desactivar un job 
EXEC msdb.dbo.sp_update_job @job_name = 'NombreDelTrabajo', @enabled = 0; -- Cambia a 1 para habilitar

---- saber lo job que hay 
SELECT job_id, name, enabled  FROM dbo.sysjobs;

-- Detalles de los pasos de un job específico:
SELECT j.name AS 'Job Name', s.step_id, s.step_name, s.subsystem, s.command
FROM dbo.sysjobs j
JOIN dbo.sysjobsteps s ON j.job_id = s.job_id

--- Historial de ejecución de un job:
SELECT j.name AS 'Job Name', h.run_date, h.run_time, h.run_status
FROM dbo.sysjobs j
JOIN dbo.sysjobhistory h ON j.job_id = h.job_id
ORDER BY h.run_date DESC, h.run_time DESC;


---- Ver que es lo que ejecuta la tarea 
SELECT j.name AS 'Job Name', s.step_id, s.step_name, s.command
FROM dbo.sysjobs j
JOIN dbo.sysjobsteps s ON j.job_id = s.job_id



--- Esta consulta muestra los trabajos actualmente en ejecución 
SELECT job_id, start_execution_date, stop_execution_date, *
FROM sysjobactivity
WHERE start_execution_date IS NOT NULL AND stop_execution_date IS NULL;


extras: 
select * from dbo.sysjobschedules 
SELECT * FROM dbo.sysjobhistory


