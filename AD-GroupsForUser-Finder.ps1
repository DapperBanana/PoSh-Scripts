<#
.SYNOPSIS
    Compares txt file with AD to find groups the user is in
.DESCRIPTION
    Cross checks a desired txt file against a list of all AD users in the users OU as well as Terminations to check for which groups they are in and outputs this to a CSV
.NOTES
  Version:        1.0
  Author:         Captain Howard
  Creation Date:  1/22/2020
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
$outlist = foreach($user in $textfilearray){

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
