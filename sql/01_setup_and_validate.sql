CREATE DATABASE netflix_churn_analysis CHARACTER SET utf8mb4;
USE netflix_churn_analysis;

CREATE TABLE netflix_churn (
  customer_id            VARCHAR(36) PRIMARY KEY,
  age                    INT,
  gender                 VARCHAR(30),
  subscription_type      VARCHAR(30),
  watch_hours            DECIMAL(6,2),
  last_login_days        INT,
  region                 VARCHAR(50),
  device                 VARCHAR(30),
  monthly_fee            DECIMAL(5,2),
  churned                TINYINT,
  payment_method         VARCHAR(30),
  number_of_profiles     TINYINT,
  avg_watch_time_per_day DECIMAL(4,2),
  favorite_genre         VARCHAR(30)
);

-- VALIDATE
-- row count, unique customers, overall churn rate
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT customer_id) AS unique_customers,
       ROUND(100 * AVG(churned), 2) AS churn_rate_pct
FROM netflix_churn;

-- missing values in key columns
SELECT SUM(age IS NULL) AS null_age,
       SUM(watch_hours IS NULL) AS null_watch_hours,
       SUM(last_login_days IS NULL) AS null_last_login,
       SUM(churned IS NULL) AS null_churned
FROM netflix_churn;

-- ranges
SELECT MIN(age), MAX(age), MIN(watch_hours), MAX(watch_hours),
       MIN(last_login_days), MAX(last_login_days)
FROM netflix_churn;

-- does monthly_fee match the tier?
SELECT subscription_type, monthly_fee, COUNT(*) AS subscribers
FROM netflix_churn
GROUP BY subscription_type, monthly_fee;

-- do the two watch-time columns agree?
SELECT ROUND(AVG(watch_hours / 30), 2) AS implied_hours_per_day,
       ROUND(AVG(avg_watch_time_per_day), 2) AS stated_hours_per_day
FROM netflix_churn;

SELECT favorite_genre, COUNT(*) AS subscribers
FROM netflix_churn GROUP BY favorite_genre ORDER BY subscribers DESC;

SELECT payment_method, COUNT(*) AS subscribers
FROM netflix_churn GROUP BY payment_method ORDER BY subscribers DESC;

SELECT region, COUNT(*) AS subscribers
FROM netflix_churn GROUP BY region ORDER BY subscribers DESC;