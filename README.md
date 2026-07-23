# Swiggy Data Analysis using SQL

## Project Overview

This project analyzes a Swiggy food-ordering dataset using MySQL to explore 
ordering patterns, revenue trends, restaurant performance, geographic 
performance, cuisine preferences, pricing patterns, and customer ratings.
The project follows an end-to-end SQL analytics workflow, including data
loading, data validation, data cleaning, dimensional modeling, ETL,
KPI calculation, and business analysis.

---

## Project Objectives

The main objectives of this project are to:

- Clean and validate the raw dataset before analysis.
- Design an analytics-ready star schema.
- Analyze order and revenue trends over time.
- Evaluate geographic performance across states and cities.
- Identify high-performing restaurants, categories, and dishes.
- Analyze pricing and rating distributions.
- Calculate Month-over-Month (MoM) revenue growth.
- Generate business-oriented insights using SQL.

---

## Tools & Technologies

- MySQL
- MySQL Workbench
- SQL
- GitHub

---

## Dataset

The dataset contains food-ordering records with the following attributes:

- State
- City
- Order Date
- Restaurant Name
- Location
- Category
- Dish Name
- Price (INR)
- Rating
- Rating Count

---

## Data Validation & Cleaning

Before performing the analysis, the dataset was validated and cleaned using SQL.

The process included:

- Checking for NULL values.
- Identifying blank or empty strings.
- Detecting duplicate records.
- Adding a unique identifier to each record.
- Removing duplicate records using `ROW_NUMBER()`.

---

## Data Modeling

The original flat dataset was transformed into a **Star Schema** to create
a structured analytical data model.

### Fact Table

`fact_swiggy_orders`

Measures stored in the fact table include:

- Price
- Rating
- Rating Count

### Dimension Tables

- `dim_date`
- `dim_location`
- `dim_restaurant`
- `dim_category`
- `dim_dish`

The fact table is connected to the dimension tables through primary and
foreign keys.

---

## ETL Process

The project implements a SQL-based ETL workflow:

**Extract**
- Imported the raw CSV dataset into MySQL.

**Transform**
- Validated NULL and blank values.
- Identified and removed duplicates.
- Converted text-based dates into MySQL date values.
- Created dimension tables using distinct attributes.

**Load**
- Loaded transformed data into dimension tables.
- Populated the central fact table using joins between the raw data and
  dimension tables.

---

## Key Performance Indicators (KPIs)

The following KPIs were calculated:

- Total Orders
- Total Revenue
- Average Order Value
- Average Rating

---

## Business Analysis

The analysis covers the following areas:

### Time-Based Analysis
- Monthly order trends
- Monthly revenue trends
- Month-over-Month revenue growth
- Quarterly order trends
- Quarterly revenue trends
- Orders by day of the week

### Geographic Analysis
- Top 10 cities by order volume
- State-wise revenue contribution

### Restaurant Analysis
- Top 10 restaurants by revenue
- Top 3 restaurants in each city

### Product & Cuisine Analysis
- Top categories by order volume
- Most ordered dishes
- Cuisine performance based on order volume and average rating

### Pricing & Rating Analysis
- Order distribution across price ranges
- Rating distribution

---

## SQL Concepts Demonstrated

This project demonstrates the use of:

- Aggregate Functions
- `GROUP BY`
- `HAVING`
- `CASE` Statements
- Joins
- Common Table Expressions (CTEs)
- Window Functions
- `ROW_NUMBER()`
- `LAG()`
- `PARTITION BY`
- Date Functions
- Primary Keys
- Foreign Keys
- Star Schema Modeling
- ETL and Data Transformation

---

## Repository Structure

    swiggy-sql-data-analysis/
    |
    |-- README.md
    |
    |-- dataset/
    |   |-- Swiggy_Data.csv
    |
    |-- sql/
    |   |-- 01_data_loading_cleaning.sql
    |   |-- 02_star_schema.sql
    |   |-- 03_business_analysis.sql
    |
    |-- images/
        |-- star_schema.png
