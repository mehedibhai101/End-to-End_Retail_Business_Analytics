# 📊 Calculated Tables & Columns: Omniretail Business Analytics

This documentation provides a comprehensive overview of the **Calculated Tables** and **Calculated Columns** used for the Omniretail analysis. It outlines the structural transformations and row-level logic used to drive business insights, customer segmentation, and dynamic growth metrics.

---

### Calculated Table

* **RFM_Calculation**: Generates a summary table at the customer level, aggregating transaction history into the three core RFM pillars.
    * **Formula**:
    ```dax
    RFM_Calculation = 
    SUMMARIZE(
        Sales_Data,
        Sales_Data[Customer_ID],
        "R Value", [Customer Recency Days (Non-Filter)],
        "F Value", [Total Orders],
        "M Value", [Total Revenue]
    )
    ```





---

### RFM_Calculation Table (Columns)

* **R Score**: Assigns a score from 1 to 5 based on customer recency quintiles. A lower recency value (more recent) results in a higher score.
* **Formula**:
    ```dax
    VAR R = 'RFM_Calculation'[R Value]
    VAR P20 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[R Value], 0.2)
    VAR P40 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[R Value], 0.4)
    VAR P60 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[R Value], 0.6)
    VAR P80 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[R Value], 0.8)
    RETURN
        SWITCH(
            TRUE(),
            R <= P20, 5,
            R <= P40, 4,
            R <= P60, 3,
            R <= P80, 2,
            1
        )
    ```
    
    
    * **Formatting**: `0`


* **F Score**: Assigns a score from 1 to 5 based on order frequency quintiles. Higher frequency results in a higher score.
    * **Formula**:
    ```dax
    VAR F = 'RFM_Calculation'[F Value]
    VAR P20 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[F Value], 0.2)
    VAR P40 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[F Value], 0.4)
    VAR P60 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[F Value], 0.6)
    VAR P80 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[F Value], 0.8)
    RETURN
        SWITCH(
            TRUE(),
            F <= P20, 1,
            F <= P40, 2,
            F <= P60, 3,
            F <= P80, 4,
            5
        )
    ```
    
    
    * **Formatting**: `0`


* **M Score**: Assigns a score from 1 to 5 based on total revenue quintiles. Higher spend results in a higher score.
    * **Formula**:
    ```dax
    VAR M = 'RFM_Calculation'[M Value]
    VAR P20 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[M Value], 0.2)
    VAR P40 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[M Value], 0.4)
    VAR P60 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[M Value], 0.6)
    VAR P80 = PERCENTILEX.INC('RFM_Calculation', 'RFM_Calculation'[M Value], 0.8)
    RETURN
        SWITCH(
            TRUE(),
            M <= P20, 1,
            M <= P40, 2,
            M <= P60, 3,
            M <= P80, 4,
            5
        )
    ```
    
    
    * **Formatting**: `0`


* **RFM Score**: Concatenates the R, F, and M scores into a single three-digit code to identify the specific customer profile.
    * **Formula**: `'RFM_Calculation'[R Score] & 'RFM_Calculation'[F Score] & 'RFM_Calculation'[M Score]`
    * **Formatting**: `Text`


* **Segment**: Categorizes customers into named marketing segments based on their individual RFM scores.
* **Formula**:
    ```dax
    SWITCH(
        TRUE(),
        [R Score]>= 4 && [F Score]>= 4 && [M Score]>= 4, "Champions",
        [F Score]>= 4 && [M Score]>= 3, "Loyal Customers",
        [R Score]>= 3 && [F Score]>= 3 && [M Score]>= 3, "Potential Loyalists",
        [R Score]>= 4 && [F Score]<= 3 && [M Score]<= 3, "Recent Customers",
        [R Score]>= 3 && [F Score]<= 3 && [M Score]<= 3, "Promising",
        [R Score]<= 3 && [F Score]<= 3 && [M Score]<= 3, "Needs Attention",
        [R Score]<= 2 && [F Score]>= 3 && [M Score]>= 3, "At Risk",
        [R Score]<= 2 && [F Score]<= 2 && [M Score]<= 2, "Hibernating",
        [R Score]= 1, "Lost",
        "Other"
    )
    ```
    
    
    * **Formatting**: `Text`
    
    
    
---

### Data & Column Logics:

* **Table Grain Transformation**: The table uses a `SUMMARIZE` function to pivot the data from a transactional grain (Sales) to a customer grain. This is a strategic architectural choice to ensure quintile calculations (`PERCENTILEX.INC`) are performed across the unique customer population rather than individual orders.
* **Dynamic Quintile Segmentation**: Instead of using static thresholds, the scoring logic uses statistical quintiles. This ensures the model remains relevant as the business scales, automatically adjusting "high" and "low" performance based on the actual distribution of the data.
* **Concatenated Profiling**: The **RFM Score** allows for quick filtering and pattern recognition (e.g., a "555" customer is a perfect Champion), while the **Segment** column provides a human-readable layer for business reporting.
