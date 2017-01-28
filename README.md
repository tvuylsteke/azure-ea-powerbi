# Visualize Azure EA Usage Data with Power BI

This repository contains some scripts you can use to get the usage data of an Azure Enterprise Agreement (EA) into Power BI. In order to get this data into Power BI there are several options.
* Use the [Azure Enterprise Power Content Pack](https://powerbi.microsoft.com/en-us/documentation/powerbi-content-pack-azure-enterprise/)
* Do it yourself.

Now the content pack definitely has its advantages. For one it's dead easy. You just need your enrollment number and API key and off you go. Even with the free Power BI edition you're good to go! Now there's a downside to this story. One thing which I find a pity is that you can't use Power BI Desktop to edit your reports or shape your data. You can only work from the Power BI online interface. That alone could be acceptable.

But the biggest problem I see and hear about is the tags data. Typically people use tags in Azure Resource Management, next to Resource Groups, to divide resources in buckets. Tags might also be used for automation purposes. Take the following as an example: a VM is tagged with Environment: DEV and maybye Application: ERP. Now in Power BI you might want to have a report that shows you the costs for all resources belonging to the ERP application. Or maybe the DEV environment. However here's how the Tags column looks like in Power BI online: 

* {"Environment":"DEV","Application":"ERP"}.

Yep, that's JSON. The data in that format is basically useless within Power BI online. If we'd have additional columns like Environment and Application we could do things like this:

![Alt text](/IMG/PowerBIDesktop.png?raw=true)

The scripts on this repository does that. The "Details - V1" folder contains my first attempt at tackling this challenge. While it's working fine it requires additional services like Azure Automation and an Azure Storage Account. Eventually I found out I could get rid of all this and just use the following components:

* Azure EA Rest API: allows you to download the usage data
* Power BI Desktop: allows you to do all kinds of funky things with the data before making it available to your reports
* Power BI Online: allows you to periodically refresh the data so the reports are always up to date. Power BI online also provides you with dashboards, alerting and publishing capabilities.

Here's how you can get started:

## Azure EA

Log in to the Azure EA Portal (https://ea.azure.com) and get your:

* EA Enrollment number: e.g. 1234567
* EA API key: xxxx

## Power BI Desktop

Depending on the size of your environment you can choose which appraoch to follow:

* Simple filtering: [PowerBI-EA-UsageData-v2](/Details - V2 - One API Call/README.md) 
* Filter before getting data: [PowerBI-EA-UsageData-v3](/Details - V3 - Multiple API Calls/README.md) 

### Report

Once you have the data source ready you can go ahead and create reports. Once you're doing creating the reports click File -> Publish -> **Publish to Power BI**. The filename of the Power BI Desktop file will be used for both the report and dataset name in Power BI.

## Power BI

The first thing you'll want to do is ensure your data is refreshed regularly. Even with the Power BI free version you can have a daily refresh. 

* Right-click your dataset and choose **Schedule Refresh**
* You'll see a warning regarding the data source credentials. Click edit and provide the EA API key again
* Click Schedule Refresh and configure it as you like
* Now you can start creating dashboards

Here's a very basic example of a dashboard. I wanted to show this particular example as it demonstrates the usage of Power BI alerts. 

![Alt text](/IMG/PowerBIAlert.png?raw=true)

## Notes

Some general notes and thoughts:

* **The EA API Key is limited in time!** While keys seem like an easy way to provide access to another service, make sure you know where and when to update the key so that everything keeps running. In our current setup we'll need to update the key in Power BI online. Updating the key used by the Power BI Desktop will only be necessary when we're doing updates to our reports.

* Apply tags retroactively. I've heard this a few times. People start with tagging resources but come to conclusion that this only applies to the usage data from that moment on. For now the M query provided does not solve this problem. But I guess the query could be extended to do that.

* **Performance** While I was very satisfied that I was able to talk directly to the API, I'm not so sure it's the best solution. Especially when editting the M query the performance feels worse then when working with CSV files. Personally I'll need to work a bit more with it to make up my mind. I believe there's a clear difference between authoring the data and reports and afterwards consuming it on Power BI. The first one can be slower or maybe using a workaround by pointing to a local CSV until you're happy with the result. The latter you'd expect to be responsive.

## ChangeLog

[2017/01/05] I've added a filter for the tags that are expanded. Some people mentioned that somewhere along the line tags are added that are not visible within Azure. These all start with "Hidden-" The following line removes these and prevents the columns being added. 

"Tags: Filtered FieldNames" = List.Select(#"Tags: FieldNames", each not Text.StartsWith(_,"Hidden-")),

[2017/01/27] I've moved the PowerBI-EA-UsageData-v2 to a separate folder and added the V3 one. The V3 one is very similar to the V2 one however this one uses a function. The advantage is that the function only retrieves the data that you ask for.

[2017/01/28] I've added a script to get the EA summary data and a data source to show the last date of the data in the retrieved set.