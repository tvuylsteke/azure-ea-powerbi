# Visualize Azure EA Usage Data with Power BI

This repository contains some scripts you can use to get the usage data of an Azure Enterprise Agreement (EA) into Power BI. In order to get this data into Power BI there are several options.
* Use the [Azure Enterprise Power Content Pack](https://powerbi.microsoft.com/en-us/documentation/powerbi-content-pack-azure-enterprise/)
* Do it yourself.

Now the content pack definitely has its advantages. For one it's dead easy. You just need your enrollment number and API key and off you go. Even with the free Power BI edition you're good to go! Now there's a downside to this story. One thing which I find a pity is that you can't use Power BI Desktop to edit your reports or shape your data. You can only work from the Power BI online interface. That alone could be acceptable.

But the biggest problem I see and hear about is the tags data. Typically people use tags in Azure Resource Management, next to Resource Groups, to divide resources in buckets. Tags might also be used for automation purposes. Take the following as an example: a VM is tagged with Environment: DEV and maybye Application: ERP. Now in Power BI you might want to have a report that shows you the costs for all resources belonging to the ERP application. Or maybe the DEV environment. However here's how the Tags column looks like in Power BI online: 

* {"Environment":"DEV","Application":"ERP"}.

Yep, that's JSON. The data in that format is basically useless within Power BI online. If we'd have additional columns like Environment and Application we could do things like this:

![Alt text](../IMG/PowerBIDesktop.png?raw=true)

The script on this repository does that. The V1 folder contains my previous attempt at tackling this challenge. While it's working fine it requires additional services like Azure Automation and an Azure Storage Account. Eventually I found out I could get rid of all this and just use the following components:

* Azure EA Rest API: allows you to download the usage data
* Power BI Desktop: allows you to do all kinds of funky things with the data before making it available to your reports
* Power BI Online: allows you to periodically refresh the data so the reports are always up to date. Power BI online also provides you with dashboards, alerting and publishing capabilities.

Here's how you can get started:

## Azure EA

Log in to the Azure EA Portal (https://ea.azure.com) and get your:

* EA Enrollment number: e.g. 123456789
* EA API key: xxxx

## Power BI Desktop

Now that we have configured the automated download of the usage data it's to get the Power BI part up and running. Using the M query language we will read all CSV files we find in the container and shape the data so that it can be used within our reports.

### Set Up The Data Source

* Open Power BI Desktop. 
* Click Get Data and choose **Blank Query**. A second window should open up. 
* Choose Advanced Editor and copy paste the code from the [PowerBI-EA-UsageData-v2.m](/PowerBI-EA-UsageData-v2.m) file. 
* Replace the **EA Enrollment Number** on the 2nd line (1234567 in the sample code) 
* The line that starts with #"Setup: Filtered Rows" (line 9) controls how many months are made available. The sample currently takes 12 months into account, including the current month.
* Click done in the advanced editor
* You'll see a yellow bar asking you to specify credentials to connect. Click Edit Credentials.
* Copy paste the **EA API Key** you copied earlier
* Now it should refresh and load your data
* Provide a name for the query: e.g. Azure Usage Data
* Close the query window and click yes when asked to apply query changes

### Report

Once you have the data source ready you can go ahead and create reports. Once you're doing creating the reports click File -> Publish -> **Publish to Power BI**. The filename of the Power BI Desktop file will be used for both the report and dataset name in Power BI.

## Power BI

The first thing you'll want to do is ensure your data is refreshed regularly. Even with the Power BI free version you can have a daily refresh. 

* Right-click your dataset and choose **Schedule Refresh**
* You'll see a warning regarding the data source credentials. Click edit and provide the EA API key again
* Click Schedule Refresh and configure it as you like
* Now you can start creating dashboards

Here's a very basic example of a dashboard. I wanted to show this particular example as it demonstrates the usage of Power BI alerts. 

![Alt text](../IMG/PowerBIAlert.png?raw=true)

## Notes

Some general notes and random thoughts:

* **The EA API Key is limited in time!** While keys seem like an easy way to provide access to another service, make sure you know where and when to update the key so that everything keeps running. In our current setup we'll need to update the key in Power BI online. Updating the key used by the Power BI Desktop will only be necessary when we're doing updates to our reports.

* Apply tags retroactively. I've heard this a few times. People start with tagging resources but come to conclusion that this only applies to the usage data from that moment on. For now the M query provided does not solve this problem. But I guess the query could be extended to do that.