# AWS-EC2Instance-AUTO_ON_OFF
Auto Shutdown and Power On AWS EC2 instances<br>
<br>
To run this script you need to first setup install AWS PowerShell via below commands and setup AWS credentials:

To Install AWS PowerShell:
: Install-Module -Name AWSPowerShell

To Setup Credentials:

```
Set-AWSCredential `
                 -AccessKey <YOUR ACCESS KEY> `
                 -SecretKey <YOUR Secret Key> `
                 -StoreAs <Your ProfileName>
```

: To validate credentails is setup or not

Get-AWSCredential -ListProfileDetail 


