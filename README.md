# update-dns
Scripting to update my home DNS records due to dynamic WAN IP changes. Poor man's dynamic dns updater.

- Needs AWS authentication setup before running. I use an AWS IAM User with API credentials.
- Need to have the AWSPowerShell.NetCore module installed. If any other AWS tools module is to be used, modify the script to import that version.
(`Install-Module AWSPowerShell.Netcore`)

