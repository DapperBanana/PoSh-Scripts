#Ask the user for file location
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Documents (*.csv)|*.csv'
}
$null = $FileBrowser.ShowDialog()

$FullList = Import-Csv -Path $FileBrowser.FileName
$FullList | ForEach-Object{
    $User = Get-ADUser $_.UserID -Properties telephoneNumber,ipPhone
    $User.telephoneNumber = $_.FullPhone
    $User.ipPhone = $_.DID
    Set-ADUser -Instance $User
}
