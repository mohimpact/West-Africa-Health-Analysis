- 1. Location Dimension
CREATE TABLE dim_locations (
    iso3 CHAR(3) PRIMARY KEY,
    setting VARCHAR(100),
    region VARCHAR(100),
    income_group VARCHAR(50)
);

-- 2. Indicator Dimension
CREATE TABLE dim_indicators (
    indicator_abbr VARCHAR(50) PRIMARY KEY,
    indicator_name VARCHAR(255),
    scale INT
);

-- 3. Subgroup Dimension
CREATE TABLE dim_subgroups (
    subgroup_id INT AUTO_INCREMENT PRIMARY KEY,
    subgroup VARCHAR(50),
    dimension VARCHAR(50),
    reference_subgroup INT
);

-- 4. Fact Table
CREATE TABLE fact_health_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    iso3 CHAR(3),
    indicator_abbr VARCHAR(50),
    subgroup_id INT,
    date INT,
    estimate FLOAT,
    ci_lb FLOAT,
    ci_ub FLOAT,
    setting_average FLOAT,
    FOREIGN KEY (iso3) REFERENCES dim_locations(iso3),
    FOREIGN KEY (indicator_abbr) REFERENCES dim_indicators(indicator_abbr),
    FOREIGN KEY (subgroup_id) REFERENCES dim_subgroups(subgroup_id)
);

-- Populate Locations
INSERT INTO dim_locations (iso3, setting, region, income_group)
SELECT DISTINCT iso3, setting, whoreg6, wbincome2025 FROM health_indicators;

-- Populate Indicators
INSERT INTO dim_indicators (indicator_abbr, indicator_name, scale)
SELECT DISTINCT indicator_abbr, indicator_name, indicator_scale FROM health_indicators;

-- Populate Subgroups
INSERT INTO dim_subgroups (subgroup, dimension, reference_subgroup)
SELECT DISTINCT subgroup, dimension, reference_subgroup FROM health_indicators;

-- Populate Fact Table
INSERT INTO fact_health_data (iso3, indicator_abbr, subgroup_id, date, estimate, ci_lb, ci_ub, setting_average)
SELECT 
    hi.iso3, 
    hi.indicator_abbr, 
    ds.subgroup_id, 
    hi.date, 
    hi.estimate, 
    hi.ci_lb, 
    hi.ci_ub, 
    hi.setting_average
FROM health_indicators hi
JOIN dim_subgroups ds ON hi.subgroup = ds.subgroup AND hi.dimension = ds.dimension;

What specific health topics are tracked for Africa?


%%sql
SELECT 
    DISTINCT i.indicator_name, 
    i.indicator_abbr
FROM fact_health_data f
JOIN dim_indicators i 
    ON f.indicator_abbr = i.indicator_abbr
JOIN dim_locations l 
    ON f.iso3 = l.iso3
WHERE l.region = 'African'
ORDER BY i.indicator_name;

What is the trend of Obesity in Nigeria over the years?

%%sql
SELECT 
    f.date AS Year, 
    f.estimate AS Obesity_Rate,
    f.subgroup_id -- This will tell us who the number belongs to
FROM fact_health_data f
JOIN dim_locations l ON f.iso3 = l.iso3
WHERE l.setting = 'Nigeria' 
  AND f.indicator_abbr LIKE 'NCD_BMI_30C%' 
ORDER BY Year DESC, subgroup_id;

What is the average mortality rate by Income Group in Africa?


%%sql
SELECT 
    l.income_group, 
    ROUND(AVG(f.estimate), 2) AS Avg_Mortality_Rate,
    COUNT(DISTINCT l.setting) AS Number_of_Countries
FROM fact_health_data f
JOIN dim_locations l 
    ON f.iso3 = l.iso3
JOIN dim_indicators i 
    ON f.indicator_abbr = i.indicator_abbr
WHERE 
    l.region = 'African' 
    AND i.indicator_name LIKE '%mortality%'
GROUP BY l.income_group
ORDER BY Avg_Mortality_Rate DESC;

Which health indicators in Nigeria experienced the most significant growth during the 2019 reporting spike compared to the previous year, and how did those values stabilize in 2020?

SELECT 
    f.indicator_abbr,
    SUM(CASE WHEN f.date = 2018 THEN f.estimate ELSE 0 END) AS Total_2018,
    SUM(CASE WHEN f.date = 2019 THEN f.estimate ELSE 0 END) AS Total_2019,
    SUM(CASE WHEN f.date = 2020 THEN f.estimate ELSE 0 END) AS Total_2020,
    
    -- Calculate the Growth Rate to highlight the 2019 spike
    ROUND(
        ((SUM(CASE WHEN f.date = 2019 THEN f.estimate ELSE 0 END) - 
          SUM(CASE WHEN f.date = 2018 THEN f.estimate ELSE 0 END)) 
        / NULLIF(SUM(CASE WHEN f.date = 2018 THEN f.estimate ELSE 0 END), 0)) * 100, 
    2) AS Pct_Change_2019
    
FROM fact_health_data f
JOIN dim_locations l 
    ON f.iso3 = l.iso3
WHERE l.setting = 'Nigeria' 
  AND f.date BETWEEN 2010 AND 2024
GROUP BY f.indicator_abbr
ORDER BY Pct_Change_2019 DESC;

When comparing all countries within the West African region for the peak year of 2019, how does the total health burden (aggregate estimates) of Nigeria rank against its neighbors?

SELECT 
    l.setting AS Country,
    f.date AS Year,
    SUM(f.estimate) AS Total_Value
FROM fact_health_data f
JOIN dim_locations l ON f.iso3 = l.iso3
WHERE f.date = 2019 
  AND l.setting IN ('Benin', 'Burkina Faso', 'Cabo Verde', 'Côte d''Ivoire', 'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau', 'Liberia', 'Mali', 'Mauritania', 'Niger', 'Nigeria', 'Senegal', 'Sierra Leone', 'Togo')
GROUP BY l.setting, f.date
ORDER BY Total_Value DESC;

