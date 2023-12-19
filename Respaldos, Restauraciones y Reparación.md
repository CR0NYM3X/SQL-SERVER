# Objetivo:
Aprender hacer respaldos y restaurar la información de una base de datos, para prevenir tragedias 


# Herramientas que se usan :
Esta es la ruta de donde se encuentran las herramientas que se van usar , dependiendo de la version que tienes instalada, por ejemplo en este caso yo tengo la 130 y uso esta ruta <br>

**C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn**

**BCP.exe**  (Bulk Copy Program) Es una herramienta que sirve para Importar y exportar datos en un archivo de windows, tambien sirve para restaurar la información <br>
```
usage: bcp {dbtable | query} {in | out | queryout | format} datafile
  [-m maxerrors]            [-f formatfile]          [-e errfile]
  [-F firstrow]             [-L lastrow]             [-b batchsize]
  [-n native type]          [-c character type]      [-w wide character type]
  [-N keep non-text native] [-V file format version] [-q quoted identifier]
  [-C code page specifier]  [-t field terminator]    [-r row terminator]
  [-i inputfile]            [-o outfile]             [-a packetsize]
  [-S server name]          [-U username]            [-P password]
  [-T trusted connection]   [-v version]             [-R regional enable]
  [-k keep null values]     [-E keep identity values]
  [-h "load hints"]         [-x generate xml format file]
  [-d database name]
```

**SQLCMD.exe / OSQL.exe** (Structured Query Language  Command-line) Es una herramienta de línea de comandos que permite ejecutar scripts de Transact-SQL (T-SQL) y comandos SQL en instancias de SQL Server.
```
Microsoft (R) SQL Server Command Line Tool
Version 10.50.6000.34 NT x64
Copyright (c) Microsoft Corporation.  All rights reserved.

usage: Sqlcmd            [-U login id]          [-P password]
  [-S server]            [-H hostname]          [-E trusted connection]
  [-N Encrypt Connection][-C Trust Server Certificate]
  [-d use database name] [-l login timeout]     [-t query timeout]
  [-h headers]           [-s colseparator]      [-w screen width]
  [-a packetsize]        [-e echo input]        [-I Enable Quoted Identifiers]
  [-c cmdend]            [-L[c] list servers[clean output]]
  [-q "cmdline query"]   [-Q "cmdline query" and exit]
  [-m errorlevel]        [-V severitylevel]     [-W remove trailing spaces]
  [-u unicode output]    [-r[0|1] msgs to stderr]
  [-i inputfile]         [-o outputfile]        [-z new password]
  [-f <codepage> | i:<codepage>[,o:<codepage>]] [-Z new password and exit]
  [-k[1|2] remove[replace] control characters]
  [-y variable length type display width]
  [-Y fixed length type display width]
  [-p[1] print statistics[colon format]]
  [-R use client regional setting]
  [-b On error batch abort]
  [-v var = "value"...]  [-A dedicated admin connection]
  [-X[1] disable commands, startup script, enviroment variables [and exit]]
  [-x disable variable substitution]
  [-? show syntax summary]
```


# Tipos de respaldos 
Respaldos incrementales <br> 
Respaldos completos <br>
Respaldos solo de data <br>



# Ejemplos de uso:


