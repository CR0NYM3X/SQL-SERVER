

### ExecuteNonQuery() 
se utiliza para ejecutar comandos SQL que no devuelven resultados, como INSERT, UPDATE, DELETE, y CREATE. Aquí tienes un ejemplo:

### ExecuteReader() 
se utiliza para ejecutar comandos SQL que devuelven resultados, como SELECT. Aquí tienes un ejemplo:




# Ejemplos para ejecutar procedimientos 
```
# especificar el tipo de comando que estás ejecutando
$command.CommandType = [System.Data.CommandType]::StoredProcedure
<#
1. **StoredProcedure**: Para ejecutar procedimientos almacenados.
2. **Text**: Para ejecutar comandos SQL en texto plano.
3. **TableDirect**: Para acceder directamente a una tabla.
#>

$command.CommandText = "sp_addrolemember"  # Solo el nombre del procedimiento almacenado

# Agregar parámetros si es necesario
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@rolename", [System.Data.SqlDbType]::NVarChar, 128))).Value = "db_datareader"
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@membername", [System.Data.SqlDbType]::NVarChar, 128))).Value = "user_test"

### Ejecutar el comando y obtener un lector de datos (SqlDataReader) para leer los resultados
$reader = $command.ExecuteReader()

#Leer los resultados de la consulta
while ($reader.Read()) {
	# Imprimir el primer campo de cada fila (que en este caso es la versión del servidor SQL)
	Write-Output $reader[0]
}
```
