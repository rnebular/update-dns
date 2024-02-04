# Script to get my public IP and update my DNS records if need be.
# Authentication with AWS setup using an IAM user and SSH keys.

# static variables
$all_records = "record1","record2","record3" #can be a single record or multiple
$zone_name = "<Zone_suffix>"
$ZONE_ID = "<Zone_ID>"

# AWS tools for Powershell, full module
Import-Module AWSPowershell.NetCore

# Get the external IP of the internet router
$external_ip = (Invoke-WebRequest myexternalip.com/raw).content

$all_records | ForEach-Object {
    $record = "$_.$zone_name"
    Write-Output "Verifying $record DNS record is still current."
    $current_record = Test-R53DNSAnswer -HostedZoneId $ZONE_ID -RecordName $record -RecordType "A"
    $current_ip = $current_record.RecordData
    Write-Output "Current DNS IP: $current_ip"
    If ($current_ip -eq $external_ip) {
        Write-Output "IP is correct, no need to change it."
    } else {
        Write-Output "IP is not correct and will be updated from $current_ip to $external_ip."

        # change set
        $change1 = New-Object Amazon.Route53.Model.Change
        $change1.Action = "UPSERT"
        $change1.ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
        $change1.ResourceRecordSet.Name = "$record"
        $change1.ResourceRecordSet.Type = "A"
        $change1.ResourceRecordSet.TTL = 60
        $change1.ResourceRecordSet.ResourceRecords.Add(@{Value="$external_ip"})

        $params = @{
            HostedZoneId="$ZONE_ID"
            ChangeBatch_Comment="This change updates the IP of $record to current."
            ChangeBatch_Change=$change1
        }
        
        # time to update the record
        $results=Edit-R53ResourceRecordSet @params
        $result_record = Test-R53DNSAnswer -HostedZoneId $ZONE_ID -RecordName $record -RecordType "A"
        $result_ip = $result_record.RecordData
        Write-Output "Verified that $record is now set to $result_ip."
    }
}

# end of line