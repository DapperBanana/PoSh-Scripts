<#
.SYNOPSIS
  Updates AD Users Telephone #'s
.DESCRIPTION
  Asks for a CSV that includes the headings of FullPhone (users full telephone number), DID (4 digit extension), and UserID (UPN) then automatically goes through and updates their AD accounts with the relevant information.  
.NOTES
  Version:        1.0
  Author:         Captain Howard
  Creation Date:  11/11/20
  Purpose/Change: Production 

#>

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
