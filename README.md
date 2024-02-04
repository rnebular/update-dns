# update-dns
Scripting to update my home DNS records due to dynamic WAN IP changes. Poor man's dynamic dns updater.

- Needs AWS authentication setup before running. I use an AWS IAM User with API credentials.
- Need to have the AWSPowerShell.NetCore module installed. If any other AWS tools module is to be used, modify the script to import that version.
(`Install-Module AWSPowerShell.Netcore`)

## usage
1. Copy the script (script/check-my-ip.ps1) to your local user profile folder `C:\Users\<username>\`.
1. Edit the script, changing "<username>" to an actual local user account.
1. From a PowerShell prompt, simply run the script.
`C:\Users\<username>\check-my-ip.ps1`

## to setup as a scheduled task (cron)
Update <username> and run:
```
$action = (New-ScheduledTaskAction -Execute 'C:\Users\<username>\check-my-ip.ps1')
$trigger = New-ScheduledTaskTrigger -Daily -At '4:00 AM'
$principal = New-ScheduledTaskPrincipal -UserId '<username>'
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -WakeToRun
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings

Register-ScheduledTask 'CheckMyIP-Daily-4AM' -InputObject $task
```