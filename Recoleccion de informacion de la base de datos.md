
### ver el modelo del servidor 
wmic csproduct get name, identifyingnumber

### OBTENER, IP DEL SERVIDOR, puerto del servidor, EL HOSTNAME, VERSION Y CANTIDAD DE BASE DE DATOS 
```sql
select     (SELECT local_net_address FROM sys.dm_exec_connections where   session_id = @@SPID  ) IP_SERVER, -- select cast(connectionproperty ('local_net_address') as varchar)  as ip_server  
	   (SELECT  local_tcp_port FROM sys.dm_exec_connections where   session_id = @@SPID  ) PORT_SERVER,
            @@SERVERNAME hostname,
	    @@servicename instancia,
           (SELECT SUBSTRING(@@version, 1, CHARINDEX( CHAR(10), @@version) - 1) ) version ,
            SERVERPROPERTY('Edition') AS 'Edición',
	   (select count(*) from sys.databases where database_id > 4 ) cnt_db


```

# Validar información del S.O y SQL 
```SQL
EXEC xp_msver;
```

### Saber cuantas instanacias tiene el servidor 
```SQL

********** SABER LAS CANTIDADES DE INSTANCIAS QUE HAY EN EL SERVIDOR **********
EXEC xp_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Microsoft SQL Server', 'InstalledInstances'


********** CONECTADO EN ESCRITORIO REMOTO USAMOS LA HERRAMIENTA SQLCMD **********
SQLCMD -L

```



### Saber la ip del server o tu ip
```
	select CONNECTIONPROPERTY('client_net_address');
	select CONNECTIONPROPERTY ('local_net_address') AS Ip_servidor
```


### saber las versiones de windows  
```
dxdiag
msinfo32.exe
winver -- ver la version de windows
```

### Saber el tamaños de los discos de windows  con cmd o powershell
```
----  powershell windows  
Get-WmiObject Win32_LogicalDisk |
Select-Object DeviceID, VolumeName,
@{Name="Size(GB)";Expression={"{0:N2}" -f ($_.size / 1GB)}},
@{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.freespace / 1GB)}}

Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="TotalSpaceGB";Expression={[math]::round($_.Used / 1GB, 2)}}, @{Name="FreeSpaceGB";Expression={[math]::round($_.Free / 1GB, 2)}}



---- cmd windows  
wmic logicaldisk get deviceid, size, freespace, volumename /format:list
wmic cpu get name, caption, maxclockspeed, numberofcores, numberoflogicalprocessors
```

### Saber el tamaños de los discos de windows  con sql server
```SQL
 

/* Te muesta mas detallada la info de los discos */
select DISTINCT  
 GETDATE()  AS Fecha
,CONNECTIONPROPERTY ('local_net_address') AS Ip_servidor
,@@SERVERNAME AS NombreServidor
    ,SUBSTRING(volume_mount_point, 1, 1) AS Disco
        ,100.0 - ISNULL(ROUND(available_bytes / CAST(NULLIF(total_bytes, 0) AS FLOAT) * 100, 2), 0) as Porcentaje_Usado
    ,total_bytes/1024/1024/1024 AS total_GB
        ,total_bytes/1024/1024/1024 - available_bytes/1024/1024/1024 AS Usado_GB
    ,available_bytes/1024/1024/1024 AS Disponible_GB
    ,ISNULL(ROUND(available_bytes / CAST(NULLIF(total_bytes, 0) AS FLOAT) * 100, 2), 0) as Porcentaje_Disponible
    --,f.physical_name
        --,available_bytes 
 from sys.master_files AS f
CROSS APPLY
 sys.dm_os_volume_stats(f.database_id, f.file_id)
 INNER JOIN sys.sysaltfiles af ON f.database_id = af.dbid
 where
f.database_id not in (2) -- and f.physical_name not like '%.LDF%'
--and available_bytes > 75161927680
order by Porcentaje_Usado desc


/*  nombre del disco, el espacio total, el espacio libre */ 
xp_fixeddrives

SELECT 
	fixed_drive_path
    ,cast(free_space_in_bytes / (1024.0 * 1024.0 * 1024.0)  as decimal(10,2)) 'Free Space (GB)'
FROM sys.dm_os_enumerate_fixed_drives;

select * from DISKINFO
 

```



### Versión de la dba
    SELECT @@VERSION;

### saber el Hostname
    SELECT @@SERVERNAME;


### Saber en que puerto esta corriendo la dba
    SELECT local_net_address, local_tcp_port FROM sys.dm_exec_connections
    WHERE local_net_address IS NOT NULL group by local_net_address,local_tcp_port;

    SELECT CONNECTIONPROPERTY ('local_net_address') AS Ip_servidor


