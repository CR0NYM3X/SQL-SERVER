

### OBTENER, IP DEL SERVIDOR, EL HOSTNAME, VERSION Y CANTIDAD DE BASE DE DATOS 
```
select (SELECT local_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID) IP_SERVER, @@SERVERNAME hostname,
(SELECT SUBSTRING(@@version, 1, CHARINDEX( CHAR(10), @@version) - 1) ) version , (select count(*)
from sys.databases where database_id > 4 ) cnt_db
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

### Saber los discos duros y tamaños de windows
```
----  powershell windows  
Get-WmiObject Win32_LogicalDisk |
Select-Object DeviceID, VolumeName,
@{Name="Size(GB)";Expression={"{0:N2}" -f ($_.size / 1GB)}},
@{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.freespace / 1GB)}}

---- cmd windows  
wmic logicaldisk get deviceid, size, freespace, volumename /format:list
wmic cpu get name, caption, maxclockspeed, numberofcores, numberoflogicalprocessors
```


### Versión de la dba
    SELECT @@VERSION;

### saber el Hostname
    SELECT @@SERVERNAME;


### Saber en que puerto esta corriendo la dba
    SELECT local_net_address, local_tcp_port FROM sys.dm_exec_connections
    WHERE local_net_address IS NOT NULL group by local_net_address,local_tcp_port;

    SELECT CONNECTIONPROPERTY ('local_net_address') AS Ip_servidor


