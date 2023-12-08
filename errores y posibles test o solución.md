



# Error \#1 : Login failed. The login is from an untrusted domain and cannot be used with Windows authentication.

**Validar el tipo de autenticación de sql server**
```
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')
```
**Para cambiar la contraseña del usuario y dominio**
```
https://aka.ms/ssprsetup
https://mysignins.microsoft.com/security-info
https://myaccount.microsoft.com
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


# link de apoyo
************** The login is from an untrusted ************** <br>
https://windowsreport.com/0x8009030c/ <br>
https://dba.stackexchange.com/questions/191267/sspi-handshake-failed-with-error-code-0x8009030c-state-14

