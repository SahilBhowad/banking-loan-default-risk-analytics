-- =========================================================================
-- Banking Loan Default & Risk Analysis: SQL
-- =========================================================================
-- Author  : Sahil Bhowad
-- Tool    : SQL Server (SSMS)
-- Table   : loan_default (255K+ borrowers)
-- Purpose :
--      1. Recreate the key numbers of the Power BI dashboard in SQL
--         (KPIs, default rate, exposure) and confirm they match.
--      2. Answer the business questions behind each dashboard page:
--         Executive Overview, Underwriting & Risk Factors,
--         Demographic Segmentation, and Portfolio Growth Trends.
-- Naming  : Raw columns keep their source names (CamelCase).
--           Derived columns, aliases and CTEs use snake_case.
-- =========================================================================


-- Create Database 
CREATE DATABASE loan_default_analysis ;
GO

USE loan_default_analysis ;


-- NOTE: The table loan_default was created with the SSMS Import Flat File wizard.
-- from loan_default.csv.

-- View the entire data
SELECT * FROM loan_default ;

-- Rename the date column so it is easy to query:
EXEC sp_rename 'loan_default.Loan_Date_DD_MM_YYYY', 'LoanDate', 'COLUMN' ;
GO

-- -------------------------------------------------------------------------
-- Create a reusable view (mirrors the calculated columns / groups used in Power BI)
-- -------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_loan_segments AS
SELECT
	*,
	YEAR(LoanDate) AS loan_year,
	CASE 
		WHEN CreditScore <=400 THEN 'Poor'
		WHEN CreditScore <=500 THEN 'Fair'
		WHEN CreditScore <=700 THEN 'Good'
	ELSE 'Excellent' 
	END AS credit_score_tier,

	CASE 
		WHEN DTIRatio <0.30 THEN 'Low'
		WHEN DTIRatio <0.60 THEN 'Medium'
	ELSE 'High'
	END AS DTIRatio_brackets,

	CASE
		WHEN InterestRate <=3 THEN ' 1-3'
		WHEN InterestRate <=6 THEN ' 4-6'
		WHEN InterestRate <=9 THEN ' 7-9'
	ELSE '10-12'							-- every rate above 9%
	END AS interest_rate_bins,

	CASE 
		WHEN Age <=19 THEN 'Teen'
		WHEN Age <=39 THEN 'Adult'
		WHEN Age <=59 THEN 'Mid Age Adult'
	ELSE 'Senior Citizen' 
	END AS age_group,

    CASE
        WHEN Income < 30000 THEN '3) Low Income'
        WHEN Income < 60000 THEN '2) Medium Income'
        ELSE                     '1) High Income'
    END AS income_bracket

FROM loan_default 
;
GO

--Questions :- 

-- =========================================================================
-- PAGE 1: EXECUTIVE OVERVIEW
-- =========================================================================

-- -------------------------------------------------------------------------
-- Q1. How many borrowers are in the data?
-- -------------------------------------------------------------------------

SELECT COUNT(*) AS total_borrowers FROM loan_default;

-- Insight: The data has 255347 (255K) borrowers

-- -------------------------------------------------------------------------
-- Q2. What are the overall portfolio KPIs (dashboard KPI cards)?
-- -------------------------------------------------------------------------

SELECT 
	FORMAT(SUM(CAST(LoanAmount AS BIGINT)) / 1000000.0,'N0') AS Total_Exposure_Million,
	COUNT(*) AS total_borrowers,   -- 255347 (Power BI shows 255K)
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL (5,2)) AS default_rate,
	ROUND(AVG(InterestRate),1) AS avg_interest,
	ROUND(AVG(DTIRatio),2) AS avg_DTIratio
FROM loan_default 
;

-- Insight: Total exposure is about $32,577M, with an 11.61% default rate,
-- 13.5% average interest and an average DTI of 0.5.
-- NOTE: SUM(LoanAmount) is cast to BIGINT because it exceeds the INT limit.


-- -------------------------------------------------------------------------
-- Q3. how is default rate moved year by year ?
-- -------------------------------------------------------------------------

SELECT
	loan_year,
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,1)) AS default_rate
FROM vw_loan_segments
GROUP BY loan_year
ORDER BY loan_year
;

