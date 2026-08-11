# Banking Loan Default & Risk Analysis (Power BI)

### Project File & Report Access:
* **Download Power BI Desktop File (`.pbix`):** [Download `.pbix` File via OneDrive](https://insightbi99-my.sharepoint.com/:u:/g/personal/sahilbhowad_insightbi99_onmicrosoft_com/IQB2uEB3_KeXR7JezLlB1jvcAVNr9ucs7_h3YZHf_IQNN_g?e=i6hHKX)
> *Note: Click "Download" on the OneDrive page to open the complete interactive model in Power BI Desktop. Full report page snapshots are provided below.*

## Problem Statement

An end-to-end Power BI financial analytics solution designed to evaluate loan portfolio exposure, borrower demographic risk factors, underwriting efficiency, and year-over-year (YoY) growth trends across **255K+ borrowers** representing **$32.5B+ in total exposure**.

### Steps followed 

- Step 1 : Staged raw source data in SQL Server Management Studio (SSMS) to validate schema structures, check primary keys, and verify initial data integrity.
- Step 2 : Connected SSMS to Power BI Dataflows in Power BI Service to construct an enterprise-grade, centralized ETL pipeline.
- Step 3 : Connected Power BI Desktop to the workspace Dataflow to import cleaned tables into the semantic model.
- Step 4 : Opened Power Query Editor and enabled Column distribution, Column quality, and Column profile under the View tab (selecting profiling based on the entire dataset) to inspect complete data hygiene.
- Step 5 : Applied data transformations and verified data type consistency across key financial attributes (LoanAmount, InterestRate, DTIRatio, Age, Income, Default).
- Step 6 : Established a custom corporate report theme using Executive Burgundy (#80242B), Slate Navy (#2C3E50), and high-contrast dark neutrals (#2B2D42).
- Step 7 : Integrated interactive Slicer panels on the canvas for dynamic filtering across LoanTerm, Education, and HasCoSigner. 
- Step 8 : Five KPI Card visuals were added to the top canvas representing core executive metrics: Total Exposure ($32,577M), Total Borrowers (255K), Overall Default Rate (11.61%), Average Interest Rate (13.5%), and Average DTI Ratio (0.50).
- Step 9 : Designed multi-page visual layouts across 4 dedicated report pages:

Page 1 (Overview): Added line charts for multi-year default trends, horizontal bar charts for loan purpose distribution, and grouped bar charts comparing average income of defaulters vs. non-defaulters.

Page 2 (Underwriting Analysis): Added column charts for credit score tiers, horizontal bars for DTI brackets, line charts for interest rate sensitivity, and a Matrix Heatmap evaluating HasCoSigner against EmploymentType.

Page 3 (Demographics): Added bar charts for age group default rates, a Donut visual for education level distribution, and a Matrix Heatmap cross-tabulating MaritalStatus vs. HasCoSigner.

Page 4 (Portfolio Trends): Added dual line charts for YoY Loan Amount Change % vs. YoY Default Cases Change %, alongside a Sankey Diagram (credit rating & marital status flow) and a Decomposition Tree (income & employment breakdown).

- Step 10 : Calculated columns were created in DAX to perform dynamic categorical bucketing for income and age groups:
   
Income Bracket:
    Income Bracket = 
    SWITCH(
    TRUE(),
    'Loan_default'[Income] < 30000, "Low Income",
    'Loan_default'[Income] < 60000, "Medium Income",
    "High Income"
    );



- Step 11 : Core DAX measures were created to calculate total borrower counts, exposure, default rates, and averages:

    Total Borrowers = COUNT('Loan_default'[ID])

    Total Exposure = SUM('Loan_default'[LoanAmount])

    Default Rate % = 
    DIVIDE(
    COUNTROWS(FILTER('Loan_default', 'Loan_default'[Default] = 1)),
    COUNT('Loan_default'[ID]),
    0
    )


- Step 12 : Time Intelligence DAX measures were developed to calculate Year-over-Year (YoY) growth percentages:

    YOY Loan Amount Change % = 
    VAR CurrentYearAmount = SUM('Loan_default'[LoanAmount])
    VAR PreviousYearAmount = 
    CALCULATE(
    SUM('Loan_default'[LoanAmount]),
    DATEADD('Date'[Date], -1, YEAR)
    )
    RETURN
    DIVIDE(CurrentYearAmount - PreviousYearAmount, PreviousYearAmount, 0)


    YOY Default Cases Change % = 
    VAR CurrentDefaults = COUNTROWS(FILTER('Loan_default', 'Loan_default'[Default] = 1))
    VAR PreviousDefaults = 
    CALCULATE(
    COUNTROWS(FILTER('Loan_default', 'Loan_default'[Default] = 1)),
    DATEADD('Date'[Date], -1, YEAR)
    )
    RETURN
    DIVIDE(CurrentDefaults - PreviousDefaults, PreviousDefaults, 0)

- Step 13 : Formatted all visual data labels across all pages to standard financial display units ($bn, $M, %) for executive clarity.

- Step 14 : Inserted custom header text boxes and rectangular shapes to structure the title banner on every report page.
        
- Step 15 : Published the completed report to Power BI Service inside the dedicated project workspace (Credit Risk & Portfolio Growth Analytics).
 
 
![Publish_Message](https://github.com/user-attachments/assets/445cae02-734b-403c-8fe6-53a110c4a626)

# Snapshot of Dashboard (Power BI Service)

![Dashboard_Snapshot](https://github.com/user-attachments/assets/027998c7-3232-4f7a-a261-b99782f2a7a0)

 
 # Report Snapshot (Power BI DESKTOP)

### Page 1: Credit Risk & Loan Default Overview (Executive Summary)
![Page 1 Overview](https://github.com/user-attachments/assets/a11f6e17-8179-434f-a37c-7836684ce2e6)

### Page 2: Underwriting & Credit Risk Factor Analysis
![Page 2 Underwriting Analysis](https://github.com/user-attachments/assets/05c5b4db-b0ab-4cec-992d-af090054ba1e)

### Page 3: Demographic Profiling & Borrower Segmentation
![Page 3 Demographic Segmentation](https://github.com/user-attachments/assets/e27e006f-1220-416b-9fbe-b7033dafd309)

### Page 4: Financial Risk & Portfolio Growth Trends
![Page 4 Portfolio Growth Trends](https://github.com/user-attachments/assets/d06e7832-964b-4cd6-9191-38b186c84017)

# Insights

A 4-page interactive executive report was created in Power BI Desktop and published to Power BI Service.

The following key business inferences were derived from the portfolio data:

### [1] Portfolio Baseline & Executive Exposure
* **Total Exposure:** $32,577M ($32.58B)
* **Total Borrowers:** 255K
* **Portfolio Default Rate:** 11.61%
* **Average Interest Rate:** 13.5%
* **Average DTI Ratio:** 0.50

### [2] Underwriting & Risk Factor Analysis
* **Credit Score Tier Impact:**
  * Borrowers in the **Poor** credit score tier carry the highest default rate at **13.31%**.
  * Default risk drops progressively as credit score improves: **Fair (12.22%)**, **Good (11.49%)**, and **Excellent (10.21%)**.
* **Co-Signer Risk Mitigation:**
  * Borrowers **without a co-signer** (`False`) exhibit a **12.35%** default rate.
  * Borrowers **with a co-signer** (`True`) exhibit a **10.88%** default rate.
  * *Conclusion:* Requiring a co-signer reduces default probability across all employment types by an average of **1.47%**.
* **Interest Rate Tier Sensitivity:** Higher interest rates correlate directly with increased default risk, peaking at **13.69%** for high-interest loans (10-12% tier) compared to **5.14%** for low-interest loans (1-3% tier).

### [3] Demographic Borrower Segmentation
* **Age Tiers:**
  * **Teens / Young Adults:** Highest default propensity at **22.14%**.
  * **Adults:** **16.69%** default rate.
  * **Mid-Age Adults:** **8.71%** default rate.
  * **Senior Citizens:** Lowest default rate at **5.13%**.
  * *Conclusion:* Default risk declines significantly as borrower age increases.
* **Education Level Distribution:**
  * Borrowers with a **High School** education show the highest default rate at **12.88%**.
  * Default risk decreases with higher education: **Bachelor's (12.10%)**, **Master's (10.87%)**, and **PhD (10.59%)**.
* **Marital Status & Co-Signer Interaction:**
  * **Divorced borrowers without a co-signer** represent the highest single demographic default risk at **13.89%**.
  * **Married borrowers with a co-signer** represent the lowest risk demographic at **9.48%**.

### [4] YoY Portfolio Growth & Income Breakdown
* **Growth vs. Risk Tracking:** Evaluating **YoY Loan Amount Change %** alongside **YoY Default Cases Change %** identifies rapid expansion years where default spikes occurred (e.g., peak default growth in 2015 at +2.70% and 2018 at +1.89%).
* **Income Tiers:** **High-Income** borrowers account for **$17.88B** of total portfolio exposure, while **Medium-Income** ($2.55B) and **Low-Income** ($0.64B) represent smaller fractions.
