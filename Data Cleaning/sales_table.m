let
    // Extracted the sales data from the CSV source.
    #"Source Data" = Csv.Document(File.Contents("your_file_path.csv"),[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Changed types for all value columns to text for unpivoting
    #"Changed Type To Text" = Table.TransformColumnTypes(
        #"Source Data",
        {
            {"Field_Name", type text}, 
            {"Value1", type text}, 
            {"Value2", type text}, 
            {"Value3", type text}, 
            {"Value4", type text}, 
            {"Value5", type text}
        }
    ),

    // Unpivoted the value columns so each row had a Field_Name and Value
    #"Unpivoted Values" = Table.UnpivotOtherColumns(
        #"Changed Type To Text", 
        {"Field_Name"}, 
        "Attribute", 
        "Value"
    ),

    // Removed the Attribute column
    #"Removed Attribute Column" = Table.RemoveColumns(#"Unpivoted Values", {"Attribute"}),

    // Grouped rows by Field_Name to prepare for adding an index
    #"Grouped By Field" = Table.Group(
        #"Removed Attribute Column", 
        {"Field_Name"}, 
        {{"Values Table", each _, type table [Field_Name=nullable text, Value=text]}}
    ),

    // Added an index to each grouped table to preserve order
    #"Added Index In Groups" = Table.AddColumn(
        #"Grouped By Field",
        "Values With Index",
        each Table.AddIndexColumn([Values Table], "Index", 1, 1, Int64.Type)
    ),

    // Removed the original grouped table, kept only indexed version
    #"Removed Original Values" = Table.RemoveColumns(#"Added Index In Groups", {"Field_Name", "Values Table"}),

    // Expanded the indexed tables back into a single table
    #"Expanded Indexed Values" = Table.ExpandTableColumn(
        #"Removed Original Values",
        "Values With Index",
        {"Field_Name", "Value", "Index"},
        {"Field_Name", "Value", "Index"}
    ),

    // Pivoted the table back to wide format using Field_Name as columns
    #"Pivoted Columns" = Table.Pivot(
        #"Expanded Indexed Values",
        List.Distinct(#"Expanded Indexed Values"[Field_Name]),
        "Field_Name",
        "Value"
    ),

    // Removed the Index column
    #"Removed Index Column" = Table.RemoveColumns(#"Pivoted Columns", {"Index"}),

    // Changed types for each column as appropriate
    #"Changed Column Types" = Table.TransformColumnTypes(
        #"Removed Index Column",
        {
            {"Sale_ID", type text},
            {"Customer_ID", type text},
            {"Product_ID", type text},
            {"Product_Category", type text},
            {"Store_ID", type text},
            {"Region", type text},
            {"Quantity_Sold", Int64.Type},
            {"Payment_Method", type text},
            {"Unit_Price", type number},
            {"Returned", type text},
            {"Total_Sale_Amount", type number},
            {"Sale_Date", type text} // kept as text initially for safe conversion
        }
    ),

    // Converted Excel-style numeric dates in Sale_Date to proper date
    #"Converted Sale Date" = Table.TransformColumns(
        #"Changed Column Types",
        {{"Sale_Date", each try 
            if _ = null or Text.Trim(_) = "" 
            then null 
            else Date.AddDays(#date(1899, 12, 30), Number.FromText(Text.Trim(_))) 
        otherwise null, type date}}
    )

in
    #"Converted Sale Date"
