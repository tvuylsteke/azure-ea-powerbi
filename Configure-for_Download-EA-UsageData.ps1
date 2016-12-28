<#
    PowerShell steps to be executed when configuring an Azure Automation environment for the Download-EA-UsageData.sp1
#>
$subscriptionID="dddd-xxxx-11212-dddd"
$resourceGroup = "contosoAutomationRG"
$automationAccount = "AutomationPowerProd"

$usageData_StorageKey = 'storage account key'
$usageData_Container = 'container name'
$usageData_StorageAccount = 'storage account name (the short format, not the URL)'
$usageData_EnrollmentNumber = 'EA enrollment number'
$usageData_EnrollmentKey = 'EA API key' 

login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionID
 
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroup –AutomationAccountName $automationAccount –Name 'usageData_StorageKey' –Encrypted $false –Value $usageData_StorageKey
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroup –AutomationAccountName $automationAccount –Name 'usageData_Container' –Encrypted $false –Value $usageData_Container
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroup –AutomationAccountName $automationAccount –Name 'usageData_StorageAccount' –Encrypted $false –Value $usageData_StorageAccount
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroup –AutomationAccountName $automationAccount –Name 'usageData_EnrollmentNumber' –Encrypted $false –Value $usageData_EnrollmentNumber
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroup –AutomationAccountName $automationAccount –Name 'usageData_EnrollmentKey' –Encrypted $false –Value $usageData_EnrollmentKey
 
