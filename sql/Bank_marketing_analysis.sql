-- Dataset overview
SELECT COUNT(*) FROM bank;
-- 11162 rows

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bank';

SELECT * FROM bank LIMIT 10;
-- 17 COLUMNS

-- Missing value assesment
SELECT
  SUM(CASE WHEN job = 'unknown' THEN 1 ELSE 0 END) AS unknown_job,
  SUM(CASE WHEN education = 'unknown' THEN 1 ELSE 0 END) AS unknown_education,
  SUM(CASE WHEN contact = 'unknown' THEN 1 ELSE 0 END) AS unknown_contact,
  SUM(CASE WHEN poutcome = 'unknown' THEN 1 ELSE 0 END) AS unknown_poutcome
FROM bank;
-- job-70, education-497, contact-2346, poutcome-8326
SELECT
  SUM(age IS NULL) AS null_age,
  SUM(balance IS NULL) AS null_balance,
  SUM(duration IS NULL) AS null_duration
FROM bank;
-- No null values were found
-- Summary statistics for numeric columns
SELECT
  MIN(age) AS min_age, MAX(age) AS max_age, AVG(age) AS avg_age,
  MIN(balance) AS min_balance, MAX(balance) AS max_balance, AVG(balance) AS avg_balance,
  MIN(duration) AS min_duration, MAX(duration) AS max_duration, AVG(duration) AS avg_duration,
  MIN(campaign) AS min_campaign, MAX(campaign) AS max_campaign, AVG(campaign) AS avg_campaign,
  MIN(pdays) AS min_pdays, MAX(pdays) AS max_pdays, AVG(pdays) AS avg_pdays,
  MIN(previous) AS min_previous, MAX(previous) AS max_previous, AVG(previous) AS avg_previous
FROM bank;
-- Distribution
-- Age 
SELECT
  CASE
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS total
FROM bank
GROUP BY age_group
ORDER BY age_group;
-- 18-30  2007, 31-45  5522, 46-60	3022, 60+	611

-- Job distribution
SELECT job, COUNT(*) AS total FROM bank GROUP BY job ORDER BY total DESC;

-- Education distribution
SELECT education, COUNT(*) AS total FROM bank GROUP BY education ORDER BY total DESC;
-- secondary	5476, tertiary	3689, primary	1500, unknown	497

-- Target variable distribution (deposit yes/no)
SELECT deposit, COUNT(*) AS total,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank), 2) AS pct
FROM bank
GROUP BY deposit;
-- yes	5289	47.38
-- no	5873	52.62


-- Investigating the business problem (Why do some customers subscribe to term deposit and some don't)
-- Subscription rate by age group
SELECT
  CASE
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY age_group
ORDER BY conversion_rate DESC;
-- customers above the age 60 and customers within the age group of 18-30 are most likey to subscribe to term deposit while middle aged
-- customers might be more reluctant. So age is a conversion factor

-- Subscription rate by job
SELECT job,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY job
ORDER BY conversion_rate DESC;
-- This shows that students,retired and unemployed individuals are most likely to be converted to subscribers and from the lowest blue-collar,
-- entreprenur and housemaid
-- Subscription rate by education
SELECT education,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY education
ORDER BY conversion_rate DESC;
-- Top conversion rate by education is the tertiary and the lowest being primary, meaning literacy might be a factor for conversion

-- does housing loan or personal loan affect the rate of conversion
SELECT housing,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY housing;
-- customers with housing loans are less likely to subsribe to a term deposit than customers with no housing loans

SELECT loan,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY loan;
-- customers with private loans are less likely to subsribe to a term deposit than customers without private loans
-- So loan might also be a factor or a key driver

-- are previous subscribers likely to subscribe again
SELECT poutcome,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
WHERE poutcome != 'unknown'
GROUP BY poutcome
ORDER BY conversion_rate DESC;
-- previously converted customers are most likely to subscribe to term deposit again

-- Does seasons affect conversion rate of customers
SELECT month,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY month
ORDER BY conversion_rate DESC;
-- the conversion rate is the highest in december and lowest in may

-- Is the method of contact a factor
SELECT contact,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY contact
ORDER BY conversion_rate DESC;
-- the cellular method of contact is the most effective as it covers more customers and the conversion rate is also higher

SELECT campaign,
  COUNT(*) AS total,
  SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) AS converted,
  ROUND(SUM(CASE WHEN deposit = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM bank
GROUP BY campaign
ORDER BY campaign;
-- the higher the  campaign the lesser the conversion rate.