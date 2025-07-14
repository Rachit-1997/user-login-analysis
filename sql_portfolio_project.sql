/*
# Login Activity Analysis Portfolio Project

This project analyzes user login patterns and session data to provide business insights.
The database contains two tables:
- users1: User information (ID, name, status)
- logins: Login records with timestamps and session scores

Created: June 2024
Author: [Your Name]
*/

-- =============================================
-- Database Schema Setup
-- =============================================

-- Complete SQL File for Login Analysis Project (Ready for Recruiters)
-- Includes ALL sample data for testing

-- 1. Table Creation
CREATE TABLE users1 (
    USER_ID INT PRIMARY KEY, 
    USER_NAME VARCHAR(20) NOT NULL, 
    USER_STATUS VARCHAR(20) NOT NULL
);

CREATE TABLE logins (
    USER_ID INT, 
    LOGIN_TIMESTAMP TIMESTAMP NOT NULL, 
    SESSION_ID INT PRIMARY KEY, 
    SESSION_SCORE INT, 
    FOREIGN KEY (USER_ID) REFERENCES USERS1(USER_ID)
);

-- 2. COMPLETE Sample Data (28 Records)
-- Users Table
INSERT INTO USERS1 VALUES 
(1,'Alice','Active'),(2,'Bob','Inactive'),(3,'Charlie','Active'),
(4,'David','Active'),(5,'Eve','Inactive'),(6,'Frank','Active'),
(7,'Grace','Inactive'),(8,'Heidi','Active'),(9,'Ivan','Inactive'),
(10,'Judy','Active');

-- Logins Table (All 28 Records)
INSERT INTO LOGINS VALUES 
(1,'2023-07-15 09:30:00',1001,85),
(2,'2023-07-22 10:00:00',1002,90),
(3,'2023-08-10 11:15:00',1003,75),
(4,'2023-08-20 14:00:00',1004,88),
(5,'2023-09-05 16:45:00',1005,82),
(6,'2023-10-12 08:30:00',1006,77),
(7,'2023-11-18 09:00:00',1007,81),
(8,'2023-12-01 10:30:00',1008,84),
(9,'2023-12-15 13:15:00',1009,79),
(1,'2024-01-10 07:45:00',1011,86),
(2,'2024-01-25 09:30:00',1012,89),
(3,'2024-02-05 11:00:00',1013,78),
(4,'2024-03-01 14:30:00',1014,91),
(5,'2024-03-15 16:00:00',1015,83),
(6,'2024-04-12 08:00:00',1016,80),
(7,'2024-05-18 09:15:00',1017,82),
(8,'2024-05-28 10:45:00',1018,87),
(9,'2024-06-15 13:30:00',1019,76),
(10,'2024-06-25 15:00:00',1010,92),
(10,'2024-06-26 15:45:00',1020,93),
(10,'2024-06-27 15:00:00',1021,92),
(10,'2024-06-28 15:45:00',1022,93),
(1,'2024-01-10 07:45:00',1101,86),
(3,'2024-01-25 09:30:00',1102,89),
(5,'2024-01-15 11:00:00',1103,78),
(2,'2023-11-10 07:45:00',1201,82),
(4,'2023-11-25 09:30:00',1202,84),
(6,'2023-11-15 11:00:00',1203,80);

-- 3. Key Analysis Queries (From Your Project)
-- Example: Inactive Users Query
SELECT user_id 
FROM logins
GROUP BY user_id
HAVING MAX(login_timestamp) < ('2024-06-28'::date - INTERVAL '5 months');
-- =============================================
-- Analysis Queries
-- =============================================

/*
1. Identify inactive users - Users who haven't logged in for the past 5 months
(as of June 28, 2024)
*/
-- Method 1: Using HAVING with max login timestamp
SELECT user_id, max(login_timestamp) as last_login 
FROM logins
GROUP BY user_id 
HAVING max(login_timestamp) < ('2024-06-28'::date - interval '5 Months')
ORDER BY user_id;

-- Method 2: Using NOT IN subquery
SELECT DISTINCT user_id 
FROM logins 
WHERE user_id NOT IN (
    SELECT user_id 
    FROM logins
    WHERE login_timestamp > ('2024-06-28'::date - interval '5 Months')
)
ORDER BY user_id;

