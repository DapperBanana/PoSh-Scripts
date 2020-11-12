<#
.SYNOPSIS
  Restricts Room Booking to an AD Security Group
.DESCRIPTION
  Asks user for the desired room to restrict, the name of the new AD security group to create, a user to put into that group, and then completes the tasks.
  If you're wanting to input a large number of users into an AD Security group, I have other scripts to do that.  
.NOTES
  Version:        1.0
  Author:         Captain Howard
  Creation Date:  11/11/10
  Purpose/Change: Production 

#>

#Setup
$RestrictRoom = Read-Host -Prompt "Input the target meeting room to restrict"
$ADGroup = Read-Host -Prompt "Input the New AD Security Group"
$InitialUser = Read-Host -Prompt "Input the initial UPN for this group"


$group = New-DistributionGroup $ADGroup
$member = $InitialUser | Get-Mailbox
Add-DistributionGroupMember -Identity $group -Members $member -BypassSecurityGroupManagerCheck:$true
Set-CalendarProcessing -Identity $RestrictRoom -AutomateProcessing AutoAccept -BookInPolicy $group -AllBookInPolicy $false
