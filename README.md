# update-dns
Scripting to update my home DNS records due to dynamic WAN IP changes. Poor man's dynamic dns updater.

- Needs AWS authentication setup before running. I use an AWS IAM User with API credentials.
- Need to have the AWSPowerShell.NetCore module installed. If any other AWS tools module is to be used, modify the script to import that version.
(`Install-Module AWSPowerShell.Netcore`)

# usage
1. Copy the script (script/check-my-ip.ps1) to your local user profile folder `C:\Users\<username>\`.
1. From a PowerShell prompt, simply run the script.
`C:\Users\<username>\check-my-ip.ps1`