/*
2. Quarterly Analysis - Count of users and sessions per quarter
*/
SELECT 
    date_trunc('quarter', min(login_timestamp))::date as quarter, 
    count(*) as total_sessions,
    count(distinct user_id) as total_users
FROM logins
GROUP BY date_part('quarter', login_timestamp);

/*
3. Users who logged in Jan 2024 but not Nov 2023
(Identifying new/returning users after a gap)
*/
SELECT DISTINCT user_id 
FROM logins 
WHERE to_char(login_timestamp, 'YYYY-MM') = '2024-01' 
AND user_id NOT IN (
    SELECT user_id 
    FROM logins 
    WHERE to_char(login_timestamp, 'YYYY-MM') = '2023-11'
);

/*
4. Enhanced Quarterly Analysis with % Change
Adds quarter-over-quarter session growth metrics
*/
WITH quarterly_stats AS (
    SELECT 
        date_trunc('quarter', min(login_timestamp))::date as quarter,
        count(*) as session_cnt,
        count(distinct user_id) as total_users
    FROM logins
    GROUP BY date_part('quarter', login_timestamp)
)
SELECT 
    *,
    lag(session_cnt) OVER (ORDER BY quarter) as prev_session,
    round((session_cnt - lag(session_cnt) OVER (ORDER BY quarter))*100.0/ 
          lag(session_cnt) OVER (ORDER BY quarter), 2) as pct_change
FROM quarterly_stats;

/*
5. Daily Top Performers - Users with highest session score each day
*/
WITH daily_scores AS (
    SELECT 
        user_id, 
        login_timestamp::date as login_date, 
        sum(session_score) as score 
    FROM logins
    GROUP BY user_id, login_timestamp::date
)
SELECT * FROM (
    SELECT 
        *,
        row_number() OVER(PARTITION BY login_date ORDER BY score DESC) as rank
    FROM daily_scores
) ranked
WHERE rank = 1;

/*
6. Perfect Attendance Users - Logged in every day since first login
*/
-- Method 1: Comparing date range with distinct login days
SELECT 
    USER_ID,
    MIN(LOGIN_TIMESTAMP::date) as first_login,
    ('2024-06-28' - MIN(LOGIN_TIMESTAMP::date) + 1) as days_since_first_login,
    COUNT(DISTINCT LOGIN_TIMESTAMP::date) as login_days
FROM logins
GROUP BY user_id
HAVING ('2024-06-28' - MIN(LOGIN_TIMESTAMP::date) + 1) = 
       COUNT(DISTINCT LOGIN_TIMESTAMP::date)
ORDER BY user_id;

-- Method 2: Checking consecutive day logins
WITH login_gaps AS (
    SELECT 
        *,
        lag(login_timestamp::date) OVER(PARTITION BY user_id ORDER BY login_timestamp::date) as prev_login,
        login_timestamp::date - lag(login_timestamp::date) OVER(PARTITION BY user_id ORDER BY login_timestamp::date) as day_gap,
        max(login_timestamp::date) OVER(PARTITION BY user_id) as last_login
    FROM logins
)
SELECT user_id 
FROM (
    SELECT 
        user_id,
        last_login,
        CASE WHEN min(day_gap) = 1 AND max(day_gap) = 1 THEN 1 ELSE 0 END as perfect_attendance
    FROM login_gaps
    GROUP BY user_id, last_login
) stats
WHERE perfect_attendance = 1 AND last_login = '2024-06-28';

/*
7. Dates with no login activity
*/
-- Method 1: Using calendar table join
SELECT c.date_key as inactive_date
FROM (
    SELECT 
        min(login_timestamp::date) as start_date, 
        max(login_timestamp::date) as end_date 
    FROM logins
) date_range
JOIN calendar_dim c ON c.date_key BETWEEN date_range.start_date AND date_range.end_date
WHERE date_key NOT IN (SELECT DISTINCT login_timestamp::date FROM logins);

-- Method 2: Using recursive CTE to generate dates
WITH RECURSIVE date_series AS (
    SELECT min(login_timestamp::date) as date FROM logins
    UNION ALL
    SELECT date + 1 FROM date_series
    WHERE date < (SELECT max(login_timestamp::date) FROM logins)
SELECT date as inactive_date
FROM date_series
WHERE date NOT IN (SELECT DISTINCT login_timestamp::date FROM logins);