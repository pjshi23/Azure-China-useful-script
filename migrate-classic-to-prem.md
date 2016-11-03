# CLASSIC VMs #

Below, you can find an example of PowerShell cmdlet to use in each steps:

1) Login to subscription and select current one

    add-azureaccount -Environment AzureChinaCloud
    get-azuresubscription
    select-azuresubscription -subscriptionname "subscriptionname"  

2) Export VM configuration
    
    Get-AzureVM 
    Export-AzureVM -ServiceName $serviceName -Name $vmName -Path "C:\MyFolder\VM1config.xml"
     
3) Delete the VM and keep all existing disks

    Stop-AzureVM -Name $vmName -ServiceName $serviceName -Force
    Remove-AzureVM -Name $vmName -ServiceName $serviceName -Verbose

4) Move all VHDs from Standard Storage Account to Premium Storage Account via AzCopy

*Getting Started with the AzCopy Command-Line Utility*

[https://azure.microsoft.com/en-us/documentation/articles/storage-use-azcopy/](https://azure.microsoft.com/en-us/documentation/articles/storage-use-azcopy/)
 


    AzCopy /Source:https://sourceaccount.blob.core.chinacloudapi.cn/mycontainer1 /Dest:https://destaccount.blob.core.chinacloudapi.cn/mycontainer2 /SourceKey:key1 /DestKey:key2 /Pattern:filename.vhd
 
5) Create the OS and Data disks based on existing VHDs

    # OS Disk
    Add-AzureDisk -DiskName "MY-OS-Disk-Name" -MediaLocation "http://yourstorageaccount.blob.core.chinacloudapi.cn/vhds/winosdisk.vhd" -Label "W12Disk" -OS "Windows" 
    # Data Disk
    Add-AzureDisk -DiskName "MY-Data-Disk-Name" -MediaLocation "http://yourstorageaccount.blob.core.chinacloudapi.cn/vhds/datadisk.vhd" -Label "SQLDataDisk" 
 
6) Verify the exported VM configuration to point to the correct disks
    <DiskName>MY-OS-Disk-Name</DiskName>
    ...
    <DiskName>MY-Data-Disk-Name</DiskName>
    ...
    <RoleSize>Standard_DS14</RoleSize>
 
7) Create new VM based on the exported configuration

    New-AzureService -ServiceName ServiceName -Location "China East"
    $vm1 = Import-AzureVM -Path "D:\folder\VM1config.xml"
    New-AzureVM –ServiceName ServiceName -Location "East US"  -VMs $vm1 -VNetName "VNetName"



# ARM VMs #

Below, you can find an example of PowerShell cmdlet to use in each steps:

1) Login to subscription and select current one


    Login-AzureRmAccount -SubscriptionId $subscriptionid -EnvironmentName AzureChinacloud

 
2) Export JSON format for the Resource Group from Portal: Azure VM -> Automation Script -> Download




3) Save the ZIP file which contains a PowerShell script
 
4) Delete the VM and keep all existing disks
    Stop-AzureRmVM -Name $vmName -ResourceGroupName $RGName -Force
    Remove-AzureRmVM -Name $vmName -ResourceGroupName $RGName -Verbose
 
5) Move all VHDs from Standard Storage Account to Premium Storage Account via AzCopy

*Getting Started with the AzCopy Command-Line Utility*

[https://azure.microsoft.com/en-us/documentation/articles/storage-use-azcopy/](https://azure.microsoft.com/en-us/documentation/articles/storage-use-azcopy/)
 


    AzCopy /Source:https://sourceaccount.blob.core.chinacloudapi.cn/mycontainer1 /Dest:https://destaccount.blob.core.chinacloudapi.cn/mycontainer2 /SourceKey:key1 /DestKey:key2 /Pattern:filename.vhd
 
 
 
6) Edit the JSON of the exported VM configuration:

    	1. Change the VM size to Standard_DSnn
    	2. Change storage account and disks
    {
    "hardwareProfile": {
    	"vmSize": "Standard_DSnn"
    {
    "osDisk": {
    	"osType": "Windows",
    	"encryptionSettings": null,
    	"name": "vm-name",
    	"vhd": {
    	"uri": "https://premiumstorageaccount.blob.core.chinacloudapi.cn/vhds/vmname-osdisk.vhd"
    }

7) Run the PowerShell script inside the ZIP file to re-create all VMs in Resource Group
