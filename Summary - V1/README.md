# Visualize Azure EA Usage Data with Power BI: Summary

Once one of my customers got the hang of the EA usage details we could visualize he asked me whether we could also show some info regarding the EA balance. The EA API offers this data as well. The format is a bit of a challenge, but I managed to come up with something which convers to data to a single table that can be used to visualize the balance. Here is a sample graph showing the balance at the beginning and end of the month. The new purchaes and the adjustments.

![Alt text](../IMG/PowerBI-summary.png?raw=true)

## Power BI Desktop

This configuration happens within Power BI Desktop

### Set up the Data Source

* Open Power BI Desktop. 
* Click Get Data and choose **Blank Query**. A second window should open up. 
* Choose Advanced Editor and copy paste the code from the [PowerBI-EA-Summary-v1.m](PowerBI-EA-Summary-v1.m) file. 
* Replace the **EA Enrollment Number** on the 2nd line (1234567 in the sample code) 
* Click done in the advanced editor
* Name the query: "Usage Summary"

### Set up the Report

In the example I posted I used the following visual configuration. In order for the values to be summarized correctly by default I modified the default summarization for those columns to Sum in the Modeling section of the data source.

![Alt text](../IMG/PowerBI-summary-setup.png?raw=true)

## Notes

I must admit that I've only validated this approach against one EA. Maybe different EA have data that doesn't go well with this one. It was a lot more tricky to get the data in the way I liked it. I did drop the "SIE Credit" data as I didn't see I'd need it and it helped me avoid an error later down the path.

It might help to go step by step over this query so that you can preview the data and see if nothing unexpected happens.