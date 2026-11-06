# 🏦 Banking Loan Default & Risk Analysis

**Which borrower and loan factors are linked to default? A credit risk dashboard covering $32.5B+ in loan exposure across 255K+ borrowers, built with SQL Server, Power BI and DAX.**

🔗 [Download Interactive .pbix File](https://insightbi99-my.sharepoint.com/:u:/g/personal/sahilbhowad_insightbi99_onmicrosoft_com/IQB2uEB3_KeXR7JezLlB1jvcAVNr9ucs7_h3YZHf_IQNN_g?e=i6hHKX) | 📊 4-Page Interactive Report | 🛠️ SQL + Power BI + DAX | 👨‍💻 255K+ Borrowers Analyzed

---

## 📌 The Business Problem

Lenders need to know **who is likely to default, and why**, at the underwriting stage and not only after the loss. This project analyzes a loan portfolio of 255K+ borrowers to find which factors (credit score, co-signer status, age, education, income, interest rate) are most linked to default, so a risk team has data to support its underwriting policy.

**Data:** 255K+ loan records, $32.5B+ total exposure. Columns include loan amount, interest rate, DTI ratio, credit score, age, income, education, marital status and co-signer status.

---

![Executive Overview](https://github.com/user-attachments/assets/a11f6e17-8179-434f-a37c-7836684ce2e6)

---

## 💡 Key Results

* **$32,577M** total exposure across **255K** borrowers, **11.61%** overall default rate, **13.5%** average interest rate.
* Borrowers **without a co-signer** default at **12.35%** vs **10.88%** with one (1.47 percentage points lower).
* **Young adults default at 22.14%**, more than 4x the rate of senior citizens (5.13%).
* Riskiest segment: **divorced borrowers without a co-signer (13.89%)**. Safest: **married borrowers with a co-signer (9.48%)**.
* **High-income borrowers** hold **$17.88B** of total exposure, the largest concentration in the portfolio.

---

## 🛠️ Tools & Approach

| Stage | What I did |
|---|---|
| Data validation | Staged the raw data in SQL Server (SSMS) and validated schema, primary keys and data integrity |
| ETL | Built Power BI Dataflows to centralize the transformation steps |
| Data profiling | Used Power Query's Column Quality, Distribution and Profile tools to check data hygiene |
| Modeling | Wrote DAX measures for default rate, exposure and Year-over-Year (YoY) change |
| Reporting | 4-page dashboard with KPI cards, heatmaps, a Sankey diagram and a decomposition tree |

---

## 🔎 Findings

| # | Finding | Evidence | Recommendation |
|---|---|---|---|
| 1 | Co-signers are linked to lower default | 12.35% without vs 10.88% with a co-signer | Weight co-signer status in underwriting |
| 2 | Weaker credit tiers default more | Poor 13.31% vs Excellent 10.21% (about 3 points higher) | Weight credit score tier in underwriting |
| 3 | Young borrowers are the highest-risk age group | 22.14% (young adults) vs 5.13% (seniors). Risk falls steadily with age | Apply stricter checks to borrowers under 30 |
| 4 | Default rises with interest rate tier | 13.69% in the highest tier vs 5.14% in the lowest | Review monitoring for the highest-rate loans |
| 5 | Risk factors stack | Divorced with no co-signer 13.89% vs married with co-signer 9.48%. Education also matters (High School 12.88% to PhD 10.59%) | Judge borrowers on combined factors, not one at a time |
| 6 | Exposure is concentrated in high earners | High-income borrowers hold $17.88B | Track concentration risk in this segment |

**Main recommendation:** weight **co-signer requirement and credit score tier** more heavily for borrowers under 30. This group shows the highest default rate and is the clearest chance to reduce overall defaults without cutting loan volume.

YoY tracking also flagged **2015 and 2018** as peak years, with default cases changing by **+2.70%** and **+1.89%** year over year.

---

## 🧮 DAX Highlight

**Year-over-Year change in default cases:**

```dax
YOY Default Cases Change % = 
VAR CurrentDefaults = COUNTROWS(FILTER('Loan_default', 'Loan_default'[Default] = 1))
VAR PreviousDefaults = 
    CALCULATE(
        COUNTROWS(FILTER('Loan_default', 'Loan_default'[Default] = 1)),
        DATEADD('Date'[Date], -1, YEAR)
    )
RETURN DIVIDE(CurrentDefaults - PreviousDefaults, PreviousDefaults, 0)
```

This measure counts defaults in the current year, uses `DATEADD` to count defaults one year earlier, and returns the % change. `DIVIDE` returns 0 instead of an error when the previous year is zero.

---

## 📊 Power BI Dashboard

| Page | Shows |
|---|---|
| 1. Executive Overview | Portfolio snapshot and headline KPIs |
| 2. Underwriting & Risk Factors | Co-signer, credit score tier and interest rate tier |
| 3. Demographic Segmentation | Age, education and marital status |
| 4. Portfolio Growth Trends | Exposure and YoY default change |

**Page 2: Underwriting & Risk Factor Analysis**
![Underwriting](https://github.com/user-attachments/assets/05c5b4db-b0ab-4cec-992d-af090054ba1e)

**Page 3: Demographic Segmentation**
![Demographics](https://github.com/user-attachments/assets/e27e006f-1220-416b-9fbe-b7033dafd309)

**Page 4: Portfolio Growth Trends**
![Growth Trends](https://github.com/user-attachments/assets/d06e7832-964b-4cd6-9191-38b186c84017)

---

## ⚠️ Limitations & Next Steps

**Limitations**

* The dashboard shows patterns, not causes. A link between a factor and default does not prove the factor causes default.
* Factors overlap (for example age and co-signer status), and the dashboard does not separate their effects.
* Default rates are compared across groups without a statistical test, so small differences should be read carefully.

**Next Steps**

* Build a model such as logistic regression to estimate each factor's effect while controlling for the others.
* Add loss amount or recovery data to measure the cost of default, not only the rate.

---

## 🚀 How to Open

1. Download the `.pbix` file from the link at the top.
2. Open it with Power BI Desktop (free).
3. Use the page tabs and slicers to explore the 4 pages.

---

**Sahil Bhowad** | Aspiring Data Analyst | Mumbai | [LinkedIn](https://www.linkedin.com/in/sahil-bhowad-7a915934a/) | [GitHub](https://github.com/SahilBhowad)
