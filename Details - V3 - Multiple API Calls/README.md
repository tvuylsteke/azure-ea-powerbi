# Visualize Azure EA Usage Data with Power BI: Multiple API Calls

## Power BI Desktop

With the EA details we can start setting up the data sources within Power Bi. For this approach we'll need to data sources: a function and a data set. This approach should be more performant as we'll only retrieve the months we are interested. The V2 approach first retrieves all available data and then only considers the months we care about. Once the report is upload to Power BI Online it might not really matter. But for editting this should be a huge improvement.

### Set Up Function

* Open Power BI Desktop. 
* Click Get Data and choose **Blank Query**. A second window should open up. 
* Choose Advanced Editor and copy paste the code from the [PowerBI-EA-UsageData-function-v3.m](PowerBI-EA-UsageData-function-v3.m) file. 
* Replace the **EA Enrollment Number** on the 3th line (1234567 in the sample code) 
* Click done in the advanced editor
* Name the query: "getEAUsageData"

### Set Up The Data Source

* Click Get Data and choose **Blank Query**. A second window should open up. 
* Choose Advanced Editor and copy paste the code from the [PowerBI-EA-UsageData-v3.m](PowerBI-EA-UsageData-v3.m) file.
* The line that starts with #"Date Range List" (line 2) controls how many months are made available. The sample currently takes 14 months into account, including the current month.
* Click done in the advanced editor
* You'll see a yellow bar asking you to specify credentials to connect. Click Edit Credentials.
* Copy paste the **EA API Key** you copied earlier
* Now it should refresh and load your data
* Provide a name for the query: "Usage Detail"
* Close the query window and click yes when asked to apply query changes

### Report

The instructions and tips for visualization are on the homepage of this project.