let
    #"Setup: Source" = AzureStorage.Blobs("https://contosostoraccount.blob.core.windows.net"),
    #"Setup: Usagedata Contents" = #"Setup: Source"{[Name="expressrouteusagedata"]}[Data],
    #"Setup: Combined Binaries" = Binary.Combine(#"Setup: Usagedata Contents"[Content]),
    #"Setup: Imported CSV" = Csv.Document(#"Setup: Combined Binaries",[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Setup: Promoted Headers" = Table.PromoteHeaders(#"Setup: Imported CSV"),
    #"Changed Type1" = Table.TransformColumnTypes(#"Setup: Promoted Headers",{{"PrimaryBytesIn", type number}, {"PrimaryBytesOut", type number}, {"SecondaryBytesIn", type number}, {"SecondaryBytesOut", type number}}),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Changed Type1","TimeStamp",Splitter.SplitTextByDelimiter("_", QuoteStyle.Csv),{"TimeStamp.1", "TimeStamp.2"}),
    #"Replaced Value" = Table.ReplaceValue(#"Split Column by Delimiter","-",":",Replacer.ReplaceText,{"TimeStamp.2"}),
    #"Merged Columns" = Table.CombineColumns(#"Replaced Value",{"TimeStamp.1", "TimeStamp.2"},Combiner.CombineTextByDelimiter(" ", QuoteStyle.None),"TimeStamp"),
    #"Changed Type" = Table.TransformColumnTypes(#"Merged Columns",{{"TimeStamp", type datetime}},"nl-BE"),
    //we're only keeping the date, no need for the time itself
    #"Extracted Date" = Table.TransformColumns(#"Changed Type",{{"TimeStamp", DateTime.Date}}),
    //in rare occasions the script executed but wasn't able to retrieve counters. This resulted in a blank row which messes up the numbers
    #"Filtered Rows" = Table.SelectRows(#"Extracted Date", each [PrimaryBytesIn] <> null and [PrimaryBytesOut] <> null and [SecondaryBytesIn] <> null and [SecondaryBytesOut] <> null),
    #"Added Index" = Table.AddIndexColumn(#"Filtered Rows", "Index", 0, 1)
in
    #"Added Index"