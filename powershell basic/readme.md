

podemos aprender hacer script para sql basico en powershell

# Abrir powershell desde ejecutar 
	powershell_ise

### Forma #1  de conexión usando clase SqlConnection
script utiliza la clase SqlConnection de .NET Framework y no de un módulo específico de PowerShell, que permite establecer una conexión con una base de datos SQL Server

### Forma #2  de conexión usando Module SqlServer
El comando Import-Module SqlServer se utiliza para importar el módulo de PowerShell SqlServer como  Invoke-Sqlcmd, que proporciona cmdlets adicionales para trabajar con SQL Server. Este módulo facilita la ejecución de comandos y la administración de SQL Server directamente desde PowerShell 



### **cmdlets** 
(pronunciado "command-lets") son comandos específicos de PowerShell diseñados para realizar tareas particulares. Aquí tienes una explicación más detallada:

### ¿Qué son los cmdlets?

1. **Cmdlets**:
   - Son comandos ligeros que se ejecutan en el entorno de PowerShell.
   - Están diseñados para realizar tareas específicas, como administrar sistemas, ejecutar scripts, y manipular datos.
   - Cada cmdlet sigue una convención de nomenclatura `Verbo-Sustantivo`, como `Get-Process` o `Invoke-Sqlcmd`.

### Ejemplos de cmdlets:

1. **`Get-Process`**:
   - Obtiene información sobre los procesos en ejecución en el sistema.
   - Ejemplo: `Get-Process`

2. **`Invoke-Sqlcmd`**:
   - Ejecuta consultas SQL y comandos en un servidor SQL.
   - Ejemplo: `Invoke-Sqlcmd -Query "SELECT @@VERSION" -ServerInstance "tu_servidor"`

3. **`Get-Content`**:
   - Lee el contenido de un archivo.
   - Ejemplo: `Get-Content -Path "ruta_a_tu_archivo.txt"`



### Ver todos los módulos disponibles:
	Get-Module -ListAvailable

### Buscar un modulo:
	Get-Command -Name Invoke-Sqlcmd

### Para verificar clases disponibles en un módulo específico:
	Get-Module -Name Get-Content | Select-Object -ExpandProperty ExportedClasses

### Para buscar una clase específica:
	Get-TypeData -TypeName System.Data.SqlClient.SqlConnection

### Verificar si tienes la clase SqlConnection:
	[System.Data.SqlClient.SqlConnection]

### Instalar el módulo SqlServer
Install-Module -Name SqlServer -Scope CurrentUser

### Verificar comando Invoke-Sqlcmd
```
if (Get-Command -Name Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
    Write-Host "Invoke-Sqlcmd está disponible."
} else {
    Write-Host "Invoke-Sqlcmd no está disponible."
}
```

```
https://medium.com/@rivera5656/connect-and-query-a-sql-server-database-from-powershell-f264e73941f5
https://www.sqlshack.com/connecting-powershell-to-sql-server/
https://www.sqlshack.com/connecting-powershell-to-sql-server-using-a-different-account/
https://www.itprotoday.com/powershell/how-to-connect-to-sql-server-database-from-powershell
https://blogvisionarios.com/articulos-data/powershell-y-sqlbi-ejecucin-de-consultas-sql/
```
