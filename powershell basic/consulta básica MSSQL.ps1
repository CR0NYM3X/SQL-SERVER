clear
 # Solicitar las credenciales al usuario desde una ventana de windows esto evita exponer las credenciales 
# Nombre de usuario predeterminado
$usuarioPredeterminado = "usuario_predeterminado"

# Solicitar el nombre de usuario con un valor predeterminado
$usuario = Read-Host "Ingrese el nombre de usuario de lo contrario presionar ENTER (predeterminado: $usuarioPredeterminado)"
if ([string]::IsNullOrWhiteSpace($usuario)) {
    $usuario = $usuarioPredeterminado
}else {
	$usuario = $usuario
}

Add-Type -AssemblyName System.Windows.Forms

# Crear el cuadro de diálogo
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ingrese la contraseña"
$form.Width = 400
$form.Height = 150

# Crear el cuadro de texto
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Width = 350
$textBox.Top = 20
$textBox.Left = 20
$textBox.UseSystemPasswordChar = $true
$form.Controls.Add($textBox)

# Crear el botón de aceptar
$buttonOK = New-Object System.Windows.Forms.Button
$buttonOK.Text = "Aceptar"
$buttonOK.Top = 60
$buttonOK.Left = 150
$buttonOK.Add_Click({
    $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Close()
})
$form.Controls.Add($buttonOK)

# Mostrar el cuadro de diálogo
$result = $form.ShowDialog()

# Obtener la contraseña
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $contraseña = $textBox.Text
    #Write-Host "Contraseña ingresada: $contraseña"
} else {
    Write-Host "Operación cancelada."
}


# Definir el servidor y la base de datos
$servidor = "192.168.1.100"
$puerto = "1433"
$baseDeDatos = "master"

# Crear la cadena de conexión
$connectionString = "Server=$servidor,$puerto;Database=$baseDeDatos;User Id=$usuario;Password=$contraseña"

# Crear la consulta SQL
$query = "SELECT @@VERSION"

# Ejecutar la consulta SQL
try {
    # Crear una nueva conexión SQL
    $connection = New-Object System.Data.SqlClient.SqlConnection
    
    # Establecer la cadena de conexión para la conexión SQL
    $connection.ConnectionString = $connectionString
    
    # Abrir la conexión al servidor SQL
    $connection.Open()

    # Crear un comando SQL utilizando la conexión abierta
    $command = $connection.CreateCommand()
    
    # Establecer el texto del comando como la consulta SQL definida anteriormente
    $command.CommandText = $query
    
    # Ejecutar el comando y obtener un lector de datos (SqlDataReader) para leer los resultados
    $reader = $command.ExecuteReader()

   
    # Ejecutar el comando, se usa este en caso de unicamente ejecutar algo que no esperara resultados 
    #$command.ExecuteNonQuery()

    # Leer los resultados de la consulta
    while ($reader.Read()) {
        # Imprimir el primer campo de cada fila (que en este caso es la versión del servidor SQL)
        Write-Output $reader[0]
    }

    # Cerrar la conexión al servidor SQL
    $connection.Close()
} catch {
    # Capturar cualquier error que ocurra durante la ejecución de la consulta y imprimirlo
    Write-Output "Error: $_"
}


 
