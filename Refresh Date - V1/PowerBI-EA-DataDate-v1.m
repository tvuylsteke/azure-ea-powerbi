let
    Source =  #"Usage Detail",
    #"Calculated Latest" = List.Max(Source[ConsumptionDate]),
    #"Converted to Table" = #table(1, {{#"Calculated Latest"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table",{{"Column1", type date}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1", "Date"}})
in
    #"Renamed Columns"
