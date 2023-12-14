


SELECT	GETDATE()							AS	[Datetime],
		t1.resource_type					AS  [Lock Type],
		DB_NAME(resource_database_id)		AS	[Database],
		t1.resource_associated_entity_id	AS	[Blocked Object],
		t1.request_mode						AS	[Requested Lock],
		t1.request_session_id				AS	[Blocked Processes id],  
		t2.blocking_session_id				AS  [Blocker Process ID], 
		t3.open_tran						AS	[Blk trans open],	--Transactions opened by the blocker process
		t2.wait_duration_ms					AS	[Wait time(ms)],	
		t3.hostname							AS	[Blocker Host],
		t3.program_name						AS	[Blocker Process],
		qb.text								AS	[Blocked Batch],
		t2.resource_description				AS	[Held Lock],
		(SELECT SUBSTRING(qb.text,r.statement_start_offset/2, 
				(CASE 
						WHEN r.statement_end_offset = -1 
						THEN len(convert(nvarchar(max), qb.text)) * 2 
						ELSE r.statement_end_offset 
						end - r.statement_start_offset)/2) ) AS [Blocked Statement],
		(SELECT  CASE	r.transaction_isolation_level
						WHEN 0 THEN 'Unspecified'
						WHEN 1 THEN 'ReadUncomitted'
						WHEN 2 THEN 'ReadCommitted'
						WHEN 3 THEN 'Repeatable'
						WHEN 4 THEN 'Serializable'
						WHEN 5 THEN 'Snapshot'
					END) AS [Blocked Isolation Level],    
		 qp.text AS [Blocker Batch],
		(SELECT	
				CASE	transaction_isolation_level
						WHEN 0 THEN 'Unspecified'
						WHEN 1 THEN 'ReadUncomitted'
						WHEN 2 THEN 'ReadCommitted'
						WHEN 3 THEN 'Repeatable'
						WHEN 4 THEN 'Serializable'
						WHEN 5 THEN 'Snapshot'
				END	
				FROM sys.dm_exec_sessions AS r2  
				WHERE r2.session_id = t2.blocking_session_id)		AS [Blocker Isolation Level]
		FROM	sys.dm_tran_locks AS t1	JOIN	sys.dm_os_waiting_tasks AS t2
										ON	t1.lock_owner_address = t2.resource_address
										JOIN	sys.sysprocesses AS t3
										ON	t3.spid = t2.blocking_session_id
										JOIN	sys.dm_exec_requests AS r
										ON	r.session_id = t1.request_session_id
		CROSS	APPLY	sys.dm_exec_sql_text(r.sql_handle)	AS qb
		CROSS	APPLY	sys.dm_exec_sql_text(t3.sql_handle)	AS qp