-- Insight : The default rate is stable between 11.5 - 11.7 across year 2013-2018
-- So there is no single bad year.


-- -------------------------------------------------------------------------
-- Q.4 How the loan Amount is distributed by purpose ?
-- -------------------------------------------------------------------------

SELECT
	LoanPurpose,
	COUNT(*) AS total_loans,
	CAST(SUM(CAST(LoanAmount AS BIGINT)) / 1000000.0 AS DECIMAL (10,2)) AS loan_amount_million,
	CAST(100.0 * SUM(CAST(LoanAmount AS BIGINT)) / SUM(SUM(CAST(LoanAmount AS BIGINT))) OVER() AS DECIMAL(10,2)) AS pct_loan_amount
FROM loan_default
GROUP BY LoanPurpose
ORDER BY loan_amount_million DESC
;

-- Insight : Exposure is spread almost evenly across all purposes
-- So there is no purpose concentration risk 


-- -------------------------------------------------------------------------
-- Q5. what is default rate by employment type ?
-- -------------------------------------------------------------------------

SELECT 
	EmploymentType,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL (5,2)) AS default_rate
FROM loan_default
GROUP BY EmploymentType
ORDER BY default_rate DESC
;

-- Insight : Unemployed borrower are riskiest with 13.6% default rate &
-- full time employed are safest 9.5% default rate


-- -------------------------------------------------------------------------
-- Q6. What is average income of defaulters & non-defaulters by employment type
-- -------------------------------------------------------------------------

SELECT
	EmploymentType,
	CAST(AVG(CASE WHEN [Default] = 1 THEN 1.0 * Income END) AS DECIMAL(10,0)) AS avg_income_defaulter,
	CAST(AVG(CASE WHEN [Default] = 0 THEN 1.0 * Income END) AS DECIMAL(10,0)) AS avg_income_non_defaulter,
	CAST(AVG(CASE WHEN [Default] = 0 THEN 1.0 * Income END) AS DECIMAL(10,0))
		- CAST(AVG(CASE WHEN [Default] = 1 THEN 1.0 * Income END) AS DECIMAL(10,0)) AS Income_gap
FROM loan_default
GROUP BY EmploymentType 
;

-- Insight : Defaulters earn around $12k less than non-defaulter in every employment type
-- So the income is consistent risk signal


-- =========================================================================
-- PAGE 2: UNDERWRITING & CREDIT RISK FACTORS
-- =========================================================================
-- -------------------------------------------------------------------------
-- Q7. How default rate change by Credit score tiers.
-- -------------------------------------------------------------------------

SELECT
	credit_score_tier,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM vw_loan_segments
GROUP BY credit_score_tier
ORDER BY default_rate DESC
;

-- Insight : Borrowers with poor credit score has more default risk (13.31%)
-- while borrowers with excellent credit score has low default risk (10.21%)


-- -------------------------------------------------------------------------
-- Q8. How does default rate vary by DTI ratio bracket?
-- -------------------------------------------------------------------------

SELECT
	DTIRatio_brackets,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM vw_loan_segments
GROUP BY DTIRatio_brackets
ORDER BY default_rate DESC
;

-- Insight: High debt burden means higher risk: 12.23% for High DTI vs 10.65% for Low DTI.


-- -------------------------------------------------------------------------
-- Q9. Do borrowers with co-signers default less ?
-- -------------------------------------------------------------------------
SELECT
	HasCoSigner,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM loan_default
GROUP BY HasCoSigner
ORDER BY default_rate DESC
;

-- Insight : Borrowers who have co-signer have default less (10.36%) than borrowers with no co-signer (12.87%)


-- -------------------------------------------------------------------------
-- Q10. Co-signer vs. employment type: where does a co-signer help most?
-- -------------------------------------------------------------------------

SELECT
	EmploymentType,
	CAST(100.0 * AVG(CASE 
						WHEN HasCoSigner = 'Yes' AND [Default] = 1 THEN 1.0  
						WHEN HasCoSigner = 'Yes' AND [Default] = 0 THEN 0.0
					END) AS DECIMAL(5,2)) AS default_rate_with_cosigner,
	CAST(100.0 * AVG(CASE 
						WHEN HasCoSigner = 'No' AND [Default] = 1 THEN 1.0  
						WHEN HasCoSigner = 'No' AND [Default] = 0 THEN 0.0
					END) AS DECIMAL(5,2)) AS default_rate_without_cosigner
