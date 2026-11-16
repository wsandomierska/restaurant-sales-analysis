// Query name: menu_items
// Change DataFolder to the folder containing the original CSV files.
let
    DataFolder = "/path/to/Restaurant Orders/",
    Source = Csv.Document(File.Contents(DataFolder & "menu_items.csv"),
        [Delimiter = ",", Columns = 4, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
    // Promote headers and assign data types using the source locale.
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    TypedColumns = Table.TransformColumnTypes(PromotedHeaders,
        {{"menu_item_id", Int64.Type}, {"item_name", type text},
         {"category", type text}, {"price", Currency.Type}}, "en-US"),
    // Ensure one record per menu item identifier.
    RemovedDuplicates = Table.Distinct(TypedColumns, {"menu_item_id"})
in
    RemovedDuplicates
