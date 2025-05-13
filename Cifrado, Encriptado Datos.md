
### ¿Qué técnicas se pueden usar para cifrar datos en reposo?
"En reposo" significa que los datos están almacenados (no en tránsito ni en uso). Por ejemplo: en discos duros, SSDs, backups, bases de datos, etc.


Hay varias, y la elección depende del sistema y del nivel de seguridad requerido. Algunas técnicas comunes incluyen:

1. **Cifrado a nivel de disco**  
   - Ejemplo: BitLocker (Windows), LUKS (Linux).
   - Cifra todo el disco físico.
   - Transparente para las aplicaciones.

2. **Cifrado a nivel de archivo o carpeta**  
   - Ejemplo: EFS (Encrypting File System) en Windows.
   - Cifra archivos individuales o carpetas.

3. **Cifrado a nivel de base de datos**  
   - Ejemplo: Transparent Data Encryption (TDE) en SQL Server.
   - Cifra los archivos de base de datos (.mdf, .ldf) en disco.

4. **Cifrado a nivel de columna o campo**  
   - Ejemplo: Always Encrypted o Column-Level Encryption en SQL Server.
   - Cifra datos específicos dentro de la base de datos.
 
