# Visualize Azure Express Route Statistics

One of the things which bothered me for a while is that it's pretty hard to get an idea of how many data is being transfered accross the Express Route circuit. The Azure Portal shows you the following counters: 

![Alt text](../IMG/ExpressRoute-portal.png?raw=true)

But that's all there is. They are counters and go up every once in a while. Pretty hard to keep track of it are see trends/anomalies. Power BI to the rescue again! This one is not as complex to build but I did got a push that helped me achieve my goal. Here's the endresult:

* Showing the data in a graph
![Alt text](../IMG/ExpressRoute-Report1.png?raw=true)

* Showing the data in a table
![Alt text](../IMG/ExpressRoute-Report2.png?raw=true)

* Showing the data in a stacked graph
![Alt text](../IMG/ExpressRoute-Report3.png?raw=true)

In order to visualize the data in Power BI we need a source. The source will be a CSV file that is stored on a storage account in Azure. The CSV file itself will be maintained by an Azure Automation job that runs every 3 hours. You could have it run more often, but my data showed me that the counters don't refresh much more than that. So running the script more is pointless.

The script can be found here: [ExpressRouteStatistics.ps1](ExpressRouteStatistics.ps1)

This script is a bit more rough than the other things I've uploaded here. I leave it up to you to tweak it to your likings. I access the storage account using a key and the get-AzureRmExpressRouteCircuitStatistics using the Automation credential. So in theory I could use the credential for both. The timestamp that's being written might also be a bit off depending on your timezone. And maybe you have multiple peerings/circuits and you need all of those. So if you want to polish all that, be my guest.

Once you have the script up an running you should have a CSV file with 5 columns:

* PrimaryBytesIn
* PrimaryBytesOut
* SecondaryBytesIn
* SecondaryBytesOut 
* TimeStamp

We need to add a new source (blank query) to the Power Bi Desktop file. Use the following m query: [ExpressRouteStatisticsSource.m](ExpressRouteStatisticsSource.m)
Make sure to replace the storage account name on the 2nd line with your storage account. The query is pretty much just clicked together from the UI. Maybe pay attention to the date. It might need some tweaking.

The result is something like this:

![Alt text](../IMG/ExpressRoute-Source.png?raw=true)

Now we have the counters, but we need to get the delta's. We can do that using the following columns:

* PrimaryBytesIn Difference = 
 'ExpressRouteCounters'[PrimaryBytesIn] - IF(
  'ExpressRouteCounters'[Index] = 0;
  'ExpressRouteCounters'[PrimaryBytesIn];
  LOOKUPVALUE(
   'ExpressRouteCounters'[PrimaryBytesIn];
   'ExpressRouteCounters'[Index];
   'ExpressRouteCounters'[Index]-1)
 )

 * PrimaryBytesOut Difference = 
 'ExpressRouteCounters'[PrimaryBytesOut] - IF(
  'ExpressRouteCounters'[Index] = 0;
  'ExpressRouteCounters'[PrimaryBytesOut];
  LOOKUPVALUE(
   'ExpressRouteCounters'[PrimaryBytesOut];
   'ExpressRouteCounters'[Index];
   'ExpressRouteCounters'[Index]-1)
 )

 * SecondaryBytesIn Difference = 
 'ExpressRouteCounters'[SecondaryBytesIn] - IF(
  'ExpressRouteCounters'[Index] = 0;
  'ExpressRouteCounters'[SecondaryBytesIn];
  LOOKUPVALUE(
   'ExpressRouteCounters'[SecondaryBytesIn];
   'ExpressRouteCounters'[Index];
   'ExpressRouteCounters'[Index]-1)
 )
 
* SecondaryBytesOut Difference = 
 'ExpressRouteCounters'[SecondaryBytesOut] - IF(
  'ExpressRouteCounters'[Index] = 0;
  'ExpressRouteCounters'[SecondaryBytesOut];
  LOOKUPVALUE(
   'ExpressRouteCounters'[SecondaryBytesOut];
   'ExpressRouteCounters'[Index];
   'ExpressRouteCounters'[Index]-1)
 )

I prefer working with GB instead of Bytes so I added some more columns. I could probably have combined that in the previous columns, but I didn't want to make the query all too complex.

* PrimaryGBin = Round('ExpressRouteCounters'[PrimaryBytesIn Difference] / 1024 / 1024 / 1024;1)
* PrimaryGBout = Round('ExpressRouteCounters'[PrimaryBytesOut Difference] / 1024 / 1024 / 1024;1)
* SecondaryGBin = Round('ExpressRouteCounters'[SecondaryBytesIn Difference] / 1024 / 1024 / 1024;1)
* SecondaryGBout = Round('ExpressRouteCounters'[SecondaryBytesOut Difference] / 1024 / 1024 / 1024;1)

I've also hidden a few columns from the Report View. You can do so by right-click the column and choose Hide in Report View. I did that for:

* PrimaryBytesIn
* PrimaryBytesOut
* SecondaryBytesIn
* SecondaryBytesOut
* PrimaryBytesIn Difference
* PrimaryBytesOut Difference
* SecondaryBytesIn Difference
* SecondaryBytesOut Difference
* Index

This is the result:

![Alt text](../IMG/ExpressRoute-Data.png?raw=true)

All what's left is to make some visualization to your likings. I've added some examples at the top of this page.

# Credits

Last but not least: credits are due! I quickly had my data in a CSV file but I struggled on how to get the delta columns. Luckily [@kvaes](https://twitter.com/kvaes) first pointed me to the fact that was I was trying to do was a "reverse running total". And after a good night of sleep I had an email from him with this link: [http://ignoringthevoices.blogspot.be/2016/02/comparing-with-previous-row-using.html](http://ignoringthevoices.blogspot.be/2016/02/comparing-with-previous-row-using.html) from [@dazfuller](https://twitter.com/dazfuller). With that excellent writeup it was easy peasy! Thanks for sharing!