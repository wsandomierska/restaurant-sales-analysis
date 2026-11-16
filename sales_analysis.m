// Query name: sales_analysis
// Requires a separate query named menu_items.
// Change DataFolder to the folder containing the original CSV files.
let
    DataFolder = "/path/to/Restaurant Orders/",
    Source = Csv.Document(File.Contents(DataFolder & "order_details.csv"),
        [Delimiter = ",", Columns = 5, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
    // Promote headers and assign data types using the source locale.
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    TypedColumns = Table.TransformColumnTypes(PromotedHeaders,
        {{"order_details_id", Int64.Type}, {"order_id", Int64.Type},
         {"order_date", type date}, {"order_time", type time},
         {"item_id", Int64.Type}}, "en-US"),
    // Remove duplicate order line identifiers.
    RemovedDuplicates = Table.Distinct(TypedColumns, {"order_details_id"}),
    // Retain all order lines, including those with missing item IDs.
    MergedMenu = Table.NestedJoin(RemovedDuplicates, {"item_id"},
        menu_items, {"menu_item_id"}, "menu_items", JoinKind.LeftOuter),
    ExpandedMenu = Table.ExpandTableColumn(MergedMenu, "menu_items",
        {"item_name", "category", "price"}, {"item_name", "category", "price"}),
    // Derive weekday and hour without changing the original date and time.
    AddedWeekday = Table.AddColumn(ExpandedMenu, "day_of_week",
        each Date.DayOfWeekName([order_date], "en-US"), type nullable text),
    AddedHour = Table.AddColumn(AddedWeekday, "order_hour",
        each Time.Hour([order_time]), Int64.Type),
    // Flag missing item IDs; leave unknown prices unchanged.
    AddedQualityStatus = Table.AddColumn(AddedHour, "data_quality_status",
        each if [item_id] = null then "missing item" else "valid", type text),
    ReorderedColumns = Table.ReorderColumns(AddedQualityStatus,
        {"order_details_id", "order_id", "order_date", "day_of_week",
         "order_time", "order_hour", "item_id", "item_name", "category",
         "price", "data_quality_status"})
in
    ReorderedColumns
