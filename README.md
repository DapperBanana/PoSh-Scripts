# ActiveDirectory-PoSh-Scripts
The intent is to gather together a few of my common PoSh scripts that I use in conjunction with generic Active Directory tasks.

AD-telephone-sync.ps1
---------------------
This script is intended for techs to mass upload telephone numbers to Active Directory

ZoomTXT-AD-Compare.ps1
----------------------
For those times you are running low on Zoom licenses and needing to check and see how many terminated users you having wasting your licenses

Create-Restricted-Room.ps1
--------------------------
When you're needing to create a restricted meeting room for a breakout room, executive, or otherwise. This allows you to specify the room, create an AD Security group, and add an initial member

AD-GroupsForUser-Finder.ps1
---------------------------
Locate a text file on your computer full of users e-mails and strip the e-mail to find the username in order to output a csv of all of the groups the users in that list are a part of

Mass_AD_User_EndDate_Update.ps1
------------------------------
Grabs a list of users stored in a .csv file and updates their end dates with the given end dates.


# Networking-PoSh-Scripts
The intent is to gather together a few of my common PoSh scripts that I use in conjunction with generic Networking tasks.

Get-Devices-on-LAN.ps1
---------------------
Grabs all hostnames,IPs,MACs, and vendor names of devices currently on your /24 subnet

UpdateGoDaddyDNS.ps1
---------------------
Toss your domain name, API key information, and hit enter. This goes through and updates the A type @ records of your domains DNS so that you don't need a DDNS service to CNAME to. Keeps things clean.
