V1 / ASM
#To resize this, first shutdown the vm: 
Get-AzureVM -ServiceName "vfldev" -Name "vfldev" | Stop-AzureVM -Force 
#Get the OS disk attacked to this VM:
Get-AzureVM -ServiceName "vfldev" -Name "vfldev" | get-AzureOSDisk 
Update-AzureDisk –DiskName "vfldev-vfldev-0-201503091934500547" -Label "ResiZedOS" -ResizedSizeInGB 100 

V2/ARM
Login-AzureRmAccount
$VMname = "ubu15"
$rsg = "velostrata"
$VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $rsg
Stop-AzureRmVM -Name $vmname -ResourceGroupName $rsg -Force
 
# set OS disk to 200GB
$vm.StorageProfile.OsDisk.DiskSizeGB = 200 
Update-AzureRmVM -VM $VM -ResourceGroupName $rsg
