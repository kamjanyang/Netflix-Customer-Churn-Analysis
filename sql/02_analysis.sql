-- churn by days since last login
SELECT inactivity_bucket,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct
FROM churn_analysis
GROUP BY inactivity_bucket
ORDER BY MIN(last_login_days);

-- churn by engagement level (quartile 1 = lowest watch hours)
SELECT watch_quartile,
       MIN(watch_hours) AS min_hours,
       MAX(watch_hours) AS max_hours,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct
FROM churn_analysis
GROUP BY watch_quartile
ORDER BY watch_quartile;

-- does inactivity matter within every tier?
SELECT subscription_type,
       CASE WHEN last_login_days > 30 THEN '30+ days' ELSE '30 or fewer' END AS inactivity,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct
FROM netflix_churn
GROUP BY subscription_type, inactivity
ORDER BY subscription_type, inactivity;

SELECT subscription_type, monthly_fee,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct,
       ROUND(SUM(CASE WHEN churned = 1 THEN monthly_fee ELSE 0 END), 2) AS monthly_revenue_lost,
       ROUND(SUM(CASE WHEN churned = 0 THEN monthly_fee ELSE 0 END), 2) AS monthly_revenue_retained
FROM netflix_churn
GROUP BY subscription_type, monthly_fee
ORDER BY monthly_fee;

-- regions ranked by risk (window function)
SELECT region,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct,
       RANK() OVER (ORDER BY AVG(churned) DESC) AS risk_rank
FROM netflix_churn
GROUP BY region;

-- age groups
SELECT age_group,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct
FROM churn_analysis
GROUP BY age_group
ORDER BY age_group;

-- region and tier together (skip tiny groups)
SELECT region, subscription_type,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct
FROM netflix_churn
GROUP BY region, subscription_type
HAVING COUNT(*) >= 30
ORDER BY churn_rate_pct DESC;

SELECT payment_method,
       COUNT(*) AS subscribers,
       ROUND(100 * AVG(churned), 1) AS churn_rate_pct,
       ROUND(AVG(monthly_fee), 2) AS avg_fee,
       ROUND(AVG(watch_hours), 1) AS avg_watch_hours
FROM netflix_churn
GROUP BY payment_method
ORDER BY churn_rate_pct DESC;

WITH at_risk AS (
  SELECT *
  FROM netflix_churn
  WHERE churned = 0 AND last_login_days > 30
)
SELECT subscription_type,
       COUNT(*) AS at_risk_subscribers,
       ROUND(SUM(monthly_fee), 2) AS monthly_revenue_at_risk
FROM at_risk
GROUP BY subscription_type
ORDER BY monthly_revenue_at_risk DESC;