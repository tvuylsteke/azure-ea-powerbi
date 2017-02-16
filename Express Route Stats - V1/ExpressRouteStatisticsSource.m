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
    #"Added Index" = Table.AddIndexColumn(#"Changed Type", "Index", 0, 1)
in
    #"Added Index"