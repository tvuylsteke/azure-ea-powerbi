# Source: https://blogs.msdn.microsoft.com/tomholl/2016/03/08/analysing-enterprise-azure-spend-by-tags/

<#
.SYNOPSIS
Downloads the usage data for a given month and saves it as a csv on an Azure storage account.

.DESCRIPTION
This script uses the Azure Enterprise Agreement REST API to retrieve the usage details of a given month. 
The result is a CSV file that is stored on an Azure Storage Account. The parameters required to connect to the EA REST API
and Azure storage account are passed along as Azure Automation variables.

Typical usage for runForPreviousMonth: you can scheduled this script to run once a day or a week. When it runs more than once for a given month
it will update the CSV on the storage account. However in order to ensure the CSV contains the data between the last time the script ran and the
end of the month we included the runForPreviousMonth parameter.

Typical usage for runYear/runMonth: you can run the Azure Automation runbook multiple times by hand specifying these paramters. That way you can
ensure the data of the past months is also collected and made available on the storage account.

.PARAMETER runForPreviousMonth 
Either $true or $false. This parameter indicates that the previous month should be retrieved instead of the current month
This is an optional parameter; if it is not included, the default value of false is used.

.PARAMETER runYear
The path and file name of a text file. Any computers that cannot be reached will be logged to this file. 
This is an optional parameter; if it is notincluded, the current year is used.

.PARAMETER runMonth
The path and file name of a text file. Any computers that cannot be reached will be logged to this file. 
This is an optional parameter; if it is notincluded, the current month is used.

.EXAMPLE
Download the usage data of the current month.
.\Download-EA-UsageData.ps1

.EXAMPLE 
Download the usage data for the previous month.
.\Download-EA-UsageData.ps1 -runForPreviousMonth $true

.EXAMPLE 
Download the usage data for a specific month (e.g. September 2016).
.\Download-EA-UsageData.ps1 -runYear 2016 -runMonth 9

.NOTES
This script is intented to be used inside an Azure Automation environment. Some of the parameters required for this script to work or passed using Azure Automation varaibles.
#>

param (
    [Parameter(Mandatory=$false)]
    [boolean] $runForPreviousMonth = $false, 
    [Parameter(Mandatory=$false)]
    [int] $runYear,       
    [Parameter(Mandatory=$false)]
    [int] $runMonth
)
 
$StorageAccountName = Get-AutomationVariable -Name 'usageData_StorageAccount' 
$ContainerName = Get-AutomationVariable -Name 'usageData_Container'
$StorageAccountKey = Get-AutomationVariable -Name 'usageData_StorageKey'
$EnrollmentNbr = Get-AutomationVariable -Name 'usageData_EnrollmentNumber'
$key = Get-AutomationVariable -Name 'usageData_EnrollmentKey'
 
# function to invoke the api, download the data, import it, and merge it to the global array
Function DownloadUsageReport( [string]$LinkToDownloadDetailReport, $csvAll )
{
             $AccessToken = "Bearer $Key"
        $urlbase = 'https://ea.azure.com'        
             # access token is "bearer " and the the long string of garbage        
        $webClient = New-Object System.Net.WebClient
             $webClient.Headers.add('api-version','1.0')
             $webClient.Headers.add('Authorization', "$AccessToken")
             $data = $webClient.DownloadString("$urlbase/$LinkToDownloadDetailReport")
             # remove the funky stuff in the leading rows - skip to the first header column value
             $pos = $data.IndexOf("AccountOwnerId")
             $data = $data.Substring($pos-1)
             # convert from CSV into an ps variable
             $csvM = ($data | ConvertFrom-CSV)
             # merge with previous
             $csvAll = $csvAll + $csvM        
             return $csvAll
}

#current date
$date = get-date
#check whether a runYear or runMonth was specified
$strYear = if($runYear){$runYear} else {$date.Year}
$strMonth = if($runMonth){$runMonth} else {$date.Month}
#when running for the previous month we need to do -1
$strMonth = if($runForPreviousMonth){ $strMonth -1 } else {$strMonth} 
$strMonth = $strMonth.ToString("00")
#parameter for the API call (requires a dash in between)
$Month = "$strYear-$strMonth"
 
#output file (temporary)
$tempfile = ".\$($EnrollmentNbr)_UsageDetail$($Month)_$(Get-Date -format 'yyyyMMdd').csv"
 
#output blob
$blobname = "$($EnrollmentNbr)_UsageDetail_$strYear$strMonth.csv".ToLower()
 
Write-Output "$(Get-Date -format 's'): Azure Enrollment $EnrollmentNbr"
Write-Output "$(Get-Date -format 's'): Target Storage Account: $StorageAccountName"
Write-Output "$(Get-Date -format 's'): Target Container: $containerName"
Write-Output "$(Get-Date -format 's'): Target Blob Name: $blobname"
 
Write-Output "$(Get-Date -format 's'): Retrieve: $Month from EA API"
$csvAll = @()
$csvAll = DownloadUsageReport "rest/$EnrollmentNbr/usage-report?month=$Month&type=detail" $csvAll
Write-Output "Total rows retreived = $($csvAll.length)"
 
# save the data to a CSV file on disk
$csvAll | Export-Csv $tempfile -NoTypeInformation -Delimiter ","
#get a reference to the file we just wrote to disk
$file = gci $tempfile
 
# Create a new container.
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$cont = Get-AzureStorageContainer -Name $ContainerName -Context $ctx
if($cont -eq $null){
    Write-Output "Creating container  $containerName ..."    
    New-AzureStorageContainer -Name $ContainerName -Context $ctx
}
 
#write the file to a blob
Write-Output "Writing blob $blobname ..."
Set-AzureStorageBlobContent -File $file.FullName -Container $ContainerName -Blob $blobname -Context $ctx -Force
Write-Output "Done Writing blob!"