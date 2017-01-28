(YearMonth as text) as table =>
let
    report = Table.FromColumns({Lines.FromBinary(Binary.Buffer(AzureEnterprise.Contents("https://ea.azure.com/rest/1234567/usage-report", [month=YearMonth, type="detail", fmt="Csv"])),null,null,1252)}),
    skips = Table.Skip(report, 2),
    split =  Table.SplitColumn(skips, "Column1", Splitter.SplitTextByDelimiter(",", QuoteStyle.Csv)),
    promoted = Table.PromoteHeaders(split)
in
    promoted