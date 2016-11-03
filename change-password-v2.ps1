$vm = Get-AzureVM -ServiceName 'cloudservice' -Name 'vmname'

$timestamp = Get-Date
echo $timestamp
#$PublicConfiguration = '{"commandToExecute": " df -h "}'

$PublicConfiguration = "{""commandToExecute"": ""bash -c \""echo \""username:password\""|chpasswd\"""" , ""timestamp"": ""$timestamp""}"

#Deploy the extension to the VM
$ExtensionName = 'CustomScriptForLinux'  
$Publisher = 'Microsoft.OSTCExtensions'  
$Version = '1.*' 
Set-AzureVMExtension -ExtensionName $ExtensionName -VM  $vm -Publisher $Publisher -Version $Version -PublicConfiguration $PublicConfiguration  | Update-AzureVM

Get-AzureVMExtension -VM $vm 