# Check-My-IP.ps1

# Script to get my router public IP and update my DNS records if they are different.
# Assumptions: Amazon authentication is already established,
#   Amazon provided PowerShell tools are installed (Install-Module AWSPowerShell.NetCore)
# For personal use, Authentication can be setup with an IAM user and an SSH key for API access, rotated regularly.

# To receive email notifications sent via the Send-GmailNotification function,
# the environment variables $env:EMAIL_USERNAME and $env:EMAIL_APP_PASSWORD must be set to a valid Gmail address and app password.
# REF: https://support.google.com/accounts/answer/185833?hl=en

# static variables
$RecordNames = "record1","record2","record3" #can be a single record or multiple
$zone_name = "<Zone_suffix>"
$ZONE_ID = "<Zone_ID>"
$log_file = "C:\Logs\check-my-ip.log"

# AWS tools for Powershell, full module.
# Can be changed to the `AWSPowerShell.Tools.common` and `AWSPowerShell.Tools.Route53` if desired.
Import-Module AWSPowerShell.NetCore

# Get homelab functions from github and replace if already present
if ((Test-Path -Path "source\homelab-functions-main")) {
    # folder already exists, will remove and replace to make sure it's current
    Write-Output "Homelab functions already found in source path, replacing with latest from github."
    Remove-Item -Path "source\homelab-functions-main" -Recurse -Force
} else {
    # folder not found, will download from github
    Write-Output "Homelab functions not found in source path, downloading from github."
}

# check for source folder, create if not found
if (!(Test-Path -Path "source")) {
    New-Item -ItemType Directory -Path "source"
}

# download latest homelab functions from github and unzip to source folder
$dl_path = "https://github.com/rnebular/homelab-functions/archive/refs/heads/main.zip"
$extract_path = "source"
Invoke-WebRequest -Uri $dl_path -OutFile "homelab-functions.zip"
Expand-Archive -Path "homelab-functions.zip" -DestinationPath $extract_path
Remove-Item -Path "homelab-functions.zip"

$env:PSModulePath = "$($env:PSModulePath);$(Get-Location)\source"
Import-Module -Name "homelab-functions-main\source\homelab-functions.psd1" -Verbose

# check for Gmail account and app password environment variables for email notifications, log if not found and set $EmailNotificationsEnabled to false
if (!$env:EMAIL_USERNAME -or !$env:EMAIL_APP_PASSWORD) {
    Write-LogEntry "Gmail account environment variables not found. Email notifications will be disabled." $log_file
    Write-EventLogEntry -logTxt "Gmail account environment variables not found. Email notifications will be disabled." -eventId 400
    $EmailNotificationsEnabled = $false
} else {
    $EmailNotificationsEnabled = $true
}

Write-LogEntry "---------------------------------" $log_file
Write-LogEntry "New execution, will check current external IP address of the Router and update Route53 if needed." $log_file
Write-LogEntry "Current external IP: $(Invoke-WebRequest -UseBasicParsing -Uri 'http://myexternalip.com/raw')" $log_file

try {
    Write-LogEntry "Checking and updating DNS records if needed." $log_file
    Write-EventLogEntry -logTxt "Checking and updating DNS records if needed." -eventId 100
    $updated_records = Update-MyRouterDNSRecords -ZoneId $ZONE_ID -ZoneName $zone_name -RecordNames $RecordNames
} catch {
    Write-LogEntry "Error updating DNS records: $RecordNames" $log_file
    Write-EventLogEntry -logTxt "Error updating DNS records: $RecordNames" -eventId 500
    if ($EmailNotificationsEnabled) {
        Send-GmailNotification -EmailTo "<your-email@example.com>" -EmailSubject "Error updating DNS records" -Body "An error occurred while updating DNS records: $RecordNames. Error details: $_"
    }
}

if (!$updated_records) {
    Write-LogEntry "No DNS records needed to be updated." $log_file
    Write-EventLogEntry -logTxt "No DNS records needed to be updated." -eventId 200
} else {
    Write-LogEntry "Updated DNS records: $updated_records" $log_file
    Write-EventLogEntry -logTxt "Updated DNS records: $updated_records" -eventId 300
    if ($EmailNotificationsEnabled) {
        $EmailBody = "DNS updated for home router public IP. Updated records: $updated_records. `n New external IP: $external_ip."
        Send-GmailNotification -EmailTo "<your-email@example.com>" -EmailSubject "Router DNS Updated" -Body $EmailBody
    }
}

Write-LogEntry "Record check complete." $log_file

# end of line