# update-dns
Scripting to update my home DNS records in AWS Route53 due to dynamic WAN IP changes. Poor man's dynamic dns updater.

- Needs AWS authentication setup before running. I use an AWS IAM User with API credentials.
- Need to have the AWSPowerShell.NetCore module installed. If any other AWS tools module is to be used, modify the script to import that version (such as AWSPowerShell.Tools.* modular versions).
(`Install-Module AWSPowerShell.Netcore`)

## usage
1. Copy the script (script/check-my-ip.ps1) to a local folder `C:\<checkmyip-folder>\`.
1. Edit the script, changing all `<parameters>` as needed.
1. From a PowerShell prompt, simply run the script.
`C:\<checkmyip-folder>\check-my-ip.ps1`

## to setup as a scheduled task (cron)
Update all `<parameters>` and run:

```
$action = (New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\<check-my-ip-folder>\check-my-ip.ps1" -WorkingDirectory "C:\<check-my-ip-folder>\" -AsJob)
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddHours(2) -RepetitionInterval (New-TimeSpan -Minutes 30) -RepetitionDuration (New-TimeSpan -Days 999)
$principal = New-ScheduledTaskPrincipal -UserId '<username>'
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -WakeToRun
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings

Register-ScheduledTask 'CheckMyIP-Every30Min' -InputObject $task
```

Note: Must be an administrative user for `<username>`. In order to allow the Task to run when not logged in, must enter the password for the user after Task creation.