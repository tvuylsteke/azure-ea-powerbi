# Azure EA Usage Data with Power BI

This repository contains some scripts I used to get the usage data of an Azure Enterprise Agreement (EA) into Power BI. In order to get data into Power BI there are several methods. For the EA data I see two:
* Azure Enterprise Power Content Pack: https://powerbi.microsoft.com/en-us/documentation/powerbi-content-pack-azure-enterprise/
* Something custom which extracts data from the EA and puts it somewhere Power BI online can get it

Now the content pack definately has its advantages. For one it's dead easy. You just need your enrollment number and API key and off you go. Even with the free Power BI you're good to go! Now there's a downside to this story. One thing which I find a pity is that you can't use Power BI Desktop to edit your reports. You can only work from the Power BI online tooling. I guess this is a limitation which is acceptable. 
The biggest problem I see however is the tags data. Typically people use tags in Azure Resource Management next to Resource Groups to divide resources in buckets. Tags might also be used for automation purposes. Take the following as an example: a VM is tagged with Environment: DEV, Application: ERP. Now in Power BI you might want to have a report that shows you the costs for all applications belonging to ERP. Or maybe the DEV environment. However here's how the Tags column looks like in Power BI Online: 
* {"Environment":"DEV","Application":"ERP"}.

Yep, that's JSON. Wouldn't you hope/expect additional columns like Environment and Application to be there? That would allow you to do things like these:

<insert screeny>

By creating something custom we can achieve this. The solution in this repostory uses the following components:

* Azure EA Rest API: allows you to periodically retrieve the usage data for a given month
* Azure Storage Account: allows you to store the retrieve data and access it from both Power BI Desktop and Power BI Online
* Azure Automation: allows you to run PowerShell scripts on a regular base.
* Power BI Desktop: allows you to do all kinds of funky things with the data before making it available to your reports
* Power BI Online: allows you to periodically refresh the data so the reports are always up to date. Power BI online also provides you with dashboards, altering and publishing capabilities.

Here's how you can get started.

## Azure EA

Log in to the Azure EA Portal (https://ea.azure.com) and get:

* EA Enrollment number: 123456789
* EA API key: xxxx

## Azure

Log in to the Azure Portal (https://portal.azure.com) or use another way to perform the following steps:

### Storage Account

Create a storage account and a container on that storage account. Note down the following items:

* Storage account name: e.g. contosolrseadata
* Container name: e.g. usagedata
* Storage account key: yyyy

If you like to use an existing storage account that's fine. Just make sure you have a container dedicated to the usage data. And keep in mind that both the automation script and Power BI online have full access to the storage account because we will use the key in those.

### Azure Automation Runbook

Now create a new or use an existing **Azure Automation account**. In that Automation Account we we'll setup a PowerShell script that will run regulary. The script can be found in this repository: Download-EA-UsageData.ps1 (https://github.com/tvuylsteke/azure-ea-powerbi/blob/master/Download-EA-UsageData.ps1). When creating the runbook you can pick regular PowerShell and copy paste the contents of the Download-EA-UsageData.ps1 script.

Next up is setting up the required **Automation Variables**. We'll have variables for the following items:
* EA Enrollment number
* EA API key
* Azure Storage Account
* Container
* Azure Storage Account key

You can open the Configure-for_Download-EA-UsageData.ps1 (https://github.com/tvuylsteke/azure-ea-powerbi/blob/master/Configure-for_Download-EA-UsageData.ps1) using your favorite text editor and fill in the required values. Then execute the commands against your Azure subscription. We're using PowerShell for this because it's easy and it avoids the limitation of the GUI with regards to the maximum lenght variables can have.

In order for the script to run periodically we need to create some schedules. Based on your needs you could tweak the following proposal:

* Schedule #1: daily at 5:00: no parameters
* Schedule #2: once every month on the first of the month at 6:00: parameter runForPreviousMonth set to $true

The 2nd schedule asures when we start a new month we don't have a gap of 5:00 till the end of the day for the previous month. We could also schedule our first schedule at 23:59, but I'm not sure the EA data is updated that fast.

## Power BI Desktop

Start a new Power BI Desktop instance. Click Get Data and choose **Blank Query**. A second screen should open up. Choose Advanced Editor and copy paste the code from the PowerBI-EA-UsageData.m (https://github.com/tvuylsteke/azure-ea-powerbi/blob/master/PowerBI-EA-UsageData.m) file. The only thing you need to replace is setspnpowerbi with the name of your storage account on the 2nd line.






