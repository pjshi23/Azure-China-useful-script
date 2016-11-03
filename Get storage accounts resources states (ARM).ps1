
#Parameters
$subscriptionid = "<storage account>"
#/Parameters

#Code
Login-AzureRmAccount -SubscriptionId $subscriptionid -EnvironmentName Azurechinacloud
$storageAccounts = Get-AzureRmStorageAccount
foreach ($storageAccount in $storageAccounts)
{
    if ($storageAccount.Id -notlike "*securitydata/providers**")
    {
        write-host "Storage account:" $storageAccount.StorageAccountName
        $azureStorageContext = New-AzureStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName).Key1
        $azureStorageContainers = Get-AzureStorageContainer -Context $azureStorageContext
        write-host " Containers count:" $azureStorageContainers.Count
        foreach ($azureStorageContainer in $azureStorageContainers)
        {
            write-host " Container:" $azureStorageContainer.Name "(Lease:" $azureStorageContainer.CloudBlobContainer.Properties.LeaseState ")"
            $blobs = Get-AzureStorageBlob -Container $azureStorageContainer.Name -Context $azureStorageContext
            write-host "   Blobs count:" $blobs.Count
            if ($blobs.Count -gt 0)
            {
                write-host "    Blobs"
                foreach ($blob in $blobs)
                {
                
                    write-host "     * " $blob.Name
                    write-host "      - Lease state:" $blob.ICloudBlob.Properties.LeaseState
                    write-host "      - Last modified:" $blob.ICloudBlob.Properties.LastModified
                    write-host "      - VM:" $blob.ICloudBlob.Metadata.MicrosoftAzureCompute_VMName
                }
            }
        }
    }
}

#/Code

#Exit
return $LASTEXITCODE
#/Exit


