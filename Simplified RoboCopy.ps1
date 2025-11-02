<#
.SYNOPSIS
  Robocopy with simplified GUI, for copying files and folders.

.DESCRIPTION
  Displays Robocopy with a graphical overlay that makes it easier to use switches and commands for copying files and folders.

.PARAMETER Path
  No parameters supported.

.NOTES
  Author:       Brian Hansen
  Created on:   19-10-2025
  Version:      1.1

  PowerShell Execution Policy must be disabled for the script to run.
  Administrator privileges are required to copy protected files and folders.
  If needed, insert more command line switches below line 31.
#>


Add-Type -AssemblyName System.Windows.Forms

# Robocopy switches (most common - Add more as needed)
$switches = @(
    @{Name="/E"; Description="Copy all subdirectories, including empty ones"; Checked=$true},
    @{Name="/S"; Description="Copy subdirectories, excluding empty ones"; Checked=$false},
    @{Name="/COPYALL"; Description="Copy all file attributes"; Checked=$false},
    @{Name="/MOVE"; Description="Move files and folders (delete from source)"; Checked=$false},
    @{Name="/PURGE"; Description="Delete destination files/folders not present in source"; Checked=$false},
    @{Name="/MIR"; Description="Mirror source to destination (including deletions)"; Checked=$false},
    @{Name="/SEC"; Description="Copy security (NTFS ACLs)"; Checked=$false},
    @{Name="/Z"; Description="Resume copying after interruption"; Checked=$true},
    @{Name="/R:0"; Description="No retries on failed copies"; Checked=$true},
    @{Name="/W:0"; Description="No wait time between retries"; Checked=$true}
)

# Dynamic form height dependent on number of switches (extra space to footer)
$formHeight = 230 + $switches.Count*25 + 60 + 30 + 80   # output, run-btn, footer, extra to browse-buttons
if ($formHeight -lt 750) { $formHeight = 680 }

$form = New-Object System.Windows.Forms.Form
$form.Text = "Simplified Robocopy - Copy files and folders"
$form.Size = New-Object System.Drawing.Size(600, $formHeight)
$form.StartPosition = "CenterScreen"
$form.ShowIcon = $false # Remove form icon
$form.MaximizeBox = $false # Remove maximize button
$form.FormBorderStyle = 'FixedDialog' # Fixed size

# ToolTip component
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.AutoPopDelay = 10000
$toolTip.InitialDelay = 500
$toolTip.ReshowDelay = 100

# Source
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "Source:"
$lblSource.Location = '10,20'
$lblSource.Size = '100,20'
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = '120,20'
$txtSource.Size = '350,20'
$form.Controls.Add($txtSource)

$btnBrowseSource = New-Object System.Windows.Forms.Button
$btnBrowseSource.Text = "Browse..."
$btnBrowseSource.Location = '480,18'
$btnBrowseSource.Size = '80,20'
$btnBrowseSource.Add_Click({
    $folder = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folder.ShowDialog() -eq "OK") {
        $txtSource.Text = $folder.SelectedPath
    }
})
$form.Controls.Add($btnBrowseSource)

# Destination
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "Destination:"
$lblDest.Location = '10,50'
$lblDest.Size = '100,20'
$form.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = '120,50'
$txtDest.Size = '350,20'
$form.Controls.Add($txtDest)

$btnBrowseDest = New-Object System.Windows.Forms.Button
$btnBrowseDest.Text = "Browse..."
$btnBrowseDest.Location = '480,48'
$btnBrowseDest.Size = '80,20'
$btnBrowseDest.Add_Click({
    $folder = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folder.ShowDialog() -eq "OK") {
        $txtDest.Text = $folder.SelectedPath
    }
})
$form.Controls.Add($btnBrowseDest)

# Switches
$lblSwitches = New-Object System.Windows.Forms.Label
$lblSwitches.Text = "Robocopy switches:"
$lblSwitches.Location = '10,90'
$lblSwitches.Size = '200,20'
$form.Controls.Add($lblSwitches)

