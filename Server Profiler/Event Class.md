Bibliografía : https://www.sqlservercentral.com/forums/topic/sql-profiler-event-class


```sql
CREATE TABLE #EventClass (EventClass INT NOT NULL, EventName VARCHAR(255) NOT NULL)

INSERT INTO #EventClass (EventClass, EventName) VALUES (10, 'RPC:Completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (11, 'RPC:Starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (12, 'SQL:BatchCompleted')
INSERT INTO #EventClass (EventClass, EventName) VALUES (13, 'SQL:BatchStarting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (14, 'Audit Login')
INSERT INTO #EventClass (EventClass, EventName) VALUES (15, 'Audit Logout')
INSERT INTO #EventClass (EventClass, EventName) VALUES (16, 'Attention')
INSERT INTO #EventClass (EventClass, EventName) VALUES (17, 'ExistingConnection')
INSERT INTO #EventClass (EventClass, EventName) VALUES (18, 'Audit Server Starts And Stops')
INSERT INTO #EventClass (EventClass, EventName) VALUES (19, 'DTCTransaction')
INSERT INTO #EventClass (EventClass, EventName) VALUES (20, 'Audit Login Failed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (21, 'EventLog')
INSERT INTO #EventClass (EventClass, EventName) VALUES (22, 'ErrorLog')
INSERT INTO #EventClass (EventClass, EventName) VALUES (23, 'Lock:Released')
INSERT INTO #EventClass (EventClass, EventName) VALUES (24, 'Lock:Acquired')
INSERT INTO #EventClass (EventClass, EventName) VALUES (25, 'Lock:Deadlock')
INSERT INTO #EventClass (EventClass, EventName) VALUES (26, 'Lock:Cancel')
INSERT INTO #EventClass (EventClass, EventName) VALUES (27, 'Lock:Timeout')
INSERT INTO #EventClass (EventClass, EventName) VALUES (28, 'Degree of Parallelism (7.0 Insert)')
INSERT INTO #EventClass (EventClass, EventName) VALUES (33, 'Exception')
INSERT INTO #EventClass (EventClass, EventName) VALUES (34, 'SP:CacheMiss')
INSERT INTO #EventClass (EventClass, EventName) VALUES (35, 'SP:CacheInsert')
INSERT INTO #EventClass (EventClass, EventName) VALUES (36, 'SP:CacheRemove')
INSERT INTO #EventClass (EventClass, EventName) VALUES (37, 'SP:Recompile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (38, 'SP:CacheHit')
INSERT INTO #EventClass (EventClass, EventName) VALUES (39, 'Deprecated')
INSERT INTO #EventClass (EventClass, EventName) VALUES (40, 'SQL:StmtStarting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (41, 'SQL:StmtCompleted')
INSERT INTO #EventClass (EventClass, EventName) VALUES (42, 'SP:Starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (43, 'SP:Completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (44, 'SP:StmtStarting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (45, 'SP:StmtCompleted')
INSERT INTO #EventClass (EventClass, EventName) VALUES (46, 'Object:Created')
INSERT INTO #EventClass (EventClass, EventName) VALUES (47, 'Object:Deleted')
INSERT INTO #EventClass (EventClass, EventName) VALUES (50, 'SQLTransaction')
INSERT INTO #EventClass (EventClass, EventName) VALUES (51, 'Scan:Started')
INSERT INTO #EventClass (EventClass, EventName) VALUES (52, 'Scan:Stopped')
INSERT INTO #EventClass (EventClass, EventName) VALUES (53, 'CursorOpen')
INSERT INTO #EventClass (EventClass, EventName) VALUES (54, 'TransactionLog')
INSERT INTO #EventClass (EventClass, EventName) VALUES (55, 'Hash Warning')
INSERT INTO #EventClass (EventClass, EventName) VALUES (58, 'Auto Stats')
INSERT INTO #EventClass (EventClass, EventName) VALUES (59, 'Lock:Deadlock Chain')
INSERT INTO #EventClass (EventClass, EventName) VALUES (60, 'Lock:Escalation')
INSERT INTO #EventClass (EventClass, EventName) VALUES (61, 'OLEDB Errors')
INSERT INTO #EventClass (EventClass, EventName) VALUES (67, 'Execution Warnings')
INSERT INTO #EventClass (EventClass, EventName) VALUES (68, 'Showplan Text (Unencoded)')
INSERT INTO #EventClass (EventClass, EventName) VALUES (69, 'Sort Warnings')
INSERT INTO #EventClass (EventClass, EventName) VALUES (70, 'CursorPrepare')
INSERT INTO #EventClass (EventClass, EventName) VALUES (71, 'Prepare SQL')
INSERT INTO #EventClass (EventClass, EventName) VALUES (72, 'Exec Prepared SQL')
INSERT INTO #EventClass (EventClass, EventName) VALUES (73, 'Unprepare SQL')
INSERT INTO #EventClass (EventClass, EventName) VALUES (74, 'CursorExecute')
INSERT INTO #EventClass (EventClass, EventName) VALUES (75, 'CursorRecompile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (76, 'CursorImplicitConversion')
INSERT INTO #EventClass (EventClass, EventName) VALUES (77, 'CursorUnprepare')
INSERT INTO #EventClass (EventClass, EventName) VALUES (78, 'CursorClose')
INSERT INTO #EventClass (EventClass, EventName) VALUES (79, 'Missing Column Statistics')
INSERT INTO #EventClass (EventClass, EventName) VALUES (80, 'Missing Join Predicate')
INSERT INTO #EventClass (EventClass, EventName) VALUES (81, 'Server Memory Change')
INSERT INTO #EventClass (EventClass, EventName) VALUES (82, 'UserConfigurable:0')
INSERT INTO #EventClass (EventClass, EventName) VALUES (83, 'UserConfigurable:1')
INSERT INTO #EventClass (EventClass, EventName) VALUES (84, 'UserConfigurable:2')
INSERT INTO #EventClass (EventClass, EventName) VALUES (85, 'UserConfigurable:3')
INSERT INTO #EventClass (EventClass, EventName) VALUES (86, 'UserConfigurable:4')
INSERT INTO #EventClass (EventClass, EventName) VALUES (87, 'UserConfigurable:5')
INSERT INTO #EventClass (EventClass, EventName) VALUES (88, 'UserConfigurable:6')
INSERT INTO #EventClass (EventClass, EventName) VALUES (89, 'UserConfigurable:7')
INSERT INTO #EventClass (EventClass, EventName) VALUES (90, 'UserConfigurable:8')
INSERT INTO #EventClass (EventClass, EventName) VALUES (91, 'UserConfigurable:9')
INSERT INTO #EventClass (EventClass, EventName) VALUES (92, 'Data File Auto Grow')
INSERT INTO #EventClass (EventClass, EventName) VALUES (93, 'Log File Auto Grow')
INSERT INTO #EventClass (EventClass, EventName) VALUES (94, 'Data File Auto Shrink')
INSERT INTO #EventClass (EventClass, EventName) VALUES (95, 'Log File Auto Shrink')
INSERT INTO #EventClass (EventClass, EventName) VALUES (96, 'Showplan Text')
INSERT INTO #EventClass (EventClass, EventName) VALUES (97, 'Showplan All')
INSERT INTO #EventClass (EventClass, EventName) VALUES (98, 'Showplan Statistics Profile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (100, 'RPC Output Parameter')
INSERT INTO #EventClass (EventClass, EventName) VALUES (102, 'Audit Database Scope GDR Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (103, 'Audit Schema Object GDR Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (104, 'Audit Addlogin Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (105, 'Audit Login GDR Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (106, 'Audit Login Change Property Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (107, 'Audit Login Change Password Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (108, 'Audit Add Login to Server Role Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (109, 'Audit Add DB User Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (110, 'Audit Add Member to DB Role Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (111, 'Audit Add Role Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (112, 'Audit App Role Change Password Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (113, 'Audit Statement Permission Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (114, 'Audit Schema Object Access Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (115, 'Audit Backup/Restore Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (116, 'Audit DBCC Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (117, 'Audit Change Audit Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (118, 'Audit Object Derived Permission Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (119, 'OLEDB Call Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (120, 'OLEDB QueryInterface Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (121, 'OLEDB DataRead Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (122, 'Showplan XML')
INSERT INTO #EventClass (EventClass, EventName) VALUES (123, 'SQL:FullTextQuery')
INSERT INTO #EventClass (EventClass, EventName) VALUES (124, 'Broker:Conversation')
INSERT INTO #EventClass (EventClass, EventName) VALUES (125, 'Deprecation Announcement')
INSERT INTO #EventClass (EventClass, EventName) VALUES (126, 'Deprecation Final Support')
INSERT INTO #EventClass (EventClass, EventName) VALUES (127, 'Exchange Spill Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (128, 'Audit Database Management Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (129, 'Audit Database Object Management Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (130, 'Audit Database Principal Management Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (131, 'Audit Schema Object Management Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (132, 'Audit Server Principal Impersonation Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (133, 'Audit Database Principal Impersonation Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (134, 'Audit Server Object Take Ownership Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (135, 'Audit Database Object Take Ownership Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (136, 'Broker:Conversation Group')
INSERT INTO #EventClass (EventClass, EventName) VALUES (137, 'Blocked process report')
INSERT INTO #EventClass (EventClass, EventName) VALUES (138, 'Broker:Connection')
INSERT INTO #EventClass (EventClass, EventName) VALUES (139, 'Broker:Forwarded Message Sent')
INSERT INTO #EventClass (EventClass, EventName) VALUES (140, 'Broker:Forwarded Message Dropped')
INSERT INTO #EventClass (EventClass, EventName) VALUES (141, 'Broker:Message Classify')
INSERT INTO #EventClass (EventClass, EventName) VALUES (142, 'Broker:Transmission')
INSERT INTO #EventClass (EventClass, EventName) VALUES (143, 'Broker:Queue Disabled')
INSERT INTO #EventClass (EventClass, EventName) VALUES (144, 'Broker:Mirrored Route State Changed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (146, 'Showplan XML Statistics Profile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (148, 'Deadlock graph')
INSERT INTO #EventClass (EventClass, EventName) VALUES (149, 'Broker:Remote Message Acknowledgement')
INSERT INTO #EventClass (EventClass, EventName) VALUES (150, 'Trace File Close')
INSERT INTO #EventClass (EventClass, EventName) VALUES (152, 'Audit Change Database Owner')
INSERT INTO #EventClass (EventClass, EventName) VALUES (153, 'Audit Schema Object Take Ownership Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (155, 'FT:Crawl Started')
INSERT INTO #EventClass (EventClass, EventName) VALUES (156, 'FT:Crawl Stopped')
INSERT INTO #EventClass (EventClass, EventName) VALUES (157, 'FT:Crawl Aborted')
INSERT INTO #EventClass (EventClass, EventName) VALUES (158, 'Audit Broker Conversation')
INSERT INTO #EventClass (EventClass, EventName) VALUES (159, 'Audit Broker Login')
INSERT INTO #EventClass (EventClass, EventName) VALUES (160, 'Broker:Message Undeliverable')
INSERT INTO #EventClass (EventClass, EventName) VALUES (161, 'Broker:Corrupted Message')
INSERT INTO #EventClass (EventClass, EventName) VALUES (162, 'User Error Message')
INSERT INTO #EventClass (EventClass, EventName) VALUES (163, 'Broker:Activation')
INSERT INTO #EventClass (EventClass, EventName) VALUES (164, 'Object:Altered')
INSERT INTO #EventClass (EventClass, EventName) VALUES (165, 'Performance statistics')
INSERT INTO #EventClass (EventClass, EventName) VALUES (166, 'SQL:StmtRecompile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (167, 'Database Mirroring State Change')
INSERT INTO #EventClass (EventClass, EventName) VALUES (168, 'Showplan XML For Query Compile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (169, 'Showplan All For Query Compile')
INSERT INTO #EventClass (EventClass, EventName) VALUES (170, 'Audit Server Scope GDR Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (171, 'Audit Server Object GDR Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (172, 'Audit Database Object GDR Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (173, 'Audit Server Operation Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (175, 'Audit Server Alter Trace Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (176, 'Audit Server Object Management Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (177, 'Audit Server Principal Management Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (178, 'Audit Database Operation Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (180, 'Audit Database Object Access Event')
INSERT INTO #EventClass (EventClass, EventName) VALUES (181, 'TM: Begin Tran starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (182, 'TM: Begin Tran completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (183, 'TM: Promote Tran starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (184, 'TM: Promote Tran completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (185, 'TM: Commit Tran starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (186, 'TM: Commit Tran completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (187, 'TM: Rollback Tran starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (188, 'TM: Rollback Tran completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (189, 'Lock:Timeout (timeout > 0)')
INSERT INTO #EventClass (EventClass, EventName) VALUES (190, 'Progress Report: Online Index Operation')
INSERT INTO #EventClass (EventClass, EventName) VALUES (191, 'TM: Save Tran starting')
INSERT INTO #EventClass (EventClass, EventName) VALUES (192, 'TM: Save Tran completed')
INSERT INTO #EventClass (EventClass, EventName) VALUES (193, 'Background Job Error')
INSERT INTO #EventClass (EventClass, EventName) VALUES (194, 'OLEDB Provider Information')
INSERT INTO #EventClass (EventClass, EventName) VALUES (195, 'Mount Tape')
INSERT INTO #EventClass (EventClass, EventName) VALUES (196, 'Assembly Load')
INSERT INTO #EventClass (EventClass, EventName) VALUES (198, 'XQuery Static Type')
INSERT INTO #EventClass (EventClass, EventName) VALUES (199, 'QN: Subscription')
INSERT INTO #EventClass (EventClass, EventName) VALUES (200, 'QN: Parameter table')
INSERT INTO #EventClass (EventClass, EventName) VALUES (201, 'QN: Template')
INSERT INTO #EventClass (EventClass, EventName) VALUES (202, 'QN: Dynamics')

```
