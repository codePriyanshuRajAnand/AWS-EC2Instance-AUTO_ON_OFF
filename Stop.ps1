<#
    !SBD-StopInstances.ps1 v1.0 created to Facilitate the Auto Shutdown of AWS servers
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

$preMsg = @"
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

Below AWS Servers will be shutdown in next 30 Minutes, kindly complete all your important work before that...

"@

$srvStatus = @"
<table>
<tr>
<th>Server</th>
<th>Status</th>
</tr>
"@

foreach ($instance in $Instances){
    $instanceState = Invoke-Command -ScriptBlock ${function:getState} -argumentlist $instance
    $instanceName = Invoke-Command -ScriptBlock ${function:getInstanceName} -argumentlist $instance
    $temp = @"
    <tr>
<td>$instanceName</td>
<td>$instanceState</td>
</tr>
"@

$srvStatus += $temp
}

$preMsg = $preMsg + $srvStatus + "</table><br><br> Thanks,<br>(Automation Team) </body> </html>"


Send-MailMessage -To "testuser@test.com" -Cc "team@test.com" -From "AutomationTeam<Automation@test.com>" -SmtpServer:smtp.srv.com -Subject "Notice: AWS Automated Servers Shutdown" -BodyAsHtml $preMsg -Priority High

Get-Date

Start-Sleep 1800

Get-Date

foreach ($instance in $instances) {
    $instanceState = Invoke-Command -ScriptBlock ${function:getState} -argumentlist $instance
    $instanceName = Invoke-Command -ScriptBlock ${function:getInstanceName} -argumentlist $instance
    Write-Host "Current State of Server - $instanceName ($instance) is $instanceState"
    if($instanceState -ne "stopped"){
        Write-Host "Proceeding to Stop $instanceName ($instance)..."
        $isStopped = (Stop-EC2Instance -InstanceId $instance -Force -ProfileName NonProduction -Region us-east-1).Instances.State.Name
        while ($isStopped -ne "stopped"){
            Start-Sleep 10
            Write-Host "."
            $isStopped  = (Get-EC2Instance -InstanceId $instance -ProfileName NonProduction -Region us-east-1).Instances.State.Name
        }
        Write-Host "$instanceName ($instance) is Stopped Now"
        Write-Host "Thank you ..."
    }
    else {
        write-host "$instanceName ($instance) is already in stopped state"
    }
}

$message = @"

Hi Team,
<br><br>
Servers are Shutdown successfully...<br><br><br>

Thanks,<br>(Automation Team)

"@

Send-MailMessage - -To "testuser@test.com" -Cc "team@test.com" -From "AutomationTeam<Automation@test.com>" -SmtpServer:smtp.srv.com -Subject "Notice: AWS Automated Servers Shutdown" -BodyAsHtml $message -Priority High
Remove-Variable -Name * -ErrorAction SilentlyContinue
