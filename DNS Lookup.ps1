function Get-MACVendor($macAddress, $maxRetries = 6) {
    $retryCount = 0

    do {
        $apiUrl = "https://api.maclookup.app/v2/macs/$macAddress"

        try {
            Start-Sleep -Milliseconds 500
            $vendorInfo = Invoke-RestMethod -Uri $apiUrl -Method Get
            if ($vendorInfo.found) {
                return $vendorInfo.company
            }
        } catch {
            Write-Host "Failed to retrieve vendor information for MAC address: $macAddress"
        }

        $retryCount++
        
    } while ($retryCount -lt $maxRetries)

    return "Unknown"
}

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "LAN Device Search"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "Do you want to start the device search over LAN?"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(20, 20)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$okButton.Location = New-Object System.Drawing.Point(50, 100)
$okButton.Add_Click({

    $lanIpAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias (Get-NetConnectionProfile).InterfaceAlias | Where-Object { $_.AddressFamily -eq 'IPv4' }).IPAddress

    $strippedLanIP = $lanIpAddress -replace '\.\d+$'

    $subnet = $strippedLanIP.TrimEnd('.') + "."

    $form.Close()

    $progressFormPing = New-Object System.Windows.Forms.Form
    $progressFormPing.Text = "Ping Progress"
    $progressFormPing.Size = New-Object System.Drawing.Size(400, 120)
    $progressFormPing.StartPosition = "CenterScreen"

    $progressLabelPing = New-Object System.Windows.Forms.Label
    $progressLabelPing.Text = "Running ping..."
    $progressLabelPing.AutoSize = $true
    $progressLabelPing.Location = New-Object System.Drawing.Point(20, 20)

    $progressBarPing = New-Object System.Windows.Forms.ProgressBar
    $progressBarPing.Style = 'Continuous'
    $progressBarPing.Minimum = 1
    $progressBarPing.Maximum = 509
    $progressBarPing.Location = New-Object System.Drawing.Point(20, 50)

    $progressFormPing.Controls.Add($progressLabelPing)
    $progressFormPing.Controls.Add($progressBarPing)

    $progressFormPing.Show()

    1..254 | ForEach-Object {
        $progressBarPing.Value = $_
        $progressFormPing.Refresh()

        Start-Process -WindowStyle Hidden ping.exe -ArgumentList "-n 1  -l 0 -f -i 2 -w 1 -4 $subnet$_"
    }

    $computers =(arp.exe -a | Select-String "$Subnet.*dynam") -replace ' +',','|
        ConvertFrom-Csv -Header Compuername,IPv4,MAC,x,Vendor|
        ForEach-Object {
            $progressBarPing.Value++
            $progressFormPing.Refresh()
            $_.Vendor = Get-MACVendor $_.MAC
            $_
        } | Select-Object Computername, IPv4, MAC, Vendor

    $progressBarPing.Value++
    $progressFormPing.Refresh()

    $progressFormPing.Close()

    $progressFormNSLookup = New-Object System.Windows.Forms.Form
    $progressFormNSLookup.Text = "NSLookup Progress"
    $progressFormNSLookup.Size = New-Object System.Drawing.Size(400, 120)
    $progressFormNSLookup.StartPosition = "CenterScreen"

    $progressLabelNSLookup = New-Object System.Windows.Forms.Label
    $progressLabelNSLookup.Text = "Running arp + nslookup..."
    $progressLabelNSLookup.AutoSize = $true
    $progressLabelNSLookup.Location = New-Object System.Drawing.Point(20, 20)

    $progressBarNSLookup = New-Object System.Windows.Forms.ProgressBar
    $progressBarNSLookup.Style = 'Continuous'
    $progressBarNSLookup.Minimum = 1
    $progressBarNSLookup.Maximum = $computers.length + 1
    $progressBarNSLookup.Location = New-Object System.Drawing.Point(20, 50)

    $progressFormNSLookup.Controls.Add($progressLabelNSLookup)
    $progressFormNSLookup.Controls.Add($progressBarNSLookup)

    $progressFormNSLookup.Show()

    foreach ($computer in $computers) {
        $progressBarNSLookup.Value++
        $progressFormNSLookup.Refresh()

        
        try{
            $result = nslookup $computer.IPv4 2>$null | Select-String -Pattern "^Name:\s+([^\.]+).*$"
        }
        catch{
            $result = false
        }
        if ($result) {
            $computer.Computername = $result.Matches.Groups[1].Value
        } else {
            $nbtstatResult = nbtstat -A $computer.IPv4 | Select-String -Pattern "^\s*([^\s]+)\s+<00+>\s+UNIQUE.*$"
            if ($nbtstatResult) {
                $computer.Computername = $nbtstatResult.Matches.Groups[1].Value
            }
        }
    }

    $progressFormNSLookup.Close()

    $computers | Out-GridView
})

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$cancelButton.Location = New-Object System.Drawing.Point(150, 100)

$form.Controls.Add($label)
$form.Controls.Add($okButton)
$form.Controls.Add($cancelButton)

$result = $form.ShowDialog()

$form.Dispose()