FROM loan_default
GROUP BY EmploymentType
;

-- Insight: A co-signer lowers default risk for every job type
-- So it is a great safety tool for banks when lending to risky borrowers.


-- -------------------------------------------------------------------------
-- Q11. Does the higher interest rate mean higher default rate ?
-- -------------------------------------------------------------------------

SELECT
	interest_rate_bins,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM vw_loan_segments
GROUP BY interest_rate_bins
ORDER BY interest_rate_bins
;

-- Insight : Interest rate between 1-3 has low default rate (5.14%) than interest rate between 10-12 (13.69%)
-- Higher the interest rate higher the chance of default

-- -------------------------------------------------------------------------
-- Q12. Which credit score tier + DTI combinations are the riskiest?
-- -------------------------------------------------------------------------
WITH segment_risk AS(
	SELECT
		credit_score_tier,
		DTIRatio_brackets,
		SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
		CAST(100.0 * SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS default_rate
	FROM vw_loan_segments
	GROUP BY 
		credit_score_tier,
		DTIRatio_brackets
)
SELECT 
	RANK() OVER (ORDER BY default_rate DESC) AS risk_rank,
	credit_score_tier,
	DTIRatio_brackets,
	total_defaults,
	default_rate
FROM segment_risk
;

-- Insight: Poor credit combined with High DTI is the highest-risk segment,
-- and Excellent credit with Low DTI is the safest.


-- =========================================================================
-- PAGE 3: DEMOGRAPHIC PROFILING & BORROWER SEGMENTATION
-- =========================================================================

-- -------------------------------------------------------------------------
-- Q13. What is default rate by age group ?
-- -------------------------------------------------------------------------

SELECT
	age_group,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(100.0 * SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM vw_loan_segments
GROUP BY age_group
ORDER BY default_rate DESC
;

-- Insight: Age is the strongest risk driver. Default falls from 22.14% (Teen)
-- to 5.13% (Senior Citizens).


-- -------------------------------------------------------------------------
-- Q14. What is the no. of borrowers by education level and their default rate ?
-- -------------------------------------------------------------------------

SELECT
	Education,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(100.0 * SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM loan_default
GROUP BY Education
ORDER BY default_rate DESC
;

-- Insight: Borrowers are split almost evenly across the four education levels,
-- while default falls with education: High School 12.88% to PhD 10.59%.


-- -------------------------------------------------------------------------
-- Q15. Marital status vs. Has Dependents : who defaults the most?
-- -------------------------------------------------------------------------

SELECT
	MaritalStatus,
	CAST(100.0 * AVG(CASE 
						WHEN HasDependents = 'Yes' AND [Default] = 1 THEN 1.0  
						WHEN HasDependents = 'Yes' AND [Default] = 0 THEN 0.0
					END) AS DECIMAL(5,2)) AS default_rate_with_dependents,
	CAST(100.0 * AVG(CASE 
						WHEN HasDependents = 'No' AND [Default] = 1 THEN 1.0  
						WHEN HasDependents = 'No' AND [Default] = 0 THEN 0.0
					END) AS DECIMAL(5,2)) AS default_rate_without_dependents
FROM loan_default
GROUP BY MaritalStatus
;

-- Insight: Divorced borrowers without dependents are riskiest (13.89%),
-- and Married borrowers with dependents are safest (9.48%).


-- =========================================================================
-- PAGE 4: FINANCIAL RISK & PORTFOLIO GROWTH TRENDS
-- =========================================================================

-- -------------------------------------------------------------------------
-- Q16. What is the year-over-year change in loan amount and default cases?
-- (window function: LAG)
-- -------------------------------------------------------------------------

WITH yearly	AS(
SELECT
	loan_year,
	SUM(CAST(LoanAmount AS BIGINT)) / 1000000.0 AS total_loan_million,
	SUM(CASE WHEN [Default] = 1 THEN  1 ELSE 0 END) AS total_default
FROM vw_loan_segments
GROUP BY loan_year
)
SELECT 
	loan_year,
	total_loan_million,
	total_default,
	CAST(100.0 * (total_loan_million - LAG(total_loan_million) OVER (ORDER BY loan_year)) 
	/ NULLIF(LAG(total_loan_million) OVER (ORDER BY loan_year),0) AS DECIMAL(5,2)) AS yoy_loan_amount,
	CAST(100.0 * (total_default - LAG(total_default) OVER (ORDER BY loan_year))
	/ NULLIF(LAG(total_default) OVER (ORDER BY loan_year),0) AS DECIMAL(5,2)) yoy_default_cases
FROM yearly
;

-- Insight: Loan growth and default cases move together. Both fell in 2014 and
-- 2017 (-1.53% / -2.57% and -1.08% / -2.83%) and rebounded in 2015 and 2018
--  (loan amount +1.30% and +1.73%),(default cases +2.70% and +1.89%).


-- -------------------------------------------------------------------------
-- Q17. Loan amount by credit tier and marital status
-- -------------------------------------------------------------------------

SELECT
	credit_score_tier,
	MaritalStatus,
	CAST(SUM(CAST(LoanAmount AS BIGINT)) / 1000000.0 AS DECIMAL(10,0)) AS total_loan_million
FROM vw_loan_segments
GROUP BY 
	credit_score_tier, MaritalStatus
ORDER BY credit_score_tier, total_loan_million DESC
;

-- Insight: Good credit tier borrowers hold the highest total loan volume, 
-- while exposure is evenly balanced across marital statuses within each tier.


-- -------------------------------------------------------------------------
-- Q18. Income bracket and employment type: where is the income concentrated?
-- -------------------------------------------------------------------------

SELECT
	income_bracket,
	EmploymentType,
	COUNT(*) AS total_borrowers,
	CAST(SUM(CAST(Income AS BIGINT)) / 1000000.0 AS DECIMAL(10,0)) AS total_income_million,
	CAST(100.0 * SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS default_rate
FROM vw_loan_segments
GROUP BY 
	income_bracket, EmploymentType
ORDER BY income_bracket, total_income_million DESC
;

-- Insight: High Income borrowers hold Most of the total income,
-- and the Low Income bracket has the highest default rates.


-- -------------------------------------------------------------------------
-- Q19. Final risk scorecard: all key segments ranked against the portfolio average
-- -------------------------------------------------------------------------

WITH portfolio AS (
	SELECT 
		100.0 * SUM(CASE WHEN [Default] = 1 THEN  1 ELSE 0 END) / COUNT(*) AS portfolio_default_rate
	FROM loan_default
),
segments AS (
	SELECT 'Age Group' as dimensions, age_group as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Credit Score Tier' as dimensions, credit_score_tier as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'DTI Ratio Bracket' as dimensions, DTIRatio_brackets as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Income Bracket' as dimensions, income_bracket as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Employment type' as dimensions, EmploymentType as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Marital Status' as dimensions, MaritalStatus as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Education' as dimensions, Education as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Loan Purpose' as dimensions, LoanPurpose as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Has Dependents' as dimensions, HasDependents as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Has Mortgage' as dimensions, HasMortgage as segments, [Default] FROM vw_loan_segments
	UNION ALL
	SELECT 'Has Co-signer' as dimensions, HasCoSigner as segments, [Default] FROM vw_loan_segments
)
SELECT
	s.dimensions,
	s.segments,
	COUNT(*) AS total_borrowers,
	SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) AS total_defaults,
	CAST(100.0 * SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS default_rate,
	CAST(100.0 * SUM(CASE WHEN [Default] = 1 THEN 1 ELSE 0 END) / COUNT(*) - p.portfolio_default_rate AS DECIMAL(5,2))  AS vs_portfolio_pp
FROM
	segments s
CROSS JOIN
	portfolio p
GROUP BY s.dimensions, s.segments, portfolio_default_rate
ORDER BY vs_portfolio_pp DESC
;

-- Insight: Teens (22.14%) and low earners (21.96%) are the furthest above
-- the 11.61% bank average across all categories, making age the primary tool for loan approvals and pricing.
