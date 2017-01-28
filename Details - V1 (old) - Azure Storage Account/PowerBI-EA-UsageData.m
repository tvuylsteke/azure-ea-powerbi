let
    #"Setup: Source" = AzureStorage.Blobs("https://setspnpowerbi.blob.core.windows.net"),
    #"Setup: Usagedata Contents" = #"Setup: Source"{[Name="usagedata"]}[Data],
    #"Setup: Combined Binaries" = Binary.Combine(#"Setup: Usagedata Contents"[Content]),
    #"Setup: Imported CSV" = Csv.Document(#"Setup: Combined Binaries",[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Setup: Promoted Headers" = Table.PromoteHeaders(#"Setup: Imported CSV"),
    //we only need to change the type for non-text columns
    #"Setup: Changed Type Localized" = Table.TransformColumnTypes(#"Setup: Promoted Headers",{{"SubscriptionId", Int64.Type}, {"Month", Int64.Type}, {"Day", Int64.Type}, {"Year", Int64.Type}, {"Consumed Quantity", type number}, {"ResourceRate", type number},{"Date", type date},{"ExtendedCost", type number}},"en-US"),
    // each CSV that is imported contributes one header row, we need to remove those
    #"Setup: Filter Duplicate Header Rows" = Table.SelectRows(#"Setup: Changed Type Localized", each [SubscriptionGuid] <> "SubscriptionGuid"),
    //further down we'll expand the Tags column. In order to keep the original column we'll take a copy of it first
    #"Tags: Duplicated Column" = Table.DuplicateColumn(#"Setup: Filter Duplicate Header Rows", "Tags", "Tags - Copy"),
    //We need to pouplate the empty json tag {} for values that are blank
    #"Tags: Replace Empty Value" = Table.ReplaceValue(#"Tags: Duplicated Column","","{}",Replacer.ReplaceValue,{"Tags - Copy"}),
    //sometimes tags might have different casings due to erroneous input (e.g. Environment and environment). Here we convert them to Proper casing
    #"Tags: Capitalized Each Word" = Table.TransformColumns(#"Tags: Replace Empty Value",{{"Tags - Copy", Text.Proper}}),    
    //convert the content of the Tags column to JSON records
    #"Tags: in JSON" = Table.TransformColumns(#"Tags: Capitalized Each Word",{{"Tags - Copy", Json.Document}}),
    //The next steps will determine a list of columns that need to be added and populated
    //the idea is to have a column for each tag key type
    //take the Tags column in a temp list variable
    //source of inspiration: https://blog.crossjoin.co.uk/2014/05/21/expanding-all-columns-in-a-table-in-power-query/
    #"Tags: Content" = Table.Column(#"Tags: in JSON", "Tags - Copy"),
    //for each of the Tags: take the fieldnames (key names) and add them to a list while removing duplicates
    #"Tags: FieldNames" = List.Distinct(List.Combine(List.Transform(#"Tags: Content", 
                        each Record.FieldNames(_)))),
    //this is the list of the actual column names. We're prepending Tag.'
    #"Tags: New Column Names" = List.Transform(#"Tags: FieldNames", each "Tag." & _),    
    //expand the JSON records using the fieldnames (keys) to new column names list mapping
    #"Tags: Expanded" = Table.ExpandRecordColumn(#"Tags: in JSON", "Tags - Copy", #"Tags: FieldNames",#"Tags: New Column Names"),
    //create a column with the consumption date (instead of 3 separate columns)    
    #"Consumption Date: Added Column" = Table.AddColumn(#"Tags: Expanded", "ConsumptionDate", each Text.From([Month])&"/"&Text.From([Day])&"/"&Text.From([Year])),
    #"Consumption Date: Change to Date Type" = Table.TransformColumnTypes(#"Consumption Date: Added Column",{{"ConsumptionDate", type date}},"en-US"),
    //create a column with the amount of days ago the usage happened
    #"Date Difference: Added Column" = Table.AddColumn(#"Consumption Date: Change to Date Type", "DateDifference", each Duration.Days(Duration.From(DateTime.Date(DateTime.LocalNow())- [ConsumptionDate]))),
    #"Date Difference: Changed to Number Type" = Table.TransformColumnTypes(#"Date Difference: Added Column",{{"DateDifference", type number}}),
    //create a friendly name for resource (as an alternative to the instance ID which is quite long)
    #"Resource Name: Duplicate Instance ID" = Table.DuplicateColumn(#"Date Difference: Changed to Number Type", "Instance ID", "Instance ID-TEMP"),
    #"Resource Name: Split Column" = Table.SplitColumn(#"Resource Name: Duplicate Instance ID","Instance ID-TEMP",Splitter.SplitTextByEachDelimiter({"/"}, QuoteStyle.Csv, true),{"Instance ID.1", "Instance ID.2"}),
    #"Resource Name: Construct Column" = Table.AddColumn(#"Resource Name: Split Column", "Resource Name", each if [Instance ID.2] = null then [Instance ID.1] else [Instance ID.2] ),
    #"Cleanup: Removed Undesired Columns" = Table.RemoveColumns(#"Resource Name: Construct Column",{"Instance ID.1", "Instance ID.2", "AccountOwnerId", "Account Name", "ServiceAdministratorId"})
in
    #"Cleanup: Removed Undesired Columns"
