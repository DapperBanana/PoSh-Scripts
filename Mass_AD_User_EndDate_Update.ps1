<#
.SYNOPSIS
    Updates AD users with new end-dates as specified by a .csv
.DESCRIPTION
    Grabs a list of users stored in a .csv file and updates their end dates with the given end dates.
.NOTES
  Version:        1.0
  Author:         Captain Howard
  Creation Date:  12/23/2020
  Purpose/Change: Production 
#>

#setup
Add-Type -AssemblyName System.Windows.Forms
$numberofusers = 0

#Ask the user for file location
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Documents (*.csv)|*.csv'
}
$null = $FileBrowser.ShowDialog()

#Load in array from csv file
$textfilearray = Get-Content -Path $FileBrowser.FileName

#In order to check we want to print out the values
$outlist = foreach($item in $textfilearray){

    #This just splits the UPN for the User's name
    $username = $user -split ('@')
    
    $s = $username[0]
    $s1 = "No Group"
    $var1 = Get-ADUser -Identity $s -Properties *
    $var2 = $var1.MemberOf | Get-ADGroup | select name 
    foreach($item in $var2){
        #This is the standard section that just grabs all groups for the users in the list
        if($item){
            
            #gets out all of the gross AD formatting before throwing it into the 
            $item = $item -split ('=')
            $item = $item -split ('}')
            
            $s1 = [string]$item[1]
            break
        }
        else{
            $s1 = "No Group"
        }

        <#
        .This is for an optional "Find all groups that have this phrasing" section that you can add in
        .Obviously this would be able to be updated by entering a search param in the beginning specified by the tech instead of hardcording it but... I'm lazy and so are you if you're copying the code in here bahaha, so... There's plenty of times I do this in other scripts, you can copy it from one of those.
        if($item -like '*searchstring*'){
            
            #gets out all of the gross AD formatting before throwing it into the 
            $item = $item -split ('=')
            $item = $item -split ('}')
            
            $s1 = [string]$item[1]
            break
        }
        else{
            $s1 = "No Group"
        }
        #>
    }
    New-Object PSObject -Property @{
        Username = $s
        Group = $s1
    }
    $numberofusers = $numberofusers + 1
}
write-host "Total Number of users is" $numberofusers

#Once again, you can change this to have a prompt for the tech if you wish. I don't change location enough to not have a hardcoded location.
$outlist | Export-Csv C:\temp\output.csv