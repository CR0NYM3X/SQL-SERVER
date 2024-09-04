



# Error \#1 : Login failed. The login is from an untrusted domain and cannot be used with Windows authentication.

https://solutions.dbwatch.com/Sqlserver/ <br><br>

**Validar el tipo de autenticación de sql server**
```
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')
```
**Para cambiar la contraseña del usuario y dominio**
```
https://aka.ms/ssprsetup
https://mysignins.microsoft.com/security-info
https://myaccount.microsoft.com
https://account.activedirectory.windowsazure.com/ChangePassword.aspx
```

**Validar el usuario que esas en windows**
ver tu usuario de dominio, LOS grupos en los que estas Y las políticas que tienes  aplicadas 
```
whoami /all 
```

**Verificar la existencia de un usuario en activi directory**
Si el usuario no existe te retornara el error "El dominio especificado no existe", si sí existe te retornara los dominios
```
 net user /domain alejandro.lopez
```
 

**ver las ip del dominio** 
- Con esta consulta vas a ver las ip y los dns de los dominios active directory que existen y responde a tu computadora,  por ejemplo:  usuario1.CRONYMEX.com, grupodessarollo,CRONYMEX.com, jefes.CRONYMEX.com
```
 nslookup -type=srv _ldap._tcp.dc._msdcs.CRONYMEX.com
```

- Con esta consulta vas a ver el a que subdominio pertenece
```
 echo %LOGONSERVER%

***** Ejemplo que retora esta consulta *****
\\jefes

***** validar la ip  *****
ping jefes

```
 
**Corroborar que el usuario si se puede autenticar y ver que si funcione correctamente**

```
****** EJECUTAS ESTE COMANDO PRIMERO Y COLOCAS CONTRASEÑA Y DESPUÉS SE ABRIRA EL CMD ******
runas /user:coppel\alejandro.lopez "C:\Windows\System32\cmd.exe"

****** UNA VEZ SE ABRA EL CMD NUEVO COLOCAS ESTE COMANDO Y TE DIRA SI ESTAS DENTRO DEL DOMINIO Y USUARIO ******
whoami

****** PARA VALIDAR SI PUEDES REALIZAR LA CONEXION DESDE SQLCMD  ******
sqlcmd -E -S 192.168.1.10 -d master -Q "select 'usuario:  '+SUSER_SNAME()"

```


**Mostrar una lista de los Controladores de Dominio disponibles en un dominio**
```
nltest /dclist:coppel 
```

**Verificar la confiabilidad y la conectividad al dominio**
```
nltest /dsgetdc:coppel 
```

**otros**
```
nltest /dsgetsite
nltest /domain_trusts
```

### Problemas para iniciar sesion por usuario huérfanos 
Este detalle se puede presentar porque el  sid usuario creado en la base de datos no coincide con el sid login, o  puede ser que el usuario de la base de datos no se elimino y que el login si se elimino , entonces por eso se dice que
el usuario se quedo huérfanos porque ya no esta ligado a un login, y siempre un usuario debe de tener un login y coincidir su sid 




**sp_change_users_login** es un procedimiento almacenado en SQL Server que solía utilizarse para corregir la desincronización entre un usuario de base de datos y su inicio de sesión correspondiente en el servidor de base de datos.
```
***** Identificar usuarios sin asociar con logins: *****

-- Si no coinciden entonces es un usuario huérfanos
SELECT a.name, a.sid, b.sid, a.type_desc
FROM sys.database_principals AS a
LEFT JOIN sys.server_principals AS b on a.name COLLATE DATABASE_DEFAULT = b.name COLLATE DATABASE_DEFAULT
where a.type_desc in('WINDOWS_USER', 'SQL_USER' ,  'DATABASE_ROLE','WINDOWS_GROUP') and 
a.sid != b.sid --and a.name= 'AdmonFlotas'
ORDER BY a.type_desc,a.name;

-- o puedes usar el procedimiento que es para lo mismo
EXEC sp_change_users_login 'Report';




***** Vincular un usuario huérfano con un inicio de sesión: ***** 
EXEC sp_change_users_login 'Update_One', 'nombre_de_usuario', 'nombre_de_login';

***** OTRA OPCIÓN ES ***** 
ALTER USER nombre_de_usuario WITH LOGIN = nombre_de_login;
```

### solucion 
se cambio de contraseña el correo 

Para validar si tu servidor está dentro de un dominio y a qué dominios apunta, puedes usar varios comandos en la línea de comandos (CMD). Aquí te dejo los pasos detallados:

### Validar si el Servidor Está en un Dominio

1. **Abrir CMD con Privilegios de Administrador**:
   - Haz clic derecho en el menú de inicio y selecciona "Símbolo del sistema (Administrador)".

2. **Usar el Comando `systeminfo`**:
   - Escribe el siguiente comando para obtener información del sistema, incluyendo el dominio al que pertenece:

     ```cmd
     systeminfo | findstr /B /C:"Domain"
     ```

   - Este comando buscará la línea que comienza con "Domain" en la salida de `systeminfo`.

### Ejemplo de Salida

```cmd
Domain:                    DOMINIO_LOCAL
```

Si el servidor está en un dominio, verás el nombre del dominio. Si no está en un dominio, verás algo como "Workgroup".

### Ver a Qué Dominios Apunta

1. **Usar el Comando `nltest`**:
   - Puedes usar `nltest` para listar los controladores de dominio (DC) disponibles en tu dominio:

     ```cmd
     nltest /dclist:tu_dominio
     ```

   - Reemplaza `tu_dominio` con el nombre de tu dominio.

