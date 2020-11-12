$FullList = Import-Csv -Path C:\Users\ahoward\phone-numbers.csv
$FullList | ForEach-Object{
    $User = Get-ADUser $_.UserID -Properties telephoneNumber,ipPhone
    $User.telephoneNumber = $_.FullPhone
    $User.ipPhone = $_.DID
    Set-ADUser -Instance $User
}
