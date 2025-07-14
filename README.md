# 📊 SQL Login Activity Analysis Project

**Objective:** Analyze user engagement patterns, session metrics, and inactive users using PostgreSQL.  

### 🛠️ Skills Demonstrated  
- **SQL**: Complex queries, window functions (`ROW_NUMBER()`, `LAG()`), date arithmetic  
- **Analysis**: Cohort tracking, trend identification, KPI calculation  
- **Optimization**: Multiple solutions for each problem  
- **Business Insights**: Translating raw data into actionable metrics  

---

## 🔍 Key Queries  
| # | Analysis Type               | Business Use Case                          | SQL Technique Used              |  
|---|-----------------------------|--------------------------------------------|----------------------------------|  
| 1 | Inactive Users              | Identify churn risks                       | `HAVING` with date intervals    |  
| 2 | Quarterly Session Growth    | Track product engagement trends            | `DATE_TRUNC`, `LAG()` for % change |  
| 3 | Daily Top Performers        | Reward high-engagement users               | `ROW_NUMBER()` partitioning     |  
| 4 | Perfect Attendance Users    | Detect power users for loyalty programs    | Date range vs. login day counts |  

---

## 🚀 Quick Start  
1. **Set up the database**:  
   ```sql
   CREATE TABLE users1 (
       USER_ID INT PRIMARY KEY, 
       USER_NAME VARCHAR(20) NOT NULL, 
       USER_STATUS VARCHAR(20) NOT NULL
   );
   
   CREATE TABLE logins (
       USER_ID INT REFERENCES users1(USER_ID),
       LOGIN_TIMESTAMP TIMESTAMP NOT NULL,
       SESSION_ID INT PRIMARY KEY,
       SESSION_SCORE INT
   );
