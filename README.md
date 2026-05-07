# 🍔 Swiggy Sales Analysis (SQL Project)

## 📌 Project Overview
The Swiggy Sales Analysis project focuses on analyzing food delivery transactional data using SQL to uncover meaningful business insights related to customer ordering behavior, restaurant performance, cuisine trends, revenue patterns, and ratings analysis.

This project demonstrates end-to-end SQL analytics including:
- Data Cleaning
- Data Validation
- Dimensional Modelling (Star Schema)
- KPI Development
- Business Insights Generation

---

# 🎯 Business Objectives
- Identify total orders and total revenue
- Analyze monthly and quarterly sales trends
- Identify top-performing restaurants and cuisines
- Analyze customer spending behavior
- Understand location-based performance
- Study dish rating distribution
- Build scalable analytical models using Star Schema

---

# 🗂 Dataset Information

### Dataset Includes:
- Food delivery transactions
- Restaurant details
- Cuisine categories
- Dish-level information
- Ratings and revenue metrics

### Key Fields:
- `Order_Date`
- `State`
- `City`
- `Location`
- `Restaurant_Name`
- `Category`
- `Dish_Name`
- `Price_INR`
- `Rating`
- `Rating_Count`

---

# 🛠 Tools & Technologies Used
- **MySQL Workbench**

---

# 🧹 Data Cleaning & Validation

The raw dataset was cleaned and validated before analysis.

## Cleaning Steps Performed:
- Null value checks
- Blank/empty string checks
- Duplicate detection
- Duplicate removal using `ROW_NUMBER()`
- Data standardization

## Fields Validated:
- State
- City
- Order_Date
- Restaurant_Name
- Location
- Category
- Dish_Name
- Price_INR
- Rating
- Rating_Count

---

# ⭐ Dimensional Modelling (Star Schema)

To improve analytical performance and reporting efficiency, a Star Schema was created.

## Dimension Tables
- `dim_date`
- `dim_location`
- `dim_restaurant`
- `dim_category`
- `dim_dish`

## Fact Table
- `fact_swiggy_orders`

The fact table stores:
- Revenue
- Ratings
- Order metrics
- Foreign keys from all dimensions

---

# 📊 Key Performance Indicators (KPIs)

## Basic KPIs
- Total Orders
- Total Revenue (INR Million)
- Average Dish Price
- Average Rating

---

# 📈 SQL Business Analysis

## 📅 Date-Based Analysis
- Monthly order trends
- Quarterly order trends
- Year-wise growth
- Day-of-week ordering patterns

---

## 🌍 Location-Based Analysis
- Top 10 cities by order volume
- Revenue contribution by state
- Location-wise sales distribution

---

## 🍽 Food Performance Analysis
- Top restaurants by orders
- Most ordered dishes
- Cuisine-wise performance
- Category-level sales analysis

---

## 💰 Customer Spending Insights

Customer spending analysis was performed using price buckets:

- Under ₹100
- ₹100–199
- ₹200–299
- ₹300–499
- ₹500+

This helps identify customer purchasing behavior and spending patterns.

---

# ⭐ Ratings Analysis
- Rating distribution from 1–5
- Average ratings by cuisine
- Restaurant rating analysis

---

# 🧮 SQL Concepts Used
- Joins
- CTEs
- Window Functions
- CASE Statements
- Aggregate Functions
- GROUP BY
- ORDER BY
- Star Schema Modelling
- Data Cleaning Techniques

---

# 📁 Project Structure

```plaintext
Swiggy-Sales-Analysis/
│
├── Dataset/
├── SQL Queries/
├── BRD/
├── README.md
└── Dashboard Images/
```

---

# 📌 Deliverables
- SQL Data Cleaning Scripts
- Star Schema Creation Scripts
- KPI Queries
- Business Analysis Queries
- Business Requirements Document (BRD)

---

# 🚀 Conclusion
This project demonstrates how SQL can be used to transform raw food delivery transactional data into meaningful business insights.

By implementing:
- Data cleaning
- Dimensional modelling
- KPI generation
- Trend analysis

the project provides a scalable analytical solution for understanding restaurant performance, customer behavior, and revenue trends in the food delivery industry.

---
