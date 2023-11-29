

### Versión de la dba
    SELECT @@VERSION;

### saber el Hostname
    SELECT @@SERVERNAME;


### Saber en que puerto esta corriendo la dba
    SELECT local_net_address, local_tcp_port FROM sys.dm_exec_connections
    WHERE local_net_address IS NOT NULL group by local_net_address,local_tcp_port;

    SELECT CONNECTIONPROPERTY ('local_net_address') AS Ip_servidor
