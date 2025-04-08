#  _   _           _                         
# | | | | __ _ ___| |__                      
# | |_| |/ _` / __| '_ \                     
# |  _  | (_| \__ \ | | |                    
# |_| |_|\__,_|___/_| |_|      _             
# \ \   / /_ _| (_) __| | __ _| |_ ___  _ __ 
#  \ \ / / _` | | |/ _` |/ _` | __/ _ \| '__|
#   \ V / (_| | | | (_| | (_| | || (_) | |   
#    \_/ \__,_|_|_|\__,_|\__,_|\__\___/|_|   
#  by LRuiz


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Security

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Hash Validator by L.Ruiz"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.StartPosition = "CenterScreen"

# Title label at the top center
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Hash Validator"
$titleLabel.Font = New-Object System.Drawing.Font("Impact", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(55, 150, 0)  # Blue color for the text
$titleLabel.Size = New-Object System.Drawing.Size(250, 30)

# Center the title horizontally
$titleLabel.Location = New-Object System.Drawing.Point(120, 10)
$form.Controls.Add($titleLabel)

# Browse button to select the file
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Size = New-Object System.Drawing.Size(75, 23)
$browseButton.Location = New-Object System.Drawing.Point(10, 40)
$form.Controls.Add($browseButton)

# Text box to display the selected file path
$filePathTextBox = New-Object System.Windows.Forms.TextBox
$filePathTextBox.Size = New-Object System.Drawing.Size(260, 20)
$filePathTextBox.Location = New-Object System.Drawing.Point(95, 40)
$filePathTextBox.ReadOnly = $true
$form.Controls.Add($filePathTextBox)

# Label for the Original Hash text box
$checksumLabel = New-Object System.Windows.Forms.Label
$checksumLabel.Text = "Paste Original Hash"
$checksumLabel.Location = New-Object System.Drawing.Point(10, 80)
$checksumLabel.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($checksumLabel)

# Input Text box for the user to enter the hash to compare
$hashTextBox = New-Object System.Windows.Forms.TextBox
$hashTextBox.Size = New-Object System.Drawing.Size(260, 20)
$hashTextBox.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($hashTextBox)

# Button to run hash validation
$validateButton = New-Object System.Windows.Forms.Button
$validateButton.Text = "Validate Hash"
$validateButton.Size = New-Object System.Drawing.Size(100, 23)
$validateButton.Location = New-Object System.Drawing.Point(10, 130)
$form.Controls.Add($validateButton)

# Label for Instructions
$checksumLabel = New-Object System.Windows.Forms.Label
$checksumLabel.Text = "Instructions:`n`n1. Browse for the downloaded file`n`n2. Copy/Paste the Original Hash (Provided by Vendor)`n`n3. Click Validate Hash"
$checksumLabel.Location = New-Object System.Drawing.Point(10, 180)
$checksumLabel.Size = New-Object System.Drawing.Size(400, 400)
$form.Controls.Add($checksumLabel)

# Define the browse button click event
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "All Files (*.*)|*.*"
    $openFileDialog.Title = "Select a File"
    
    # Show the dialog and get the file path
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $filePathTextBox.Text = $openFileDialog.FileName
    }
})

# Define the validate button click event
$validateButton.Add_Click({
    $filePath = $filePathTextBox.Text
    $expectedHash = $hashTextBox.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($filePath) -or [string]::IsNullOrWhiteSpace($expectedHash)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a file and enter a hash to validate.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Calculate the file hash
    try {
        $fileStream = [System.IO.File]::OpenRead($filePath)
        $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
        $fileHashBytes = $hashAlgorithm.ComputeHash($fileStream)
        $fileStream.Close()

        $fileHash = [BitConverter]::ToString($fileHashBytes) -replace '-'
        
        # Compare the file hash with the user-entered hash
        if ($fileHash -eq $expectedHash) {
            [System.Windows.Forms.MessageBox]::Show("Hashes match!", "Validation Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            [System.Windows.Forms.MessageBox]::Show("Hashes do not match!", "Validation Failed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error reading the file. Please ensure the file is accessible.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
