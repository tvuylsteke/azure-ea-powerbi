# Azure EA Usage Data with Power BI

This repository contains some scripts I use to get the usage data of an Azure Enterprise Agreement (EA) into Power BI. In order to get this data into Power BI there are several options.
* Azure Enterprise Power Content Pack: https://powerbi.microsoft.com/en-us/documentation/powerbi-content-pack-azure-enterprise/
* Something custom which extracts data from the EA and puts it somewhere Power BI online can get it.

Now the content pack definately has its advantages. For one it's dead easy. You just need your enrollment number and API key and off you go. Even with the free Power BI edition you're good to go! Now there's a downside to this story. One thing which I find a pity is that you can't use Power BI Desktop to edit your reports or shape your data. You can only work from the Power BI online tooling. That alone could be acceptable.
The biggest problem I see however is the tags data. Typically people use tags in Azure Resource Management next to Resource Groups to divide resources in buckets. Tags might also be used for automation purposes. Take the following as an example: a VM is tagged with Environment: DEV and maybye Application: ERP. Now in Power BI you might want to have a report that shows you the costs for all resources belonging to the ERP application. Or maybe the DEV environment. However here's how the Tags column looks like in Power BI online: 

* {"Environment":"DEV","Application":"ERP"}.

Yep, that's JSON. If we'd have additional columns like Environment and Application we could do things like this:

![Alt text](/IMG/PowerBIDesktop.png?raw=true)

The scripts and guidance on this repository do that. This solution uses the following components:

* Azure EA Rest API: allows you to periodically retrieve the usage data for a given month
* Azure Storage Account: allows you to store the retrieved data and access it from both Power BI Desktop and Power BI Online
* Azure Automation: allows you to run PowerShell scripts on a regular base.
* Power BI Desktop: allows you to do all kinds of funky things with the data before making it available to your reports
* Power BI Online: allows you to periodically refresh the data so the reports are always up to date. Power BI online also provides you with dashboards, alerting and publishing capabilities.

Here's how you can get started:

## Azure EA

Log in to the Azure EA Portal (https://ea.azure.com) and get you:

* EA Enrollment number: 123456789
* EA API key: xxxx

## Azure

Log in to the Azure Portal (https://portal.azure.com) or use another way to perform the following steps:

### Storage Account

Create a storage account and a container on that storage account. Note down the following items:

* Storage account name: e.g. contosolrseadata
* Container name: e.g. usagedata
* Storage account acccess key: yyyy

If you like to use an existing storage account that's fine. Just make sure you have a container dedicated to the usage data. Keep in mind that both the automation script and Power BI online have full access to the storage account because we will use the access key in those.

### Azure Automation Runbook

Now create a new or use an existing **Azure Automation account**. In that Automation Account we we'll setup a PowerShell script that will run regulary. The script can be found in this repository: Download-EA-UsageData.ps1 [../Download-EA-UsageData.ps1](../Download-EA-UsageData.ps1). When creating the runbook you can pick regular PowerShell and copy paste the contents of the Download-EA-UsageData.ps1 script. You don't need to change anything in the script.

Next up is setting up the required **Automation Variables**. We'll have variables for the following items:
* EA Enrollment number
* EA API key
* Azure Storage Account
* Container
* Azure Storage Account Access Key

You can open the Configure-for_Download-EA-UsageData.ps1 [../Configure-for_Download-EA-UsageData.ps1](../Configure-for_Download-EA-UsageData.ps1)using your favorite text editor and fill in the required values. Then execute the commands against your Azure subscription. We're using PowerShell for this because it avoids the limitation of the GUI with regards to the maximum length variables can have. And it's easy!

In order for the script to run periodically we need to create some schedules. Based on your needs you could tweak the following proposal:

* Schedule #1: daily at 5:00: no parameters
* Schedule #2: once every month on the first of the month at 6:00: parameter runForPreviousMonth set to $true

The 2nd schedule ensures when we start a new month we don't have a gap of 5:00 till the end of the day for the previous month. We could also schedule our first schedule at 23:59, but I'm not sure the EA data is updated that fast.

Execute the runbook at least once so you have some data. Check the container contents to be sure:

![Alt text](/IMG/StorageAccountContainer.png?raw=true)

## Power BI Desktop

### Data Source

* Open Power BI Desktop. 
* Click Get Data and choose **Blank Query**. A second screen should open up. 
* Choose Advanced Editor and copy paste the code from the PowerBI-EA-UsageData.m (https://github.com/tvuylsteke/azure-ea-powerbi/blob/master/PowerBI-EA-UsageData.m) file. 
* Replace the **Ustorage account name** on the 2nd line (setspnpowerbi in the sample code)
* Replace the **container name** on the 3th line (usagedata in the sample code) 
* Click done in the advanced editor
* You'll see a yellow bar asking you to specify credentials to connect. Click Edit Credentials.
* Copy paste the **storage account access key** you copied earlier
* Now it should refresh and load your data
* Provide a name for the query: e.g. Azure Usage Data
* Close the query window and click yes when asked to apply query changes

### Report

Once you have the data source ready you can go ahead and create reports. Once you're doing creating the reports click File -> Publish -> **Publish to Power BI**. The filename of the Power BI Desktop file will be used for both the report and dataset name in Power BI.

## Power BI

The first thing you'll want to do is ensure your data is refreshed regularly. Even with the Power BI free version you can have a daily refresh. 

* Right-click your dataset and choose **Schedule Refresh**
* You'll see a warning regarding the data source credentials. Click edit and provide the storage account access key again
* Click Schedule Refresh and configure it as you like
* Now you can start creating dashboards

![Alt text](/IMG/PowerBIAlert.png?raw=true)

## Notes

Some general notes and random thoughts:

* **Keys are temporary**! While they seem like an easy way to provide access to another service, make sure you know where and when to update the key so that everything keeps running. Both the Azure EA API and storage account have a key.
    * Azure EA API Key: update in the Azure Automation variable
    * Storage account access key: update in Azure Automation variable, update in Power BI Online dataset credentials. Updating the key in Power BI Desktop is only required when you want to create/update repots.
* **Tags**: while building this solution I had various version of this. Each version had his issues.
    * **Version #1**: let the PowerShell script that downloads the usage data parse the JSON Tags column and create the required columns. Challenge: tags might be added/removed on various occasions. This results in CSV files having different columns. That makes the Power BI aspect more challenging.
    * **Version #2**: have a static CSV file on the storage account which contains the Tags you want to see as columns. The Power BI M query language then looked at this file to know which columns to create when processing the query. While this worked perfectly I wasn't entirely satisfied with it. 
    *  **Version #3**: this is the current version. This one does some M query black magic to get a list of columns to add based on all the tags it reads. I did some tests and it seems to work fine. For environments with a lot of usage data and a lot of tags this might come with a performance penalty. These might be better of with version #2. Contact me if you're interested.
* The Azure EA Rest API allows you to ask for a specific month or all available months. I prefer to work with one CSV file representing the data of a month. This will speed up the Azure Automation script.
* Intially I looked at Azure Functions to do the Azure Automation part. Probably this will be my next improvement. The reason I stopped looking at it was that it was quite challenging (impossible?) to provide a name for the output file on the blob with a PowerShell Azure Function. As with this approach we really want to overwrite the file for the same month over and over again.
