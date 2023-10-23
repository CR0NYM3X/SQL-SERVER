

### Conectarse a sql server desde CMD 
```
# Directorio donde se encuentra la herramienta:
C:\Program Files\Microsoft SQL Server\150\Tools\Binn

//// Ejemplos #1
OSQL.EXE -E -S My_hostnameServ -d Mydba -Q "SELECT name FROM sys.databases" 

//// Ejemplos #2
OSQL.EXE -S My_hostnameServ -d Mydba -U Usuario_test -i script.sql -o "C:\Users\alex\Desktop\log_script.txt"

*** Info parámetro ***
-E Este le indicas que utilice el windows autentication, con esta opcion no colocas ningun usuario o contraseña
-S Colocas el hostname del servidor
-d colocas el nombre de la base de datos a la que te conectas 
-Q sirve para ejecutar querys
-i Sirve para ejecutar scripts que tengan querys denstro del script
-U Indicas el usuario con el que te vas a conectas 
-o se guarda en un archivo como lgo toda la salida que se va ejecutar



```