$checkboxes = @()
for ($i=0; $i -lt $switches.Count; $i++) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($switches[$i].Name) - $($switches[$i].Description)"
    $cb.Location = "30,$(120 + $i*25)"
    $cb.Size = '500,22'
    $cb.Checked = $switches[$i].Checked
    $form.Controls.Add($cb)
    $checkboxes += $cb
}

# /XD (Exclude Directories) switch with text field and browse button
$xdLabelY = 120 + $switches.Count*25
$xdTextY = 145 + $switches.Count*25

$lblXD = New-Object System.Windows.Forms.Label
$lblXD.Text = "/XD - Exclude Directories (Hover to see tooltip)"
$lblXD.Location = "30,$xdLabelY"
$lblXD.Size = '470,20'
$form.Controls.Add($lblXD)
$toolTip.SetToolTip($lblXD, "Add multiple Directories seperated by Semicolon. Simple Folder names are also supported. Eg. Notes")

$txtXD = New-Object System.Windows.Forms.TextBox
$txtXD.Location = "30,$xdTextY"
$txtXD.Size = '440,20'
$form.Controls.Add($txtXD)

$btnBrowseXD = New-Object System.Windows.Forms.Button
$btnBrowseXD.Text = "Browse..."
$btnBrowseXD.Location = '480,' + $xdTextY
$btnBrowseXD.Size = '80,20'
$btnBrowseXD.Add_Click({
    $folder = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folder.ShowDialog() -eq "OK") {
        if ($txtXD.Text.Trim().Length -gt 0) {
            $txtXD.Text += ";$($folder.SelectedPath)"
        } else {
            $txtXD.Text = $folder.SelectedPath
        }
    }
})
$form.Controls.Add($btnBrowseXD)

# /XF (Exclude Files) switch with text field and browse button
$xfLabelY = 175 + $switches.Count*25
$xfTextY = 200 + $switches.Count*25

$lblXF = New-Object System.Windows.Forms.Label
$lblXF.Text = "/XF - Exclude Files (Hover to see tooltip)"
$lblXF.Location = "30,$xfLabelY"
$lblXF.Size = '470,20'
$form.Controls.Add($lblXF)
$toolTip.SetToolTip($lblXF, "Add multiple files or filetypes seperated by Semicolon. Wildcard filetypes eg. *.txt are also supported")

$txtXF = New-Object System.Windows.Forms.TextBox
$txtXF.Location = "30,$xfTextY"
$txtXF.Size = '440,20'
$form.Controls.Add($txtXF)

$btnBrowseXF = New-Object System.Windows.Forms.Button
$btnBrowseXF.Text = "Browse..."
$btnBrowseXF.Location = '480,' + $xfTextY
$btnBrowseXF.Size = '80,20'
$btnBrowseXF.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Title = "Choose file(s) to exclude"
    $ofd.Multiselect = $true
    if ($ofd.ShowDialog() -eq "OK") {
        $selected = $ofd.FileNames -join ";"
        if ($txtXF.Text.Trim().Length -gt 0) {
            $txtXF.Text += ";$selected"
        } else {
            $txtXF.Text = $selected
        }
    }
})
$form.Controls.Add($btnBrowseXF)

# Output (multiline, 3 lines high)
$outputLabelY = 230 + $switches.Count*25
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "Command:"
$lblOutput.Location = "10,$outputLabelY"
$lblOutput.Size = '100,60'
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = "110,$outputLabelY"
$txtOutput.Size = '445,60'
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.ReadOnly = $true
$form.Controls.Add($txtOutput)

