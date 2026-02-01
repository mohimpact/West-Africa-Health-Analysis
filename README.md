# West-Africa-Health-Analysis
A SQL and Power BI project analyzing health disparities in West Africa using WHO data and a Star Schema model.
# West African Health Inequality Analysis (WHO Data)

## 📌 Project Overview
I analyzed over **147,000 rows** of health data sourced from the **World Health Organization (WHO)**. This project focuses on identifying health service delivery gaps across 16 West African countries, with a deep dive into Nigeria, Liberia, Togo, and Cabo Verde.

## 🛠️ The Workflow
1. **Data Sourcing:** Extracted 147k rows from the WHO Global Health Observatory.
2. **Data Modeling:** Imported the flat file into **MySQL** and transformed it into a **Star Schema** (Fact & Dimension tables) for better performance.
3. **Feature Engineering:** Created an `indicator_category` column to group complex metrics into summaries like Mortality, Nutrition, and Adolescent Health.
4. **SQL Analysis:** Used CTEs and Window Functions to find growth trends and regional rankings.

## 📂 Project Structure
```text
├── Data/            # Raw and cleaned datasets
├── Scripts/         # SQL scripts for modeling and analysis
├── Dashboard/       # Power BI (.pbix) file and screenshots
└── README.md        # Project documentation
