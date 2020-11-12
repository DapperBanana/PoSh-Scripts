<#
.SYNOPSIS
    Helps to clean up Zoom licenses
.DESCRIPTION
    Cross checks a desired txt file against a list of all AD users in the users OU as well as Terminations to check for any disabled users that are in the list and outputs that into a txt file in the same location at the file_append_output
.NOTES
  Version:        1.0
  Author:         Captain Howard
  Creation Date:  12/18/19
  Purpose/Change: Production 

#>

#setup
Add-Type -AssemblyName System.Windows.Forms
$numberofusers = 0

#Ask the user for file location
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Documents (*.txt)|*.txt'
}
$null = $FileBrowser.ShowDialog()

#Load in array from text file
$textfilearray = Get-Content -Path $FileBrowser.FileName

#In order to check we want to print out the values
foreach($user in $textfilearray){

    # This all depends on how your data is formatted... For the lists I'm given I need to split based on common value
    $username = $user -split ('@')

    #For troubleshooting
    #Write-Host $username[0]

    if ($username[0] -like '*.*'){
        # This all depends on how your data is formatted... For the lists I'm given I need to split based on common value
        $tempuser = $username[0].split('.')
        $s = [string]$tempuser

        $state = Get-ADUser -Filter 'Name -like $s' -Properties * | Select-Object Enabled
    }
    else {
        $state = Get-ADUser -Identity $username[0] -Properties * | Select-Object Enabled
    }

    # This all depends on how your data is formatted... For the lists I'm given I need to split based on common values
    $state = $state -split ('=')
    $state = $state -split ('}')
    
    #For troubleshooting
    #write-host $state[1]

    if ($state[1] -like "False"){
        $numberofusers = $numberofusers + 1
        Write-Host $username[0]

        #For troubleshooting
        #write-host $state[1]
    }
    

}
write-host "Total Number of users is" $numberofusers