# Ambientación 
Pasar tablas de un servidor a otro desde SQL  management studio
![ambiente-sql](https://github.com/CR0NYM3X/SQL-SERVER/blob/main/img/ambientaci%C3%B3n.jpg)

### 1.- exportar toda la información de una tabla en un archivo csv y volverla a importar


**Exportar la informacion con bcp**
en estos casos no se puede exportar con el encabezado

**`[NOTA IMPORTANTE] --->`** Se recomienda utilizar delimitadores diferente a la comilla,  ya que si la tabla que vas exportar tiene campos varchar puede tener comillas dentro de la columna y esto puede entorpecer al momento de importar la información ,por ejemplo yo uso "|"
```
--- Exportando toda la tabla
bcp my_dba_test.dbo.my_tabla_test out "C:\my_tabla_test.csv" -S 192.168.10.50 -T -t "," -c  -r\n

--- Exportando con condicional en la tabla
bcp "select * from my_tabla_test where nombre='jose' " queryout  "C:\my_tabla_test.csv" -S 192.168.10.50 -T -t "|" -c  -r "\n" -d new_dba_test2
```

**Exportar la informacion con sqlcmd**
```
sqlcmd -S servidor -d base_de_datos -Q "SELECT * FROM mi_tabla WHERE condicion_campo = 'valor'" -o salida_temporal.txt -h-1 -s"," -W
```

**Importar la información con bcp**

**`[NOTA IMPORTANTE] --->`** Cuando se hace un copiado de información con millones de registros , La tabla se bloquea y no se puede consultar y el espacio usado del log transaccional se va llenando y aumenta rapidamente, por lo que si el log transaccional llega a su limite de espacio, puede tener problemas para copiar la información, para ir monitoreando el tamaño utilizado,   [ingresa a este link, para ver la query que  monitorea el espacio usado del log transaccional](https://github.com/CR0NYM3X/SQL-SERVER/blob/main/Base%20de%20datos.md#saber-el-tama%C3%B1o-utilizado-de-los-archivos-mdf-ndf-y-ldf), una vez terminado el copiado, el espacio usado de log empieza a disminur, para validar si se esta copiando la información, lo validamos con el procedimiento sp_who2 en donde el campo status estara en RUNNABLE  y campo command estara en BULK INSERT  

```
bcp  my_dba_test.dbo.my_tabla_test in  "C:\my_tabla_test.csv" -S 192.168.10.50 -T -t "|" -c  -r\n -F 2

-- El parametro -F 2 le indica al programa que inicie desde la linea 2 y no desde la primera linea,
esto sirve para cuando el documento tiene el encabezado de cada columna, aunque el BCP en automatico puede salta el encabezado 
```

**Importar la información con bulk insert**
```
BULK INSERT my_tabla_test
FROM 'C:\my_tabla_test.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1 --- si tiene encabezado ponle el numero 2
);

```



###  hacer un respaldo de una base de datos  y realizar la restauración
[documentacion de backups](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-full-database-backup-sql-server?view=sql-server-ver16)
**hacer respaldo**
```
******* QUERY BACKUP COMPLETO *******
USE [master]
BACKUP DATABASE [MY_DBA_TEST]
TO  DISK = N'C:\respaldo_nuevo_completo.bak' 
WITH NOFORMAT, NOINIT, NAME = N'new_dba_test2-Full Database Backup',SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

******* QUERY BACKUP COMPLETO, PERO DIVIDIDO EN ARCHIVOS *******
USE [master]
BACKUP DATABASE [MY_DBA_TEST]
TO  DISK = N'C:\respaldo_nuevo_1.bak',
    DISK = N'C:\respaldo_nuevo_2.bak',
    DISK = N'C:\respaldo_nuevo_3.bak' 
WITH NOFORMAT, NOINIT, NAME = N'new_dba_test2-Full Database Backup',SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

******* PARÁMETROS *******
WITH NOFORMAT, NOINIT

WITH FORMAT --- Se eliminarán los conjuntos de respaldo anteriores
WITH INIT   --- Permite sobrescribir el contenido de los medios de respaldo existentes sin necesariamente eliminar la información sobre backups anteriores.
WITH DIFFERENTIAL --- especifica que el backup contiene solo las diferencias desde el último backup completo.
STATS = 10 -- Se utiliza para especificar la frecuencia con la que se mostrarán los mensajes de progreso durante la operación de backup
NOUNLOAD -- se utiliza para evitar la descarga (unload) automática del conjunto de medios de respaldo después de una operación de backup.
NOREWIND -- se indica que el conjunto de medios de respaldo no debe rebobinarse después de la operación de backup
SKIP -- se utiliza para saltar los dispositivos de respaldo que ya están abiertos.
RETAINDAYS = 11 --- colocar dias de expiracion 
EXPIREDATE = N'12/01/2023 00:00:00'  -- colocar fecha de expiracion del respaldo
COMPRESSION --- comprimir el backup

```

**Restaurar base de datos**
```
******* QUERY BACKUP COMPLETO *******
USE [master]
RESTORE DATABASE [MY_DBA_TEST] FROM  
DISK =  N'C:\respaldo_nuevo_completo.bak'
WITH  FILE = 1,  NOUNLOAD,  STATS = 5, REPLACE -- REPLACE SE USA PARA CUANDO LA BASE DE DATOS YA EXISTE ENTONCES LA REMPLAZA
GO


******* QUERY RESTAURAR COMPLETO, PERO DE ARCHIVOS DIVIDIDO *******
USE [master]
RESTORE DATABASE [MY_DBA_TEST] FROM  
DISK =  N'C:\respaldo_nuevo_1.bak',  
DISK =  N'C:\respaldo_nuevo_2.bak', 
DISK =  N'C:\respaldo_nuevo_3.bak', 
WITH  FILE = 1,  NOUNLOAD,  STATS = 5, REPLACE -- REPLACE SE USA PARA CUANDO LA BASE DE DATOS YA EXISTE ENTONCES LA REMPLAZA
GO

```



# Reparación de una base de datos

**1.- Colocar modo Emergencia:** Esto lo que hace es que coloca la dba en solo lectura, SQL Server trata de realizar un 
chequeo de integridad de la base de datos y permite al administrador realizar ciertas acciones para intentar recuperar
la base de datos.
```
ALTER DATABASE new_dba_test24 SET EMERGENCY
```

**2.- Analiza la base de datos, para detectar errores:**
```
 DBCC CHECKDB (N'database_name') WITH ALL_ERRORMSGS, NO_INFOMSGS 
```
 
**Cambiar a modo Single_user** esto lo que hace es que los usuarios no va a poder modificar los datos, mientras la restauración está en curso.
```
ALTER DATABASE NombreDeLaBaseDeDatos SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
```

**3.- Reparar la base de datos**
Si viste que sí tiene errores, entonces ejecuta este comando
```
******* QUERY *******
DBCC CHECKDB('NombreDeLaBaseDeDatos', REPAIR_REBUILD);

******* OPCIONES DE PARÁMETROS *******
REPAIR_REBUILD :  Esta opción es la recomendada
REPAIR_ALLOW_DATA_LOSS : Esta opción puede eliminar algunas páginas de la base de datos. Por lo tanto, Microsoft no recomienda, en caso de ser muy necesario usar esta opción
```

**4.- Cambiar a modo Multi_user:** Esto hace que es que ya puedan tener acceso 
```
ALTER DATABASE [NombreDeLaBaseDeDatos] SET READ_WRITE;
ALTER DATABASE [NombreDeLaBaseDeDatos] SET MULTI_USER;
```




# Bibliografías :
Reparación de una dba: https://nira.com/how-to-repair-a-corrupted-sql-database/
