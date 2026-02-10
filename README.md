# Project Background: End-to-End Retail Analytics for Omniretail

**Omniretail Pvt Ltd** is a dynamic retail conglomerate operating across the electronics, clothing, home & kitchen, and grocery sectors. As the company scales its operations across four major African regions (North, South, East, West), the leadership team is grappling with **"Profitless Growth"**, revenue is rising, but operational inefficiencies and customer churn are eroding margins.

This project leverages a robust dataset of **500 transaction records** (representing a sample of **$18.5 Million** in revenue) to diagnose the health of the retail ecosystem. As a Lead Retail Analyst, my objective was to move beyond simple sales reporting to uncover the **"Regional Fractures"** and **"Retention Voids"** threatening long-term sustainability. The analysis serves as a strategic playbook for the C-Suite to transition from a "Spray-and-Pray" expansion model to a **Precision-Retail** strategy.

Insights and recommendations are provided on the following key areas:

* **Category 1: The Regional Divide** (West's Dominance vs. North's Decline)
* **Category 2: The "Return" Crisis** (Plugging Value Leakage in High-Ticket Categories)
* **Category 3: The Loyalty Vacuum** (Addressing the <20% Customer Retention Rate)
* **Category 4: Category Dynamics** (Stabilizing Grocery & Accelerating Home/Toys)

