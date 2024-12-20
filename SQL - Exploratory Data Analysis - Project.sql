/* EXPLORATORY DATA ANALYSIS - Here we are using the dataset that I have got from an earlier SQL Data Cleaning project.
In this project we are doing analysis based on the data aquired


Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types

*/

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funs_raised_millions DESC;

SELECT company, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`DATE`), MAX(`DATE`)
FROM layoffs_staging2; 

SELECT industry, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT `DATE`, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY `DATE`
ORDER BY 2 DESC;

SELECT YEAR(`DATE`), SUM(total_laid_off) FROM layoffs_staging2
GROUP BY YEAR(`DATE`)
ORDER BY 1 DESC;


SELECT STAGE, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY STAGE
ORDER BY 2 DESC;

SELECT SUBSTRING(`DATE`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`DATE`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
;

WITH ROLLING_TOTAL AS
(
SELECT SUBSTRING(`DATE`,1,7) AS `MONTH`,
SUM(total_laid_off) AS TOTAL_OFF
FROM layoffs_staging2
WHERE SUBSTRING(`DATE`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, TOTAL_OFF, SUM(TOTAL_OFF) OVER(ORDER BY `MONTH`) AS ROLLING_TOTAL
FROM ROLLING_TOTAL;

SELECT company, YEAR(`DATE`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`DATE`)
ORDER BY 3 DESC;

WITH COMPANY_YEAR(company,years, total_laid_off) AS
(

SELECT company, YEAR(`DATE`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`DATE`)
),
COMPANY_YEAR_RANK AS
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY YEARS ORDER BY total_laid_off DESC) AS RANKING
FROM COMPANY_YEAR
WHERE YEARS IS NOT NULL
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANKING <=5
;
