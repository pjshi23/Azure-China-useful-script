
# Description
# The script copy all Blobs of StorageAccount1/Container1 
# to StorageAccount2/Container2
 
# requirement:
# 1. you have access to both storage accounts + keys
# 2. create a target location container in the target storage Account
 
Import-Module Azure
 
# ToDo - Enter your SubscriptionName into Line 3
# e.g. get your Name with: 
#           Get-AzureSubscription | Select SubscriptionName


Select-AzureSubscription "<subscription name>"
 #Parameters
$subscriptionid = "<storage account>"
#/Parameters

#Code
Add-AzureAccount -Environment Azurechinacloud
Select-AzureSubscription -SubscriptionId $subscriptionid -Current 

# Source Storage Account
# Enter your Storage Account Name und your Key to get access
$storageAccount = "<source account name>"
$storageAccountKey = "<key>"
$srcContainerName = "vhds"
 
# Destination Storage Account
# Enter your Storage Account Name und your Key to get access
$targetStorageAccount = "<target account name>"
$targetStorageAccountKey = "<key>"
$targetContainer = "vhds"
 
 
# loading Source
$srcStorageAccount =  $storageAccount
$srcStorageAccountKey = $storageAccountKey 
 
# Source Context
$srcContext = New-AzureStorageContext –ConnectionString “DefaultEndpointsProtocol=https;AccountName=$srcStorageAccount;AccountKey=$srcStorageAccountKey;BlobEndpoint=https://$srcStorageAccount.blob.core.windows.net”
 
#destination context
$destContext = New-AzureStorageContext -StorageAccountName $targetStorageAccount -StorageAccountKey $targetStorageAccountKey
 
# temp var for Copy Status 
$tempStorageContainerAccounts = @{}   
$tempCopyStates = @()
 
# receive a list of blobs you want to copy
$allBlobs = Get-AzureStorageBlob -Container $srcContainerName -Context $srcContext
 
foreach ($blob in $allBlobs)
{
    $fileName = $blob.Name
    $mediaLink = "https://$storageAccount.blob.core.chinacloudapi.cn/$srcContainerName/$fileName"
    $targetUri = $destContext.BlobEndPoint + $targetContainer + "/" + $fileName    
 
    $tempCopyState = Start-AzureStorageBlobCopy -Context $srcContext -SrcUri $mediaLink -DestContext $destContext -DestContainer $targetContainer -DestBlob $fileName 
    $tempCopyStates += $tempCopyState
 
    write-host "copied: $mediaLink -> $targetUri"
}
 
Start-Sleep -Seconds 2
$input = "y"
 
# in Case you will copy TB of data from continent to continent, 
# a little update is nice for the hours it will take
while ($input -eq "y")
{
    # Wait for all copy operations to New container to complete
    # These copies should be instantaneous since they are in the same 
    # data center.
    foreach ($copyState in $tempCopyStates)
    {
        $now = get-date
        Write-host "Timestamp: $now"
 
        # Show copy status.    # -WaitForComplete
        $copyState |  Get-AzureStorageBlobCopyState  | Format-Table -AutoSize -Property Status,BytesCopied,TotalBytes,Source
 
    write-host $copyState.ICloudBlob.Container.Uri.AbsoluteUri"/"$fileName
    }
    $input = Read-Host "Enter Refresh (y/n)?" 
}
 
 