**SQL & DAX queries regarding various retail calculations can be found here [[Link to Script]](https://www.google.com/search?q=%23).**

**An interactive Power BI dashboard used to report and explore sales trends can be found here [[Link to Dashboard]](https://www.google.com/search?q=%23).**

---

# Data Structure & Initial Checks

The analysis is powered by a comprehensive transaction dataset (`OmniRetail.csv`) containing **500 records**, capturing the full lifecycle of retail operations from sale to return.

* **`Sale_ID` & `Sale_Date**`: Primary keys used to track transaction velocity and temporal trends.
* **`Customer_ID`**: The unique identifier used to measure the **Retention Rate** and calculate Customer Lifetime Value (CLV).
* **`Product_ID` & `Product_Category**`: Segmenting performance across **Electronics, Grocery, Clothing, Toys, and Home**.
* **`Store_ID` & `Region**`: Geographic attributes identifying the **North, South, East, and West** sales hubs.
* **`Quantity_Sold` & `Unit_Price**`: Core financial metrics (Unit Price is currently standardized at **$200.59** across the board).
* **`Payment_Method`**: Tracking the adoption of **Credit Card, Cash, UPI, and Net Banking** across different regions.
* **`Returned`**: A binary indicator (Yes/No) used to isolate "Value Leakage" and calculate the **10% overall return rate**.
* **`Total_Sale_Amount`**: The derived revenue metric representing the final transaction value.

### Entity Relationship Diagram (ERD)

---

# Executive Summary

### Overview of Findings

Omniretail is currently a **"Tale of Two Businesses."** While the **West Region** is a powerhouse driving significant revenue, the **North** is facing a dangerous profitability decline, and the **East** remains stagnant. The most alarming metric is the **Customer Retention Rate (<20%)**, indicating that the business is churning customers faster than it can acquire them. Furthermore, while overall returns are stable, specific categories like **Electronics and Clothing** are bleeding value through high return rates, requiring immediate operational intervention.

[**Visualization: Executive KPI Overview - Revenue by Region & Retention Rate**]

---

# Insights Deep Dive

### Category 1: The Regional Divide (The "West Side Story")

* **The Western Powerhouse.** The **West Region** has emerged as the undisputed growth engine, contributing the highest share of the **$18.5M** total revenue. It outperforms all other regions in both transaction volume and average ticket size.
* **The Northern Bleed.** The **North Region** is showing signs of distress with declining profitability metrics. Despite operational costs remaining high, sales velocity has slowed, suggesting a disconnect between inventory mix and local demand.
* **Eastern Stagnation.** The **East Region** is stuck in a "Volatile Demand" cycle. Sales are unpredictable, making inventory planning difficult and leading to either stockouts or overstock situations.

[**Visualization: Regional Sales Performance Heatmap**]

### Category 2: The "Return" Crisis (Value Leakage)

* **High-Ticket Vulnerability.** While the overall return rate sits at a manageable **10%**, the damage is concentrated in high-value categories. **Electronics** and **Clothing** show return rates significantly above the average.
* **The "Fit & Function" Friction.** The high return rate in Clothing suggests issues with sizing consistency or product description accuracy online. In Electronics, returns are likely driven by complex setup processes or "defect-on-arrival" perceptions.
* **Operational Cost.** Processing these returns is not just a revenue reversal; it incurs logistics, restocking, and potential liquidation costs, effectively doubling the loss on every returned unit.

[**Visualization: Return Rate by Category & Financial Impact**]

### Category 3: The Loyalty Vacuum (Retention <20%)

* **The One-and-Done Problem.** Data reveals a critical **Retention Rate of less than 20%**. The vast majority of customers make a single purchase and never return, indicating a failure in post-purchase engagement.
* **The "Silent" High-Value Customer.** A small segment of customers exhibits high spending with **zero returns**. These are our "Ideal Profiles," yet there is no dedicated program to lock them in.
* **Acquisition Dependency.** The business is heavily reliant on constantly acquiring new traffic to maintain revenue, which is a significantly more expensive strategy than retaining existing shoppers.

[**Visualization: Customer Retention Cohort Analysis**]

### Category 4: Category Dynamics & Payment Shifts

* **Grocery Stability vs. Growth Stars.** **Grocery** remains the top category by volume, acting as the "traffic driver" for the business. However, **Home** and **Toys** are identified as high-potential growth categories that are currently under-marketed.
* **Payment Friction.** Payment preferences are shifting unevenly across regions. While the West is adopting digital payments rapidly, other regions still rely heavily on Cash/Debit, creating friction at checkout and limiting data capture.
* **The "Basket Builder" Opportunity.** The strong traffic in Grocery is not being leveraged to cross-sell into higher-margin categories like Home or Toys.

[**Visualization: Sales by Category & Payment Method Distribution**]

---

# Recommendations:

* **The "Northern Revitalization" Plan:** Immediately audit the product mix in the **North Region**. Shift inventory away from slow-moving Electronics towards high-velocity Grocery and Home essentials to stabilize cash flow.
* **"Fit-First" Initiative:** To tackle the Clothing return crisis, implement a "True-Fit" sizing guide online and a stricter quality control check for Electronics suppliers. Target a **15% reduction in returns** within 6 months.
* **Launch "Omni-Prime" Loyalty:** addressing the <20% retention is critical. Launch a tiered loyalty program rewarding frequency over volume. Offer **"Free Next-Day Delivery"** to repeat buyers to lock in the Grocery segment.
* **Cross-Pollination Strategy:** Use the high-traffic Grocery category as a "Trojan Horse." Print **20% Off Coupons for Toys/Home** on every Grocery receipt to drive cross-category adoption.
* **Regional Payment Optimization:** In the cash-heavy East/North, incentivize digital payments with a **"5% Cashback on Digital Wallet"** promo to improve checkout speed and customer data capture.

---

# Assumptions and Caveats:

Throughout the analysis, the following strategic assumptions were made to address specific data architecture challenges identified during the audit:

* **Uniform Pricing Structure:** All products within the dataset currently share an identical Unit Price ($200.59). For this analysis, it is assumed that revenue variance is driven strictly by volume and regional sales velocity rather than price elasticity.
* **Flat Regional Hierarchy:** The data lacks a direct Region-to-Store hierarchy (e.g., the same Store ID appearing in multiple regions). Analysis assumes regional assignments in the fact table are the "Source of Truth" for geographic performance.
* **Product ID Granularity:** Some unique products share the same ID in the source system. Analysis treats these as category-level aggregations to maintain data integrity across the dashboard.
* **Retention Calculation:** Due to a lack of historical acquisition dates, retention is calculated as a percentage of unique Customer IDs appearing in more than one transaction cycle within the current window.
