# 📊 Measures & Calculations: Omniretail Business Analytics

This documentation provides a comprehensive overview of the DAX measures and calculations used for the Omniretail analysis. It outlines core financial KPIs, customer retention logic, and dynamic growth metrics used to drive business insights.

### **💰 Revenue & Volume Metrics**

* **Total Revenue**: The gross total value of all sales transactions generated before returns are deducted.
    * **Formula**: `SUM( Sales_Data[Total_Sale_Amount] )`
    * **Formatting**: `\$#,0;(\$#,0);\$#,0`


* **Net Revenue**: The actual realized income, calculated by filtering out all transactions where a return was processed.
    * **Formula**:
    
    
    ```dax
    CALCULATE(
        SUM( Sales_Data[Total_Sale_Amount] ),
        Sales_Data[Returned] = "No"
    )
    ```
    
    
    * **Formatting**: `\$#,0;(\$#,0);\$#,0`


* **Total Orders**: Measures transaction volume by counting unique Sale IDs.
    * **Formula**: `DISTINCTCOUNT(Sales_Data[Sale_ID])`
    * **Formatting**: `#,0`


* **Total Qty Sold**: The total count of physical units moved across all transactions.
    * **Formula**: `SUM(Sales_Data[Quantity_Sold])`
    * **Formatting**: `#,0`


* **Total Returns**: The count of unique transactions that resulted in a return.
    * **Formula**:
    
    
    ```dax
    CALCULATE(
        DISTINCTCOUNT( Sales_Data[Sale_ID] ),
        Sales_Data[Returned] = "Yes"
    )
    ```
    
    
    * **Formatting**: `#,0`


* **Total Return Amount**: The total financial value lost due to returned merchandise.
    * **Formula**:
    
    
    ```dax
    CALCULATE(
        SUM( Sales_Data[Total_Sale_Amount] ),
        Sales_Data[Returned] = "Yes"
    )
    ```
    
    
    * **Formatting**: `\$#,0;(\$#,0);\$#,0`



---

### **📉 Efficiency & Averages**

* **Avg Order Value (AOV)**: The average monetary value of a single customer transaction.
    * **Formula**: `DIVIDE([Total Revenue], [Total Orders], "N/A")`
    * **Formatting**: `\$#,0;(\$#,0);\$#,0`


* **Avg Unit Price**: The average price point of individual items sold.
    * **Formula**: `AVERAGE( Sales_Data[Unit_Price] )`
    * **Formatting**: General Number


* **Return Rate**: The percentage of total orders that result in a return.
    * **Formula**: `DIVIDE([Total Returns], [Total Orders], "N/A")`
    * **Formatting**: `#,0.00%;-#,0.00%;#,0.00%`



---

### **👥 Customer Health & Retention**

* **Total Customers**: Measures the unique reach of the business by counting distinct Customer IDs.
    * **Formula**: `DISTINCTCOUNT(Sales_Data[Customer_ID])`
    * **Formatting**: `#,0`


* **Monthly Retention Rate**: The percentage of customers who purchased in the previous month and returned to buy again in the current selected month.
    * **Formula**:
    
    
    ```dax
    -- 1. Identify customers who purchased in the prior month context
    VAR CustomersPrevMonth =
        CALCULATETABLE(
            VALUES('Sales_Data'[Customer_ID]),
            PREVIOUSMONTH('Calendar_Table'[Date])
        )
    -- 2. Identify customers active in the current selected month
    VAR CustomersCurrentMonth =
        CALCULATETABLE(
            VALUES(Sales_Data[Customer_ID]),
            'Calendar_Table'
        )
    -- 3. Perform Set Intersection to find returning individuals
    VAR RetainedCustomers =
        COUNTROWS(
            INTERSECT(CustomersPrevMonth, CustomersCurrentMonth)
        )
    VAR TotalPrevMonth =
        COUNTROWS(CustomersPrevMonth)
    RETURN
        IF(
            TotalPrevMonth = 0,
            BLANK(),
            DIVIDE(RetainedCustomers, TotalPrevMonth)
        )
    ```
    
    
    * **Formatting**: `0.00%;-0.00%;0.00%`


* **Avg Retention Rate**: A smoothed metric that calculates the average of monthly retention rates over the selected time period.
    * **Formula**:
    
    
    ```dax
    VAR RetentionTable =
        ADDCOLUMNS(
            SUMMARIZE(
                ALL( Calendar_Table ),
                Calendar_Table[Year],
                Calendar_Table[Month Name]
            ),
            "Retention Rate",
            [Monthly Retention Rate]
        )
    RETURN
        AVERAGEX(
            RetentionTable,
            [Retention Rate]
        )
    ```
    
    
    * **Formatting**: `0.00%;-0.00%;0.00%`


