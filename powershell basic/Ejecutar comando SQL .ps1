clear

# Definir las rutas de los archivos
$inputFilePath =  "C:\Users\user_local\Desktop\Execute script masivo SQL Server\ips.txt"
$outputFilePath = "C:\Users\user_local\Desktop\Execute script masivo SQL Server\output.txt"

# Leer las direcciones IP desde el archivo de entrada
$ipList = Get-Content -Path $inputFilePath


# Obtener las credenciales del usuario
$credenciales = Get-Credential

# Verificar si se ingresaron las credenciales
if ($credenciales -eq $null -or $credenciales.UserName -eq "" -or $credenciales.Password -eq $null) {
    Write-Host "No se ingresaron credenciales. Terminando la ejecución." -ForegroundColor Red
    exit
}

clear
$contraseña = $credenciales.GetNetworkCredential().Password
$part1_user = $credenciales.UserName
$part2_user = ''
$part3_user = ''
$user_final = ''

# Definir el servidor y la base de datos
$servidor = "cpl.mssql.cyberark.cloud"
$puerto = "1433"
$baseDeDatos = "master"
$query =  "ALTER ROLE [db_datareader] ADD MEMBER user_test;"


# Crear una nueva conexión SQL
$connection = New-Object System.Data.SqlClient.SqlConnection

# Recorrer cada IP
foreach ($ip in $ipList) {

    try {
		
		# Si quieres hacer un sleep
		#Start-Sleep -Seconds 5
	
        # Guardar la fecha y hora de inicio
        $startTime = Get-Date

        # Usar expresión regular para eliminar caracteres especiales y dejar solo números y puntos
        $ip_clean = $ip -replace '[^0-9.]', ''

        Write-Host " Conectando a IP: " -NoNewline
        Write-Host "$ip_clean " -NoNewline -ForegroundColor DarkYellow 

        # Juntando el usuario ejemplo : jose.pedro@dominio.cloud#cpl@admin_user@192.168.1.100#network_name
        $user_final = "$part1_user$part2_user$ip_clean$part4_user"

        #Write-Host "Trabajando con la $user_final  " -ForegroundColor Yellow  

    
        # Crear la cadena de conexión
        $connectionString = "Server=$servidor,$puerto;Database=$baseDeDatos;User Id=$user_final;Password=$contraseña" # ,Encrypt=True;TrustServerCertificate=True;


        # Establecer la cadena de conexión para la conexión SQL
        $connection.ConnectionString = $connectionString
    
        # Abrir la conexión al servidor SQL
        $connection.Open()

        # Crear un comando SQL utilizando la conexión abierta
        $command = $connection.CreateCommand()

        # Establecer el texto del comando como la consulta SQL definida anteriormente
        $command.CommandText =  $query


        # Ejecutar la query y no imprima nada
        $null = $command.ExecuteNonQuery()

        # Guardar la fecha y hora de finalización
        $endTime = Get-Date
    
        # Calcular el tiempo transcurrido
        $executionTime = $endTime - $startTime
       
        # Imprimir resultados
        Write-Host "- Status : " -NoNewline
        Write-Host "successful" -ForegroundColor Green -NoNewline
        Write-Host " - Tiempo Ejecución : $executionTime"

        Add-Content -Path $outputFilePath -Value "StartTime: $startTime - IP: $ip_clean - Status: successful - ExecuteTime: $executionTime"  



    } catch {
        # Capturar cualquier error que ocurra durante la ejecución de la consulta y imprimirlo
    
        # Guardar la fecha y hora de finalización
        $endTime = Get-Date

        # Calcular el tiempo transcurrido
        $executionTime = $endTime - $startTime

        # Imprimir resultados
        Write-Host "- Status : " -NoNewline
        Write-Host "failed" -ForegroundColor Red -NoNewline
        Write-Host " - Tiempo Ejecución : $executionTime"  -NoNewline
        Write-Host " - MSG Error: $_" -ForegroundColor Yellow
        Add-Content -Path $outputFilePath -Value "StartTime: $startTime - IP: $ip_clean - Status: failed - ExecuteTime: $executionTime - MSG Error: $_" 

    }  finally {
        # Cerrar la conexión
        $connection.Close()
        $ip = $null
    }


}
$ipList = $null

