# 🎬 Netflix SQL Data Analysis  
**By: Swapnil Yadav**  

This project analyzes the Netflix content catalog using advanced SQL to derive business insights such as popular genres, top-performing countries, content trends, director impact, and actor involvement. It showcases real-world data analytics skills using **MySQL** and demonstrates the ability to solve stakeholder questions using structured queries.

---

## 🧰 Tools & Technologies
- **MySQL** (Database & SQL Engine)  
- **MySQL Workbench** (Query Execution & Visualization)  
- **Netflix Titles Dataset (CSV)**  

---

## 🎯 Project Objective
The goal of this project is to answer 15 business-driven questions related to content strategy, audience interests, and catalog distribution on Netflix, using complex SQL operations like **CTEs, window functions, date parsing, and string splitting**.

---

## 📂 Folder Structure (Recommended)
Netflix-SQL-Analysis/

├── data/
│ └── netflix_titles.csv

├── sql/
│ └── queries.sql <-- (Optional: Store all SQL queries here)

└── README.md <-- Project Documentation

----

## 📊 Dataset Overview – Columns Used
| Column         | Description                          |
|----------------|--------------------------------------|
| show_id        | Unique ID of the title               |
| type           | Movie or TV Show                     |
| title          | Name of the content                  |
| director       | Director name(s)                     |
| cast           | Main actors                          |
| country        | Production country                   |
| date_added     | Date added to Netflix                |
| release_year   | Original release year                |
| rating         | Maturity rating (TV-MA, PG, etc.)    |
| duration       | Runtime or number of seasons         |
| listed_in      | Genre/category                       |
| description    | Short summary                        |

---

## ❓ 15 Business Questions Solved with SQL

1️⃣ Count the number of Movies vs TV Shows  
2️⃣ Most common rating for Movies and TV Shows  
3️⃣ List all Movies released in a specific year (e.g., 2020)  
4️⃣ Top 5 countries with the most content  
5️⃣ Identify the longest Movie  
6️⃣ Find content added in the last 5 years  
7️⃣ All Movies/TV Shows by director **Rajiv Chilaka**  
8️⃣ TV Shows with more than 5 seasons  
9️⃣ Count of content items per **genre**  
🔟 Year-wise average monthly content additions in the **United States** (Top 5 years)  
1️⃣1️⃣ All Movies that are **Documentaries**  
1️⃣2️⃣ Content without a **director**  
1️⃣3️⃣ How many Movies actor **Salman Khan** appeared in the last 10 years  
1️⃣4️⃣ Top 10 actors appearing in the most **U.S.-produced Movies**  
1️⃣5️⃣ Classify content as **‘Good’ or ‘Bad’** based on keywords (`kill`, `violence`) in description  

---
## 🧠 SQL Concepts Applied
SQL Concept	Usage in Project
CTEs (WITH)	Ranking ratings, year-based aggregation
Window Functions	Most common rating per category
String Functions	Splitting genres, actors, countries
Date Parsing	Last 5 years content
Conditional Logic (CASE)	Content labels: Good vs Bad

---

## How to Run This Project (MySQL)

Create Database

CREATE DATABASE netflix_db;
USE netflix_db;


Import CSV into the netflix_titles table
(Using Workbench Table Data Import Wizard or LOAD DATA INFILE)

Create the Cleaned View
(Handles date parsing, duration split, season extraction)

CREATE OR REPLACE VIEW netflix_clean AS
SELECT ... (Full code included in queries)

Run SQL Queries to Answer Business Questions

----
## 🏁 Conclusion

This project demonstrates real-world business intelligence using SQL on streaming industry data. From content classification to country-based insights, it showcases strong analytical abilities and problem-solving skills applicable to roles in Data Analytics, BI, and Data Engineering.