# Function to build robocopy command
function Build-RobocopyCommand {
    param($src, $dst, $checkboxes, $txtXD, $txtXF)
    $selSwitches = ($checkboxes | Where-Object {$_.Checked}) | ForEach-Object {$_.Text.Split(" ")[0]}
    $cmd = "robocopy `"$src`" `"$dst`" $($selSwitches -join ' ')"
    if ($txtXD.Text -and $txtXD.Text.Trim() -ne "") {
        $xdItems = $txtXD.Text -split ';' | Where-Object { $_.Trim() -ne "" }
        if ($xdItems.Count -gt 0) {
            $cmd += " /XD"
            foreach ($item in $xdItems) {
                $cmd += " `"$($item.Trim())`""
            }
        }
    }
    if ($txtXF.Text -and $txtXF.Text.Trim() -ne "") {
        $xfItems = $txtXF.Text -split ';' | Where-Object { $_.Trim() -ne "" }
        if ($xfItems.Count -gt 0) {
            $cmd += " /XF"
            foreach ($item in $xfItems) {
                $cmd += " `"$($item.Trim())`""
            }
        }
    }
    return $cmd
}

# Function to update command field
function Update-CommandField {
    $txtOutput.Text = Build-RobocopyCommand $txtSource.Text $txtDest.Text $checkboxes $txtXD $txtXF
}

# Event handlers to update command field automatically
$txtSource.Add_TextChanged({ Update-CommandField })
$txtDest.Add_TextChanged({ Update-CommandField })
$txtXD.Add_TextChanged({ Update-CommandField })
$txtXF.Add_TextChanged({ Update-CommandField })
foreach ($cb in $checkboxes) {
    $cb.Add_CheckedChanged({ Update-CommandField })
}

# Dynamic placement of Run button under output
$runBtnY = $txtOutput.Location.Y + $txtOutput.Size.Height + 20
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Run Robocopy"
$btnRun.Size = '150,30'
$runBtnX = [Math]::Round(($form.ClientSize.Width - $btnRun.Width) / 2)
$btnRun.Location = "$runBtnX,$runBtnY"
$btnRun.Add_Click({
    $src = $txtSource.Text
    $dst = $txtDest.Text
    $cmd = Build-RobocopyCommand $src $dst $checkboxes $txtXD $txtXF
    # Tjek if both fields are populated - If not show warning and stop function
    if (-not $src -or -not $dst) {
        [System.Windows.Forms.MessageBox]::Show("Please select both source and destination folders!")
        return
    }
    # Tjek if source and destination folder exists
    if (-not [System.IO.Directory]::Exists($src)) {
        [System.Windows.Forms.MessageBox]::Show("Source folder does not exist!")
        return
    }
    if (-not [System.IO.Directory]::Exists($dst)) {
        [System.Windows.Forms.MessageBox]::Show("Destination folder does not exist!")
        return
    }
    # Tjek at source og destination ikke er ens
    if ($src -eq $dst) {
        [System.Windows.Forms.MessageBox]::Show("Source and destination folders cannot be the same!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    # Run robocopy in a cmd window
    Start-Process -FilePath "cmd.exe" -ArgumentList "/k $cmd"
})
$form.Controls.Add($btnRun)

# Footer: Only "Support me" link centered at bottom
$linkDonate = New-Object System.Windows.Forms.LinkLabel
$linkDonate.Text = "Please support my projects if you like them."
$linkDonate.Size = '250,20'
$linkDonate.TextAlign = "MiddleCenter"
$linkDonate.Font = $form.Font

# Place centered, 20 px above bottom
$footerY = $form.ClientSize.Height - $linkDonate.Height - 8
$footerX = [Math]::Round(($form.ClientSize.Width - $linkDonate.Size.Width) / 2)
$linkDonate.Location = "$footerX,$footerY"
$linkDonate.LinkColor = 'Blue'
$linkDonate.ActiveLinkColor = 'Red'
$linkDonate.Add_LinkClicked({
    Start-Process "https://www.paypal.com/donate/?hosted_button_id=LZCL2N8S4E984"
})
$form.Controls.Add($linkDonate)

# Initial fill of command field
Update-CommandField

$form.Topmost = $true
$form.ShowDialog()