/* 
THIS IS A DATA CLEANING PROJECT HERE WE HAVE A DATASET HAVING DATA ABOUT THE LAYOFFS OF PEOPLE FROM DIFFERENT COMPANIES AROUND THE WORLD. 
i HAVE USED SQL CONCEPTS LIKE DDL, DML, JOIN AND STRING FUNCTIONS TO CLEAN AND MAKE THIS DATA PRESENTABLE AND WORKABLE FOR FURTHER ANALYSIS
*/

-- I have also uploaded the dataset which I have used here named - 'layoffs.csv'
SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA (SPELLINGS, WRONG DATA, ETC)
-- 3. REMOVE ANY NULL VALUES OR BLANK VALUES
-- 4. REMOVE UNWATNED COLUMNS


-- CREATIND A STAGING TABLE TO NOT AFFECT THE RAW DATA
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;



-- 1. REMOVING DUPLICATES USING ROW_NUMBER()
SELECT *,
ROW_NUMBER() OVER(PARTITION BY COMPANY,  INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`) AS ROW_NUM
FROM layoffs_staging;

WITH DUPLICATE_CTE  AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY COMPANY,LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`,STAGE,
COUNTRY,FUNDS_RAISED_MILLIONS) AS ROW_NUM
FROM layoffs_staging
)
SELECT *
FROM DUPLICATE_CTE
WHERE ROW_NUM > 1;

SELECT * FROM layoffs_staging
WHERE COMPANY = 'CASPER';

 
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * FROM layoffs_staging2;

-- DROP TABLE layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY COMPANY,LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`,STAGE,
COUNTRY,FUNDS_RAISED_MILLIONS) AS ROW_NUM
FROM layoffs_staging;

-- WHERE ROW NUMBER IS > 2 THOSE WILL BE THE DUPLICATE ENTRIES SO WE WILL REMOVE THESE RECORDS
DELETE FROM layoffs_staging2 WHERE ROW_NUM > 1;

SELECT * FROM layoffs_staging2;



-- 2. STANDARDIZING THE DATA
SELECT company, TRIM(company) FROM layoffs_staging2;


UPDATE layoffs_staging2	SET company = TRIM(company);

SELECT DISTINCT industry FROM layoffs_staging2;



-- CORRECTING SPELLINGS
UPDATE layoffs_staging2 SET industry = 'Crypto'
WHERE industry LIKE 'CRYPTO%';

SELECT DISTINCT location FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'UNITED STATES%';

SELECT `DATE`, STR_TO_DATE(`DATE`, '%m/%d/%Y')
FROM layoffs_staging2;



-- CORRECTING DATE FORMATTING
UPDATE layoffs_staging2
SET `DATE` = STR_TO_DATE(`DATE`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;

SELECT * FROM layoffs_staging2;



-- 3. REMOVING NULL VALUES OR BLANK VALUES
SELECT * FROM layoffs_staging2
WHERE industry = '' OR industry IS NULL ;

SELECT * FROM layoffs_staging2
WHERE industry = '';

UPDATE layoffs_staging2 SET industry = NULL
WHERE industry = '';
			
SELECT *
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company=T2.company
WHERE T1. industry IS NULL 
AND T2.industry IS NOT NULL    
;


-- CORRECTING INDUSTRY COLUMN
UPDATE layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company=T2.company
SET T1.industry = T2.industry
WHERE T1. industry IS NULL 
AND T2.industry IS NOT NULL
;  


SELECT * FROM layoffs_staging2 WHERE TOTAL_LAID_OFF IS NULL AND PERCENTAGE_LAID_OFF IS NULL;
DELETE FROM layoffs_staging2 WHERE TOTAL_LAID_OFF IS NULL AND PERCENTAGE_LAID_OFF IS NULL;



-- 4. REMOVE UNWANTED COLUMNS
ALTER TABLE layoffs_staging2 DROP COLUMN ROW_NUM;

SELECT * FROM layoffs_staging2;
