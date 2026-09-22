# 🏦 Banking Loan Default & Risk Analysis

**End-to-end credit risk analytics dashboard evaluating $32.5B+ in loan exposure across 255K+ borrowers — built to surface underwriting risk factors and demographic default patterns for portfolio decision-making.**

🔗 **[Download Interactive .pbix File](https://insightbi99-my.sharepoint.com/:u:/g/personal/sahilbhowad_insightbi99_onmicrosoft_com/IQB2uEB3_KeXR7JezLlB1jvcAVNr9ucs7_h3YZHf_IQNN_g?e=i6hHKX)** | 📊 4-Page Interactive Report | 🛠️ SQL + Power BI + DAX

---

## 📌 The Business Problem

Lending institutions need to understand **who is likely to default, and why** — not just after the fact, but at the underwriting stage. This project analyzes a **255K+ borrower loan portfolio** to identify which risk factors (credit score, co-signer status, age, education, income) most strongly predict default, giving risk teams a data-backed basis for underwriting policy decisions.

**Dataset:** 255K+ loan records | $32.5B+ total exposure | Attributes include loan amount, interest rate, DTI ratio, credit score, age, income, education, marital status, and co-signer status.

---

## 🛠️ Technical Approach

| Stage | Tools & Method |
|---|---|
| **Data Validation** | Staged raw data in SQL Server (SSMS) — validated schema, primary keys, and data integrity |
| **ETL Pipeline** | Built centralized Power BI Dataflows for enterprise-grade transformation |
| **Data Profiling** | Used Power Query's Column Quality/Distribution/Profile tools for full data hygiene checks |
| **Modeling** | Custom DAX measures for default rate, exposure, and Year-over-Year (YoY) growth tracking |
| **Reporting** | 4-page executive dashboard with KPI cards, heatmaps, Sankey diagram, and decomposition tree |

**Sample DAX (Time Intelligence — YoY Default Change):**
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

---

## 💡 Key Business Insights

**Portfolio Snapshot**
- **$32,577M** total exposure across **255K** borrowers | **11.61%** overall default rate | **13.5%** avg. interest rate

**Underwriting Risk Factors**
- Borrowers **without a co-signer** default at **12.35%**, vs. **10.88%** with one → co-signers reduce default risk by **~1.47%**
- **Poor credit score tier** borrowers default at **13.31%**, nearly **3 points higher** than Excellent tier (10.21%)
- Default risk **peaks at 13.69%** in the highest interest rate tier vs. **5.14%** in the lowest

**Demographic Risk Patterns**
- **Young adults face a 22.14% default rate** — over **4x higher** than senior citizens (5.13%)
- Default risk **declines steadily with age** and with education level (High School: 12.88% → PhD: 10.59%)
- Riskiest segment: **divorced borrowers without a co-signer (13.89%)**; safest: **married borrowers with a co-signer (9.48%)**

**Portfolio Growth**
- **High-income borrowers** account for **$17.88B** of total exposure — by far the largest concentration
- YoY tracking flagged **2015 and 2018** as peak years where loan growth outpaced default control (+2.70% and +1.89% default spikes)

---

## 📊 Dashboard Preview

**Page 1 — Executive Overview**
![Overview](https://github.com/user-attachments/assets/a11f6e17-8179-434f-a37c-7836684ce2e6)

**Page 2 — Underwriting & Risk Factor Analysis**
![Underwriting](https://github.com/user-attachments/assets/05c5b4db-b0ab-4cec-992d-af090054ba1e)

**Page 3 — Demographic Segmentation**
![Demographics](https://github.com/user-attachments/assets/e27e006f-1220-416b-9fbe-b7033dafd309)

**Page 4 — Portfolio Growth Trends**
![Growth Trends](https://github.com/user-attachments/assets/d06e7832-964b-4cd6-9191-38b186c84017)

---

## 🎯 Business Recommendation

Underwriting policy should weight **co-signer requirement and credit score tier** more heavily for borrowers under 30 — this segment shows the highest compounded risk (young age + often no credit history) and represents the clearest opportunity to cut portfolio-wide default rate without reducing loan volume.
