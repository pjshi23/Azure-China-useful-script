$subscriptionid = "<subscription ID>"
$storageaccountname = "<storage account>"
$resourcegroupname = "<resource group name>"

Login-AzureRmAccount -SubscriptionId $subscriptionid -EnvironmentName AzureChinacloud
Select-AzureRmSubscription -SubscriptionId $subscriptionid
Set-AzureRmCurrentStorageAccount -ResourceGroupName $resourcegroupname -StorageAccountName $storageaccountname

$StorageAccount = Get-AzureRmStorageAccount -Name $storageaccountname -ResourceGroupName $resourcegroupname
$AzureStorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccount.ResourceGroupName -Name $StorageAccount.StorageAccountName)[0].Key1
$storageAccountContainers = Get-AzureStorageContainer -Context $AzureStorageContext

write-host "***** Containers:"
$count = 0
foreach ($storageAccountContainer in $storageAccountContainers)
{
    write-host "$count - " $storageAccountContainer.Name
    $count++
}

$containerIndex = read-host "Which container contains to blob to backup?"

$container = $storageAccountContainers[$containerIndex]

write-host ""
$confirm = read-host "Do you confirm the blob is in **" $container.Name "** (y/n) ?"
write-host ""

if ($confirm.ToLower() -eq "y")
{
    $blobs = Get-AzureStorageBlob -Container $container.Name -Context $AzureStorageContext
    write-host "***** Blobs:"
    $count = 0
    foreach ($blob in $blobs)
    {
        write-host "  $count - " $blob.Name
        $count++
    }

    write-host ""
    $blobIndex = Read-Host "Which blob do you want to backup ?"
    write-host ""
    $blob = (Get-AzureStorageBlob -Container $container.Name -Context $AzureStorageContext)[$blobIndex]

    $confirm = read-host "Do you confirm the blob to backup:" $blob.Name "(y/n) ?"
    write-host ""


    $blobCopy = Start-AzureStorageBlobCopy -srcUri $blob.ICloudBlob.Uri -SrcContext $AzureStorageContext -DestContainer "vhds" -DestBlob $("BCK_"+$blob.Name) -DestContext $AzureStorageContext
    $status = $blobCopy | Get-AzureStorageBlobCopyState
    while ($status.Status -eq "Pending")
    {
        $status = $blobCopy | Get-AzureStorageBlobCopyState
        write-host ("  Copy satus: {0} - Bytes copied: {1}/{2} - %: {3}" -f $status.Status, $status.BytesCopied, $status.TotalBytes, ($status.BytesCopied/$status.TotalBytes*100).ToString())
        Start-Sleep -Seconds 10
    }

    if ($status.Status -ne "Success")
    {
        write-host ""
        write-host "Blob copy error. Exit process..." -ForegroundColor Red
        $status
        write-host ""
        Exit
    }
    elseif($status.Status -eq "Success")
    {
        write-host ""
        write-host "Blob copy successful !" -ForegroundColor Green
        write-host ""
        Get-AzureStorageBlob -Container $container.Name -Context $AzureStorageContext | ? { $_.Name -like $("*BCK_"+$blob.Name+"*")}
    }
}
