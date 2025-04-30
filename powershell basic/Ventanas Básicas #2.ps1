Add-Type -AssemblyName System.Windows.Forms

# Función para crear la nueva ventana
function Show-NewWindow {
    $newForm = New-Object System.Windows.Forms.Form
    $newForm.Text = "Nueva Ventana"
    $newForm.Width = 400
    $newForm.Height = 300
    $newForm.BackColor = [System.Drawing.Color]::LightSteelBlue
    $newForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "¡Esta es una nueva ventana!"
    $label.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::Black
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(100, 100)

    $newForm.Controls.Add($label)
    $newForm.ShowDialog()
}

# Crear la ventana principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ventana Demostrativa"
$form.Width = 800
$form.Height = 800
$form.BackColor = [System.Drawing.Color]::DarkSlateBlue
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Crear un título llamativo
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "¡Bienvenido a la Ventana Demostrativa!"
$titleLabel.Font = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(150, 20)

# Crear un cuadro de texto decorativo
$decorativeTextBox = New-Object System.Windows.Forms.TextBox
$decorativeTextBox.Multiline = $true
$decorativeTextBox.Width = 600
$decorativeTextBox.Height = 200
$decorativeTextBox.Text = "Este es un cuadro de texto decorativo. No realiza ninguna acción."
$decorativeTextBox.Font = New-Object System.Drawing.Font("Arial", 16)
$decorativeTextBox.ForeColor = [System.Drawing.Color]::White
$decorativeTextBox.BackColor = [System.Drawing.Color]::MidnightBlue
$decorativeTextBox.Location = New-Object System.Drawing.Point(100, 70)

# Crear un botón decorativo
$decorativeButton = New-Object System.Windows.Forms.Button
$decorativeButton.Text = "Botón Decorativo"
$decorativeButton.Font = New-Object System.Drawing.Font("Arial", 16)
$decorativeButton.ForeColor = [System.Drawing.Color]::White
$decorativeButton.BackColor = [System.Drawing.Color]::RoyalBlue
$decorativeButton.Width = 200
$decorativeButton.Height = 50
$decorativeButton.Location = New-Object System.Drawing.Point(300, 290)

# Crear una barra de progreso
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Width = 600
$progressBar.Height = 30
$progressBar.Location = New-Object System.Drawing.Point(100, 360)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$progressBar.Value = 50

# Crear una imagen
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Width = 100
$pictureBox.Height = 100
$pictureBox.Location = New-Object System.Drawing.Point(350, 400)
$pictureBox.ImageLocation = "https://via.placeholder.com/100"  # URL de una imagen de ejemplo
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage

# Crear un checkbox
$checkBox = New-Object System.Windows.Forms.CheckBox
$checkBox.Text = "Opción Decorativa"
$checkBox.Font = New-Object System.Drawing.Font("Arial", 12)
$checkBox.ForeColor = [System.Drawing.Color]::White
$checkBox.Location = New-Object System.Drawing.Point(100, 520)

# Crear un radio button
$radioButton = New-Object System.Windows.Forms.RadioButton
$radioButton.Text = "Selección Decorativa"
$radioButton.Font = New-Object System.Drawing.Font("Arial", 12)
$radioButton.ForeColor = [System.Drawing.Color]::White
$radioButton.Location = New-Object System.Drawing.Point(100, 550)

# Crear una lista desplegable (ComboBox)
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Items.AddRange(@("Opción 1", "Opción 2", "Opción 3"))
$comboBox.Location = New-Object System.Drawing.Point(100, 580)
$comboBox.Width = 200

# Crear un control de fecha (DateTimePicker)
$dateTimePicker = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker.Location = New-Object System.Drawing.Point(320, 580)
$dateTimePicker.Width = 200

# Crear un control de pestañas (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Width = 600
$tabControl.Height = 100
$tabControl.Location = New-Object System.Drawing.Point(100, 620)

# Crear las pestañas
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Pestaña 1"
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Pestaña 2"

# Agregar pestañas al control de pestañas
$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)

# Crear el botón para abrir una nueva ventana
$buttonNewWindow = New-Object System.Windows.Forms.Button
$buttonNewWindow.Text = "Abrir Nueva Ventana"
$buttonNewWindow.Font = New-Object System.Drawing.Font("Arial", 16)
$buttonNewWindow.ForeColor = [System.Drawing.Color]::White
$buttonNewWindow.BackColor = [System.Drawing.Color]::RoyalBlue
$buttonNewWindow.Width = 200
$buttonNewWindow.Height = 50
$buttonNewWindow.Location = New-Object System.Drawing.Point(300, 650)

# Agregar el evento de clic del botón para abrir una nueva ventana
$buttonNewWindow.Add_Click({
    Show-NewWindow
})

# Agregar controles a la ventana
$form.Controls.Add($titleLabel)
$form.Controls.Add($decorativeTextBox)
$form.Controls.Add($decorativeButton)
$form.Controls.Add($progressBar)
$form.Controls.Add($pictureBox)
$form.Controls.Add($checkBox)
$form.Controls.Add($radioButton)
$form.Controls.Add($comboBox)
$form.Controls.Add($dateTimePicker)
$form.Controls.Add($tabControl)
$form.Controls.Add($buttonNewWindow)

# Mostrar la ventana
$form.ShowDialog()
