param(
    [parameter(Mandatory=$false)]
	[String] $AzureCredentialName = "azureautomation",
    [parameter(Mandatory=$false)]
	[String] $AzureSubscriptionName = "Contoso Azure"
)
$azureCredential = Get-AutomationPSCredential -Name $AzureCredentialName
$resourceManagerContext = Add-AzureRmAccount -Credential $azureCredential -ErrorAction SilentlyContinue
Set-AzureRmContext -SubscriptionName $AzureSubscriptionName

$filename = "expressroutecircuitstats.csv"
#$StorageAccountName = Get-AutomationVariable -Name 'usageData_StorageAccount' 
#$ContainerName = Get-AutomationVariable -Name 'usageData_Container'
#$StorageAccountKey = Get-AutomationVariable -Name 'usageData_StorageKey'

$StorageAccountName = 'contosostoraccount' 
$ContainerName = 'expressrouteusagedata'
$StorageAccountKey = 'OJSDAolajsdlioojpasdfasdf5a4sd68aasdasd=='

$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$statFile = Get-AzureStorageBlob -Container $containername -Blob $filename -context $ctx| Get-AzureStorageBlobContent -Force

$stats = Get-AzureRmExpressRouteCircuitStats -ExpressRouteCircuitName ExpressRouteCircuit -ResourceGroupName Shared_Infrastructure -PeeringType AzurePrivatePeering
$stats

#$CurrentDate = (Get-Date).addhours(1)
$CurrentDate = get-date -Format R
#$CurrentDate = $CurrentDate.ToString('dd-MM-yyyy_hh-mm-ss')

$statsObj = New-Object PSCustomObject
$statsObj | add-member -NotePropertyName PrimaryBytesIn -NotePropertyValue $stats.PrimaryBytesIn
$statsObj | add-member -NotePropertyName PrimaryBytesOut -NotePropertyValue $stats.PrimaryBytesOut
$statsObj | add-member -NotePropertyName SecondaryBytesIn -NotePropertyValue $stats.SecondaryBytesIn
$statsObj | add-member -NotePropertyName SecondaryBytesOut -NotePropertyValue $stats.SecondaryBytesOut
$statsObj | add-member -NotePropertyName TimeStamp -NotePropertyValue $CurrentDate

$statsObj | Export-Csv $filename -NoTypeInformation -Delimiter "," -append
$file = gci $filename
Set-AzureStorageBlobContent -File $file.FullName -Container $ContainerName -Blob $filename -Context $ctx -Force
