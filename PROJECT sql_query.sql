USE project;

SELECT * FROM hr;

-- Data Cleaning and preprocessing --

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

-- Changing the data format and datatype of birthdate column --

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- Changing the data format and datatype of hire_date column --

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- -- Changing the data format and datatype of termdate column --

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- Creating age column --

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

-- QUESTIONS -- 

-- 1. What is the gender breakdown of the employees in the company? --

SELECT gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of the employees in the company? --

SELECT race, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of the employees in the company? --

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

SELECT
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
    COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations? --

SELECT location, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the average length of the employment for the employees who have been terminated? --

SELECT  
ROUND(AVG(datediff(termdate, hire_date))/365) AS avg_length_employment
FROM hr
WHERE termdate IS NOT NULL AND termdate <= CURDATE() AND AGE>=18;

-- 6. How does the gender distribution vary across departments and job titles? --

SELECT department, jobtitle, gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender;

SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department, gender;

-- 7. What is the distribution of job titles across the company? --

SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age>=18
GROUP BY jobtitle;

-- 8. Which department has the higher turnover/termination rate? --

SELECT department,
		COUNT(*) AS total_count,
        COUNT(CASE
					WHEN termdate <> '0000-00-00' AND termdate<=CURDATE() THEN 1
                    END) AS terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate <> '0000-00-00' AND termdate<=CURDATE() THEN 1
                    END)/COUNT(*))*100, 2) AS termination_rate
		FROM hr
        GROUP BY department
        ORDER BY termination_rate DESC;
        
SELECT department,
  total_count,
  terminated_count,
 ROUND((terminated_count/total_count)*100,2) AS termination_rate
FROM (
	SELECT department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery 
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees acroos location state? -- 

SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state;

SELECT location_city, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_city;

-- 10. How has the company's employee count changed over time based on hire and term dates? --

SELECT year,
		hires,
        terminations,
        hires - terminations AS net_change,
        ((hires - terminations)/hires)*100 AS net_change_percent
	FROM (
			SELECT year (hire_date) AS year,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate <> '0000-00-00'  AND termdate <= CURDATE() THEN 1
                    END) AS terminations
			FROM hr
            GROUP BY year(hire_date)) AS subquery
ORDER BY year;

