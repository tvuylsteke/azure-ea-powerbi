let
    Source = AzureEnterprise.Tables("https://ea.azure.com/rest/1234567"),
    Summary = Source{[Key="Summary"]}[Data],
    #"NoHeaders" = Table.TransformColumns(Summary,{{"Data",each Table.DemoteHeaders(_) }}),
    #"SkipHeaders" = Table.TransformColumns(NoHeaders,{{"Data",each Table.Skip(_,1) }}),
    #"Expanded Data" = Table.ExpandTableColumn(SkipHeaders, "Data", {"Column1", "Column2", "Column3"}, {"Data.Column1", "Data.Column2", "Data.Column3"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded Data", each [Data.Column1] <> ""),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Data.Column2"}),
    #"Pivoted Column" = Table.Pivot(#"Removed Columns", List.Distinct(#"Removed Columns"[Data.Column1]), "Data.Column1", "Data.Column3"),
    #"Removed Columns1" = Table.RemoveColumns(#"Pivoted Column",{"SIE Credit"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns1",{{"Beginning Balance", type number}, {"New Purchases", type number}, {"Adjustments", type number}, {"Utilized ( subtracted from balance)", type number}, {"Ending Balance", type number}, {"Overage", type number}, {"Service Overage", type number}, {"Charges Billed Separately", type number}, {"Total Usage (Commitment Utilized + Overage)", type number}, {"Total Overage", type number}, {"Azure Marketplace Service Charges <br /> (Billed Separately)", type number}},"en-US")
in
    #"Changed Type"