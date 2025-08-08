create database INSURANCE;
use INSURANCE;
select  * from brokerage;
select  * from budget;
select  * from fees;
select  * from invoice;
select  * from meeting;
select  * from opprtunity;

-- 1) No of Meetings per Executive
select account_executive, count(*) as meeting_count from meeting group by account_executive order by meeting_count desc;

-- 2)no of invoice per executive
select account_executive, count(*) as invoice_count from invoice group by account_executive order by invoice_count desc;

-- 3)Yearly meeting count
 SELECT 
  YEAR(STR_TO_DATE(meeting_date, '%d-%b-%y')) AS Year,
  COUNT(*) AS Meeting_Count
FROM meeting
WHERE STR_TO_DATE(meeting_date, '%d-%b-%y') IS NOT NULL
GROUP BY YEAR(STR_TO_DATE(meeting_date, '%d-%b-%y'));

-- 4)total opportunities
select count(*) as totalopportunities from opprtunity;

-- 5)Total open opportunities
select count(*) as Openopportunities from opprtunity where stage in ("Qualify Opportunity", "Propose Solution");

-- 6) open opportunities top 4
select product_group, sum(revenue_amount) as revenue from opprtunity where stage in("Qualify Opportunity", "Propose Solution") group by product_group order by  Revenue desc limit 4;


-- 7)top 4 Opportunity by Revenue
select product_group, sum(revenue_amount) as TotalRevenue from opprtunity group by product_group order by TotalRevenue Desc limit 4;

-- 8)stages by Revenue
select stage,sum(revenue_amount) as Revenue from opprtunity group by stage;

-- 9)Opportunity Product Distribution
select product_group, count(*) as Count from opprtunity group by product_group;

-- 10.a) Cross sell target
select sum( Cross_Sell_Budget) from budget;
-- 10.b) New target
select sum( New_Budget) from budget;
-- 10.c) Renewal Target
select sum( Renewal_Budget) from budget;
-- best practise- everything in single line as below
select sum(Cross_Sell_Budget) as cross_target,sum(New_Budget) as new_target,sum(Renewal_Budget) as renewal_target from budget;

-- 11.a) Cross Sell Achieved
select sum(Amount) from brokerage where income_class="Cross Sell";
-- 11.b) New Achieved
select sum(Amount) from brokerage where income_class="New";
-- 11.c) Renewal Achieved
select sum(Amount) from brokerage where income_class="Renewal";
 --  best practice-everything in single line as below
select income_class, sum(amount) as Achieved from brokerage group by income_class order by sum(amount) desc;

-- 12.a)Cross Sell invoice
select sum(Amount) from invoice where income_class="Cross Sell";
-- 12.b)New invoice
select sum(Amount) from invoice where income_class="New";
-- 12.c) Renewal invoice
select sum(Amount) from invoice where income_class="Renewal";
--  best practice - everything in single line
select income_class, sum(Amount) from invoice group by income_class order by  sum(Amount) desc;

-- 13) Find out Target,Achieved,invoice for Cross Sell, New, Renewal
-- Aggregate targets from Budget table
 WITH TargetByIncomeClass AS (
    SELECT 
        'Cross Sell' AS income_class, SUM(Cross_Sell_Budget) AS Target FROM budget
    UNION ALL
    SELECT 
        'New' AS income_class, SUM(New_Budget) FROM budget
    UNION ALL
    SELECT 
        'Renewal' AS income_class, SUM(Renewal_Budget) FROM budget
),

-- Combine Achieved from Brokerage + Fees
AchievedByIncomeClass AS (
    SELECT 
        income_class, SUM(amount) AS Achieved
    FROM (
        SELECT income_class, amount FROM Brokerage
        UNION ALL
        SELECT income_class, amount FROM Fees
    ) AS combined
    GROUP BY income_class
),

-- Aggregate Invoice
InvoiceByIncomeClass AS (
    SELECT 
        income_class, SUM(Amount) AS Invoice
    FROM invoice
    GROUP BY income_class
)

-- Final Output
SELECT 
    t.income_class,
    t.Target,
    a.Achieved,
    i.Invoice,
    ROUND(a.Achieved * 100.0 / NULLIF(t.Target, 0), 2) AS AchievementPercent,
    ROUND(i.Invoice * 100.0 / NULLIF(t.Target, 0), 2) AS InvoicePercent
FROM 
    TargetByIncomeClass t
LEFT JOIN AchievedByIncomeClass a ON t.income_class = a.income_class
LEFT JOIN InvoiceByIncomeClass i ON t.income_class = i.income_class;
