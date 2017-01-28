# Visualize Azure EA Usage Data with Power BI: Data Date

One of the questions you often see in Power BI fora is how to display a date on a report showing when the last refresh happened. To be honest, with the EA dataset I'm more interested in knowing what the most recent date is in the returned dataset. Using the instructions below you'll be able to do just that. This is how the visual will look like:

![Alt text](../IMG/PowerBI-refresh.png?raw=true)

## Power BI Desktop

This configuration happens within Power BI Desktop

### Set Up Data Source

* Open Power BI Desktop. 
* Click Get Data and choose **Blank Query**. A second window should open up. 
* Choose Advanced Editor and copy paste the code from the [PowerBI-EA-DataDate.m](PowerBI-EA-DataDate-v1.m) file. 
* Replace the **EA Enrollment Number** on the 3th line (1234567 in the sample code) 
* Click done in the advanced editor
* Name the query: "Most Recent Data Date"

### Set Up The Measure

This is where I'm lacking some Power BI knowledge. While the data source shows the correct date, I cannot get the card visual to display it correctly. For some reason the visual is only willing to apply the Summarize Count or Count Distinct. As a workaround, or mabye a requirement, I added a measure.

* Close the Query Editor
* Select the "Most Recent Data Date" data source
* Click New Measure
* Copy paste this in the function bar: Most Recent Data Date = FORMAT(LASTDATE('Most Recent Data Date'[Date]),"mmm dd, yyyy")

### Set Up Visualisation

In the last step we'll add the card to a report so that we can display the date.

* Go to the Report View
* Click the page where you want to add the date
* Click the Card visual
* Drag and drop the "Most Recent Data Date" measure from the "Most Recent Data Date" datasource to the Fields value
