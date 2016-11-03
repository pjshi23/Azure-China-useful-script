$vm = Get-AzureVM -ServiceName 'cloudservice' -Name 'vmname' 

#Check the waagent Status = Ready
$vm.GuestAgentStatus 

#Get VM informaiton
Get-AzureVM -ServiceName 'sles11vfl' |Get-AzureDeployment 

#Enter your current user name and new password
$UserName = "username"
$Password = "password"

[hashtable]$Param=@{};
$Param['username'] = $UserName;
$Param['password'] = $Password;
$Param['expiration'] = '2017-01-01';
$PrivateConfig = ConvertTo-Json $Param;
#Begin execution
$ExtensionName = 'VMAccessForLinux'
$Publisher = 'Microsoft.OSTCExtensions'
$Version = '1.*'

Set-AzureVMExtension -ExtensionName $ExtensionName -VM $vm -Publisher $Publisher -Version $Version -PrivateConfiguration $PrivateConfig | Update-AzureVM 

#Check that the VM has extension VMAccessForLinux in State = Enable - If nothing is returned wait a few minutes and try again
#If still no data the extension is not enabled or installed

Get-AzureVMExtension -VM $vm 