* **Customer Lifetime Value (CLV)**: A predictive metric estimating the total revenue a customer will generate based on their Average Order Value, Purchase Frequency, and calculated Churn Rate.
    * **Formula**: `[Avg Order Value] * [Customer Lifespan] * [Purchase Frequency]` *(See full DAX in file for Churn logic)*
    * **Formatting**: Currency (`$#,0.###############`)


* **Customer Recency Days**: The number of days elapsed since a customer's last purchase within the selected period. Used to identify dormant or at-risk customers.
    * **Formula**:
    
    
    ```dax
    -- Determine the reference date (usually the end of the selected slicer range)
    VAR SelectedPeriodEnd = MAX(Calendar_Table[Date])
    -- Find the absolute latest transaction date for the customer in context
    VAR LastPurchaseInRange =
        CALCULATE(
            MAX(Sales_Data[Sale_Date]),
            KEEPFILTERS(Calendar_Table) -- Ensure slicers are respected strictly
        )
    RETURN
        IF(
            ISBLANK(LastPurchaseInRange),
            "‎",
            DATEDIFF(LastPurchaseInRange, SelectedPeriodEnd, DAY)
        )
    ```
    
    
    * **Formatting**: `0` (Decimal)



---

### **📈 Month-over-Month (MoM) Growth Metrics**

Used for tracking performance trends. The logic includes a `SWITCH` statement to handle context: if no specific month is selected, it compares the latest available month to the previous one.

* **Measures Applied**: Revenue, Total Orders, Total Qty Sold, AOV, CLV, Retention Rate, Return Amount, Return Rate, Total Customers.
    * **General Logic Pattern**:
    ```dax
    VAR CurrentVal = [Measure]
    VAR PrevMonthVal =
        SWITCH( TRUE(),
            -- Strategy Case 1: Handle default dashboard view (no specific filter)
            NumYears = 0 && NumMonths = 0,
            CALCULATE([Measure], DATEADD(Calendar_Table[Date], -1, MONTH)),
    
            -- Strategy Case 2: Handle specific single-month selection
            NumYears = 1 && NumMonths = 1,
            CALCULATE([Measure], DATEADD(Calendar_Table[Date], -1, MONTH)),
    
            BLANK()
        )
    -- Calculate percentage variance
    RETURN DIVIDE(CurrentVal - PrevMonthVal, PrevMonthVal)
    ```


    * **Formatting**: Uses Dynamic Format Strings with `UNICHAR` arrows.
        * **Growth**: `UNICHAR(129157)` (▲)
        * **Decline**: `UNICHAR(129158)` (▼)



---

### **🏆 Dynamic Rankings (Text Generation)**

These measures return a text string listing the **Top 5 Customer IDs** based on specific performance metrics. These are used for "Hall of Fame" style visuals or dynamic tooltips.

* **Metrics Ranked**: AOV, Net Revenue, Purchase Count, Return Rate, Total Amount Spent.
    * **Formula Pattern**:
    ```dax
    CONCATENATEX(
        -- Identify the top 5 entities based on the metric provided
        TOPN(
            5,
            SUMMARIZE(Sales_Data, Sales_Data[Customer_ID], "Metric", [Measure]),
            [Metric],
            DESC
        ),
        -- Concatenate IDs into a single string for text-based visualization
        Sales_Data[Customer_ID],
        ", ",
        [Measure],
        DESC
    )
    ```



---

### **Explanation of Complex Logics**

1. **Retention Rate (Set Theory)**:
The `Monthly Retention Rate` does not simply count customers; it uses `INTERSECT`. It creates a virtual table of customers who bought *last month* and a virtual table of customers who bought *this month*. The intersection of these two sets represents true retained customers.
2. **Customer Lifetime Value (Derived Components)**:
CLV is calculated dynamically inside the measure by first determining the **Monthly Churn Rate** (customers lost vs. previous month).
* `Customer Lifespan` is derived as `1 / Churn Rate`.
* `CLV` = `Avg Order Value` × `Lifespan` × `Purchase Frequency`.
* This provides a predictive financial value rather than just a historical one.
3. **Recency (Context Awareness)**:
The `Customer Recency Days` measure uses `KEEPFILTERS(Calendar_Table)`. This ensures that when calculating the "Last Purchase Date," the engine strictly respects the user's selected date range slicer, rather than looking at the entire history of the database. If a customer hasn't bought in the selected period, it returns a blank (formatted as an empty character `"‎"`) to keep the visual clean.
4. **Smart MoM Logic**:
The Growth metrics use a `SWITCH(TRUE)` pattern. This prevents the "blank visual" error. If a user views the dashboard without selecting a specific month, the DAX automatically finds the `MAX` (latest) month in the data and compares it to the prior month, ensuring the KPI cards always show the most recent trend data.
