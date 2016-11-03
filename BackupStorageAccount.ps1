# primary means hot tier
# secondary means cool tier
# it simply migrate hot tier data to cool tier so please create cool tier prior to kick off this script
#of course, you need to auth with Azure at first 


$primary = "apilogfilesprimary"
$secondary = "apilogfilessecondary"

$primarykey = Get-AzureRmStorageAccountKey -ResourceGroupName accuweather -Name $primary
$secondarykey = Get-AzureRmStorageAccountKey -ResourceGroupName accuweather -Name $secondary

$primaryctx = New-AzureStorageContext -StorageAccountName $primary -StorageAccountKey $primarykey.Key1
$secondaryctx = New-AzureStorageContext -StorageAccountName $secondary -StorageAccountKey $secondarykey.Key1

$primarycontainers = Get-AzureStorageContainer -Context $primaryctx

# Loop through each of the containers
foreach($container in $primarycontainers)
{
    # Do a quick check to see if the secondary container exists, if not, create it.
    $secContainer = Get-AzureStorageContainer -Name $container.Name -Context $secondaryctx -ErrorAction SilentlyContinue
    if (!$secContainer)
    {
        $secContainer = New-AzureStorageContainer -Context $secondaryctx -Name $container.Name
        Write-Host "Successfully created Container" $secContainer.Name "in Account" $secondary
    }

    # Loop through all of the objects within the container and copy them to the same container on the secondary account
    $primaryblobs = Get-AzureStorageBlob -Container $container.Name -Context $primaryctx

    foreach($blob in $primaryblobs)
    {
        $copyblob = Get-AzureStorageBlob -Context $secondaryctx -Blob $blob.Name -Container $container.Name -ErrorAction SilentlyContinue

        # Check to see if the blob exists in the secondary account or if it has been updated since the last runtime.
        if (!$copyblob -or $blob.LastModified -gt $copyblob.LastModified) {
            $copyblob = Start-AzureStorageBlobCopy -SrcBlob $blob.Name -SrcContainer $container.Name -Context $primaryctx -DestContainer $secContainer.Name -DestContext $secondaryctx -DestBlob $blob.Name
    
            $status = $copyblob | Get-AzureStorageBlobCopyState
            while ($status.Status -eq "Pending")
            {
                $status = $copyblob | Get-AzureStorageBlobCopyState
                Start-Sleep 10
            }

            Write-Host "Successfully copied blob" $copyblob.Name "to Account" $secondary "in container" $container.Name
        }

    }
    
}