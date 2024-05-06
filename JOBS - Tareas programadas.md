
> [!IMPORTANT]
> Las tablas de los `job` se ven solo en la base de datos **msdb**



### Ejecutar un job 
```SQL
EXEC msdb.dbo.sp_start_job @job_name = 'NombreDelTrabajo';
```

### Habilitar/Desabilitar un job 
```SQL
EXEC msdb.dbo.sp_update_job @job_name = 'NombreDelTrabajo', @enabled = 1; -- Cambia a 0 para Desabilitar
```

### Ver los nombre de los job que existen y si estan habilitados 
```SQL
SELECT job_id, name, enabled  FROM dbo.sysjobs;
```

### Historial de ejecución de un job:
El step_id es el identificador del comando que ejecuta
```SQL

SELECT j.name AS 'Job Name', h.run_date, h.run_time, h.run_status   ,step_id
FROM dbo.sysjobs j
JOIN dbo.sysjobhistory h ON j.job_id = h.job_id
 where step_id!= 0  -- and  j.name = 'test_job_tortolero'
ORDER BY h.run_date DESC, h.run_time DESC;
```

### Ver el comando  que ejecuta el job
```SQL
SELECT j.name AS 'Job Name', s.step_id, s.step_name, s.subsystem, s.command
FROM dbo.sysjobs j
JOIN dbo.sysjobsteps s ON j.job_id = s.job_id
where j.name  = 'test_job_2024'
```


### Esta consulta muestra los trabajos actualmente en ejecución 
```SQL
SELECT job_id, start_execution_date, stop_execution_date, *
FROM sysjobactivity
WHERE start_execution_date IS NOT NULL AND stop_execution_date IS NULL;
```

### extras: 
```SQL
select * from dbo.sysjobschedules   where job_id= '58DDADCD-74CB-4237-8830-1F671C3EE202'   
select * from dbo.sysjobservers where job_id= '58DDADCD-74CB-4237-8830-1F671C3EE202'  
```

### Saber si un job tardo mucho en ejecutarse
```
SELECT distinct b.name ,
        c.command,
        a.step_id ,
        a.run_date ,
        stuff(stuff(replace(str(a.run_time,6,0),' ','0'),3,0,':'),6,0,':') as run_time,
        stuff(stuff(replace(str(a.run_duration,6,0),' ','0'),3,0,':'),6,0,':') as run_duration
FROM    msdb.dbo.sysjobhistory a
INNER JOIN msdb.dbo.sysjobs b ON b.job_id = a.job_id
INNER JOIN msdb.dbo.sysjobsteps c ON c.job_id = a.job_id and a.step_id=c.step_id
WHERE   a.run_date = CONVERT(VARCHAR(11), GETDATE()-1, 112) --and command like '%Aqui colocamos la funcion a buscar%'
ORDER BY b.name ,
        a.step_id
```



### Crear un JOB de ejemplo
```SQL

/* ****** CREAR LA TABLA ******
*/


CREATE TABLE [dbo].[ARTICULOS](
	[ID_Articulo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](100) NULL,
	[Precio] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Articulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


/* ****** CREAR el job ******
*/
USE [msdb]
GO

/****** Object:  Job [test_job_2024]    Script Date: 09/01/2024 04:36:29 p. m. ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 09/01/2024 04:36:29 p. m. ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'test_job_2024', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'MY_user_test', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


/****** Object:  Step [nueva_tarea]    Script Date: 09/01/2024 04:36:29 p. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'nueva_tarea', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'insert into ARTICULOS (Nombre,Precio ) values ( getdate()  ,10)', 
		@database_name=N'TEST_DBA_TORTOLERO', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'programando_horario', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20240109, 
		@active_end_date=99991231, 
		@active_start_time=145600, 
		@active_end_time=235959, 
		@schedule_uid=N'78b4b8ca-3cb8-4098-815d-70157ad53e4d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO




---- BORRAR TODA LA INFO DE LA TABLA ---- 
truncate table ARTICULOS
```


###### Transferir jobs 
```sql
--- Jobs Task in SSIS package  

https://learn.microsoft.com/en-us/sql/integration-services/control-flow/transfer-jobs-task?view=sql-server-ver16
https://www.sqlshack.com/transfer-sql-jobs-between-sql-server-instances-using-ssdt-2017/

```

