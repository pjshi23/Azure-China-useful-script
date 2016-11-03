delete your vm and keep VHD
note down os vhd url/nic name



		$rgname = "<your RG name>"
		$loc = "<your VM location>"
		$vmsize = "<your VM size>"
		$vmname = "<your VM name>"
		$vm = New-AzureRmVMConfig -VMName $vmname -VMSize $vmsize;
		 
		$nic = Get-AzureRmNetworkInterface -Name ("YourNICName") -ResourceGroupName $rgname;
		$nicId = $nic.Id;
		 
		$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nicId;
		 
		$osDiskName = "YourDiskOSName"
		$osDiskVhdUri = "YourDiskOSUri"
		 
		$vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $osDiskVhdUri -name $osDiskName -CreateOption attach -Windows
		 
		New-AzureRmVM -ResourceGroupName $rgname -Location $loc -VM $vm -Verbose

		