### Ejemplo de Salida

```cmd
C:\> nltest /dclist:dominio
    Lista de DCs en dominio "dominio" desde \\DC1
        DC1.dominio.com [PDC]
        DC2.dominio.com
    El comando se completó correctamente
```

### Verificar Relaciones de Confianza entre Dominios
 puede verificar las relaciones de confianza entre dominios. Esto es útil para asegurarse de que los dominios confían entre sí y que la autenticación cruzada funciona correctamente.

1. **Usar el Comando `netdom`**:
   - Para verificar las relaciones de confianza entre dominios, puedes usar el siguiente comando:

     ```cmd
     netdom trust trusting_domain /d:trusted_domain /verify
     ```

   - Reemplaza `trusting_domain` y `trusted_domain` con los nombres de los dominios correspondientes.

2. **Listar Relaciones de Confianza**:
   - Puedes listar todas las relaciones de confianza que un dominio tiene con otros dominios.

     ```cmd
     netdom trust nombre_del_dominio /domain:dominio /enumerate
     ```


### Ejemplo de Uso

```cmd
netdom trust dominio_local /d:dominio_remoto /verify
```




Para validar si un usuario existe en el Active Directory desde la línea de comandos (CMD), puedes utilizar el comando `dsquery`. Aquí te dejo los pasos para hacerlo:

### Validar Usuario en Active Directory

1. **Buscar Usuarios**:
   - Puedes buscar usuarios en el dominio utilizando varios criterios, como el nombre.

     ```cmd
     dsquery user -name "nombre_del_usuario"
     ```

2. **Buscar Grupos**:
   - Puedes buscar grupos en el dominio.

     ```cmd
     dsquery group -name "nombre_del_grupo"
     ```

3. **Buscar Unidades Organizativas (OU)**:
   - Puedes buscar unidades organizativas en el dominio.

     ```cmd
     dsquery ou -name "nombre_de_la_ou"
     ```

4. **Buscar Equipos**:
   - Puedes buscar equipos en el dominio.

     ```cmd
     dsquery computer -name "nombre_del_equipo"
     ```
 


### Ejemplo 

Aquí tienes un ejemplo completo de cómo se vería:

```cmd
C:\> dsquery user -name "juan.perez"
"CN=Juan Perez,OU=Usuarios,DC=dominio,DC=com"
```



### Alternativa con `net user`

Otra forma de verificar si un usuario de dominio existe es utilizando el comando `net user`:

```cmd
net user nombre_del_usuario /domain
```

Por ejemplo:

```cmd
net user juan.perez /domain
```
  


### Resumen

- **`systeminfo`**: Para verificar si el servidor está en un dominio.
- **`nltest`**: Para listar los controladores de dominio.
- **`netdom`**: Para verificar relaciones de confianza entre dominios.
 
 






### link de apoyo
************** The login is from an untrusted ************** <br>
https://windowsreport.com/0x8009030c/ <br>
https://dba.stackexchange.com/questions/191267/sspi-handshake-failed-with-error-code-0x8009030c-state-14












# Error \#2 : Could not open error log file.
Al intentar inciar el servicio de sql, aparecia el siguiente error 
```sql
****************** ERROR ******************
 Error : "initerrlog: Could not open error log file 'F:\SQLERRORLOG\ERRORLOG'. Operating system error = 5(Access is denied.)"

****************** SOLUCION ******************
se dio permiso en el disco F al usuario que levanta el servicio de sql server
```



# Error \#3 : The system cannot find the path specified.

Al intentar levantar el servicio de sql server, se levanto el servicio pero casi todas las base de datos estaban con estatus "Recovery Pending"  y validando el log salio el error de ":Open failed: Could not open"
```sql
*********** ERROR ***********
FCB::Open failed: Could not open file O:\SQLSERVDATA\TablasTmp.MDF for file number 1.  OS error: 3(The system cannot find the path specified.). 2024-01-05 10:43:31.19 spid61s     Error: 5120, Severity: 16, State: 101.


************* QUERYS UTILIZADAS **********
# Muestra la rutas los archivos de la base de datos que no estan online 
select DB_NAME(database_id),name,physical_name,LEFT(physical_name, 1) unidad_disco from sys.master_files 
where database_id in(select database_id from sys.databases where state_desc != 'ONLINE')
order by database_id

# Muestra las rutas de todos los archivos de la base de datos 
SELECT  physical_name from sys.master_files

# puedes ver los log del servidor 
EXEC sp_readerrorlog 0, 1, 'Open failed'

EXEC sp_readerrorlog 0, 1, 'Recovery of database'



************* SOLUCION **********
1.- Descargue el bat -> https://github.com/CR0NYM3X/SQL-SERVER/tree/main/script_bat 
2.- Se paso al servidor la herramienta validador_de_archivos.bat y se creo el archivo "Rutas.txt" en la misma ruta donde coloque el bat,
y llene el txt con los physical_name de las base de datos, obtenida esta info de la tabla sys.master_files
3.- Se encontro que los archivos mdf y ldf  se  encontraban en otros discos con diferentes letras
4.- Se detuvo el servicio de sql server y se apoyo por parte de windows a cambiar las letras
5.- Se levanto el servicio y las base de datos que tenian el detalle se pusieron en estatus "restoring"
6.- Finalizo la restauración y ya permitio ingresar a las dbs

```



