<#
    !SBD-StartInstances.ps1 v1.0 created to Facilitate the Auto Power On AWS servers
#>


function getState ($instanceId) {
    $instanceState = (Get-EC2Instance -InstanceId $instanceId -ProfileName NonProduction -Region us-east-1).Instances.State.Name
    return $instanceState
}

function getInstanceName($instanceId) {
    $instanceName = (Get-EC2Instance -InstanceID $instanceId -ProfileName NonProduction -Region us-east-1).Instances.Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -ExpandProperty Value
    return $instanceName
}

$instances = Get-Content "<PATH_OF_INSTANCE_IDs>"
$srvStatus = @"
<table>
<tr>
<th>Server</th>
<th>Status</th>
</tr>
"@

foreach ($instance in $instances) {
    $instanceState = Invoke-Command -ScriptBlock ${function:getState} -argumentlist $instance
    $instanceName = Invoke-Command -ScriptBlock ${function:getInstanceName} -argumentlist $instance
    Write-Host "Current State of Server - $instanceName ($instance) is $instanceState"
    if($instanceState -ne "running"){
        Write-Host "Proceeding to Start $instanceName ($instance)..."
        $isStarted = (Start-EC2Instance -InstanceId $instance -Force -ProfileName NonProduction -Region us-east-1).Instances.State.Name
        while ($isStarted -ne "running"){
            Start-Sleep 10
            Write-Host "."
            $isStarted  = (Get-EC2Instance -InstanceId $instance -ProfileName NonProduction -Region us-east-1).Instances.State.Name
        }
        Write-Host "$instanceName ($instance) is UP & Running Now"
        Write-Host "Thank you ..."

    }
    else {
        write-host "$instanceName ($instance) is already UP & Running No need to start."
    }
    $instanceState = Invoke-Command -ScriptBlock ${function:getState} -argumentlist $instance
    $temp = @"
    <tr>
<td>$instanceName</td>
<td>$instanceState</td>
</tr>
"@

$srvStatus += $temp
}

$message = @"

<html>
<head>

<style>
table, th, td {
  border: 1px solid;
}
</style>
</head>
<body>

Hi Team,

<br>

Below servers are now UP & Running...<br><br>

"@
$message += $srvStatus
$message += @"
</table>
<br><br>
Thank you!<br>
(Automation Team)
</body>
</html>

"@

Send-MailMessage -To "testuser@test.com" -Cc "team@test.com" -From "AutomationTeam<Automation@test.com>" -SmtpServer:smtp.srv.com -Subject "Notice: AWS Automated Server Power On" -BodyAsHtml $message -Priority High
Remove-Variable -Name * -ErrorAction SilentlyContinue
