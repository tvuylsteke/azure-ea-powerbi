# Visualize Azure EA Usage Data with Power BI: One API Call

## Power BI Desktop

With the EA details (enrollment number and API key) we can start setting up the data sources within Power Bi. For this approach we'll communicate directly with the EA API. This approach is rather simple as we only need one data source and no intermediate components. The only downside is that it will retrieve all data and then filter. The consequence is that refreshing might take quite some time. When authoring the report that can be seen as a nuisance. Once uploaded to Power Bi online this should be less important.

### Set Up The Data Source

* Open Power BI Desktop. 
* Click Get Data and choose **Blank Query**. A second window should open up. 
* Choose Advanced Editor and copy paste the code from the [PowerBI-EA-UsageData-v2.m](PowerBI-EA-UsageData-v2.m) file. 
* Replace the **EA Enrollment Number** on the 2nd line (1234567 in the sample code) 
* The line that starts with #"Setup: Filtered Rows" (line 9) controls how many months are made available. The sample currently takes 12 months into account, including the current month.
* Click done in the advanced editor
* You'll see a yellow bar asking you to specify credentials to connect. Click Edit Credentials.
* Copy paste the **EA API Key** you copied earlier
* Now it should refresh and load your data
* Provide a name for the query: e.g. Azure Usage Data
* Close the query window and click yes when asked to apply query changes